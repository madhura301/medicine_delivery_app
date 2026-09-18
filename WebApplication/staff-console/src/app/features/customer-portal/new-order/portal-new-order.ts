import { HttpErrorResponse } from '@angular/common/http';
import {
  ChangeDetectionStrategy,
  Component,
  OnDestroy,
  computed,
  effect,
  inject,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatDialog } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { OrderInputType, OrderType } from '../../../core/models/enums';
import { ToastService } from '../../../core/ui/toast.service';
import { formatAddress } from '../../customers/data/customers-api.service';
import { AddressFormData, AddressFormDialog } from '../../customers/dialogs/address-form-dialog';
import { describePlaceOrderError } from '../data/order-journey';
import { PortalApiService } from '../data/portal-api.service';
import { PortalStore } from '../data/portal.store';
import { MAX_RECORDING_SECONDS, VoiceRecorder } from '../data/voice-recorder';

type InputMode = 'photo' | 'text' | 'voice';

/** Mirrors the API's allow-lists and its 10 MB cap, so a bad file is caught before upload. */
const IMAGE_TYPES = ['.jpg', '.jpeg', '.png', '.gif', '.bmp'];
const AUDIO_TYPES = ['.mp3', '.wav', '.m4a', '.aac', '.ogg'];
const MAX_BYTES = 10 * 1024 * 1024;

@Component({
  selector: 'app-portal-new-order',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [FormsModule, RouterLink, MatButtonModule, MatIconModule, MatProgressSpinnerModule],
  template: `
    <header class="head">
      <a routerLink="/my" class="back"><mat-icon>arrow_back</mat-icon>Home</a>
      <h1>New order</h1>
      <p>Tell us what you need and where to deliver it. A chemist near you will send the bill before you pay anything.</p>
    </header>

    <div class="layout">
      <div class="steps">

        <!-- 1 · medicines -->
        <section class="card" aria-labelledby="s1">
          <div class="card-head">
            <span class="num" [class.ok]="inputReady()">@if (inputReady()) {<mat-icon>check</mat-icon>} @else {1}</span>
            <h2 id="s1">What do you need?</h2>
          </div>

          <div class="modes" role="radiogroup" aria-label="How you want to order">
            @for (m of modes; track m.key) {
              <button
                type="button" role="radio" class="mode"
                [class.on]="mode() === m.key" [attr.aria-checked]="mode() === m.key"
                (click)="setMode(m.key)"
              >
                <mat-icon>{{ m.icon }}</mat-icon>
                <span>{{ m.label }}</span>
              </button>
            }
          </div>

          @switch (mode()) {
            @case ('photo') {
              @if (photo(); as file) {
                <div class="preview">
                  <img [src]="photoUrl()" alt="Your prescription" />
                  <div class="preview-meta">
                    <strong>{{ file.name }}</strong>
                    <span>{{ size(file) }}</span>
                    <div class="row">
                      <label class="text-btn">Replace<input type="file" [accept]="imageAccept" (change)="pickPhoto($event)" hidden /></label>
                      <button type="button" class="text-btn danger" (click)="clearPhoto()">Remove</button>
                    </div>
                  </div>
                </div>
              } @else {
                <label
                  class="drop" [class.over]="dragOver()"
                  (dragover)="$event.preventDefault(); dragOver.set(true)"
                  (dragleave)="dragOver.set(false)"
                  (drop)="dropPhoto($event)"
                >
                  <input type="file" [accept]="imageAccept" capture="environment" (change)="pickPhoto($event)" />
                  <span class="drop-icon"><mat-icon>add_a_photo</mat-icon></span>
                  <strong>Add a photo of your prescription</strong>
                  <span>Drag it here, or click to choose · JPG or PNG, up to 10 MB</span>
                </label>
              }
            }
            @case ('text') {
              <label class="field">
                <span class="sr">Medicines you need</span>
                <textarea
                  rows="6" maxlength="2000"
                  [ngModel]="text()" (ngModelChange)="text.set($event)"
                  placeholder="e.g.&#10;Paracetamol 500 mg — 10 tablets&#10;Cetirizine 10 mg — 1 strip"
                ></textarea>
                <span class="count">{{ text().length }} / 2000</span>
              </label>
            }
            @case ('voice') {
              @if (recording()) {
                <div class="rec live">
                  <span class="pulse" aria-hidden="true"></span>
                  <div class="rec-body">
                    <strong>Recording…</strong>
                    <span class="timer">{{ clock(elapsed()) }} <small>/ {{ clock(maxSeconds) }}</small></span>
                  </div>
                  <button matButton="filled" class="pt-round" (click)="stopRecording()"><mat-icon>stop</mat-icon>Stop</button>
                </div>
              } @else if (voice(); as file) {
                <div class="rec">
                  <audio [src]="voiceUrl()" controls></audio>
                  <div class="row">
                    <button type="button" class="text-btn" (click)="startRecording()">Record again</button>
                    <button type="button" class="text-btn danger" (click)="clearVoice()">Remove</button>
                  </div>
                </div>
              } @else {
                <div class="rec start">
                  <button type="button" class="mic" (click)="startRecording()" [disabled]="!canRecord" aria-label="Start recording">
                    <mat-icon>mic</mat-icon>
                  </button>
                  <div>
                    <strong>{{ canRecord ? 'Tap to record your order' : 'Recording is not available in this browser' }}</strong>
                    <span>Say the medicine names and quantities. Up to 5 minutes.</span>
                    <label class="text-btn">or upload an audio file<input type="file" [accept]="audioAccept" (change)="pickAudio($event)" hidden /></label>
                  </div>
                </div>
              }
            }
          }

          @if (fileError()) {
            <p class="field-error" role="alert"><mat-icon>error_outline</mat-icon>{{ fileError() }}</p>
          }
        </section>

        <!-- 2 · type -->
        <section class="card" aria-labelledby="s2">
          <div class="card-head">
            <span class="num ok"><mat-icon>check</mat-icon></span>
            <h2 id="s2">Type of order</h2>
          </div>
          <div class="choices" role="radiogroup" aria-labelledby="s2">
            <button type="button" role="radio" class="choice" [class.on]="orderType() === rx" [attr.aria-checked]="orderType() === rx" (click)="orderType.set(rx)">
              <mat-icon>medication</mat-icon>
              <span><strong>Prescription medicines</strong><small>Needs a doctor's prescription</small></span>
            </button>
            <button type="button" role="radio" class="choice" [class.on]="orderType() === otc" [attr.aria-checked]="orderType() === otc" (click)="orderType.set(otc)">
              <mat-icon>health_and_safety</mat-icon>
              <span><strong>Over the counter</strong><small>Everyday medicines and health products</small></span>
            </button>
          </div>
        </section>

        <!-- 3 · address -->
        <section class="card" aria-labelledby="s3">
          <div class="card-head">
            <span class="num" [class.ok]="!!addressId()">@if (addressId()) {<mat-icon>check</mat-icon>} @else {3}</span>
            <h2 id="s3">Deliver to</h2>
          </div>

          <div class="addresses" role="radiogroup" aria-labelledby="s3">
            @for (addr of store.addresses(); track addr.id) {
              <button type="button" role="radio" class="address" [class.on]="addressId() === addr.id" [attr.aria-checked]="addressId() === addr.id" (click)="addressId.set(addr.id)">
                <mat-icon>{{ addressId() === addr.id ? 'radio_button_checked' : 'radio_button_unchecked' }}</mat-icon>
                <span>
                  @if (addr.isDefault) { <em>Default</em> }
                  {{ formatAddress(addr) }}
                </span>
              </button>
            }
            <button type="button" class="address add" (click)="addAddress()">
              <mat-icon>add</mat-icon><span>Add a new address</span>
            </button>
          </div>
        </section>
      </div>

      <!-- summary -->
      <aside class="summary card">
        <h2>Order summary</h2>
        <dl>
          <dt>Medicines</dt><dd>{{ inputSummary() }}</dd>
          <dt>Type</dt><dd>{{ orderType() === rx ? 'Prescription' : 'Over the counter' }}</dd>
          <dt>Deliver to</dt><dd>{{ selectedAddressText() }}</dd>
        </dl>

        @if (refusal(); as r) {
          <div class="refusal" role="alert">
            <mat-icon>wrong_location</mat-icon>
            <div><strong>{{ r.title }}</strong><p>{{ r.message }}</p></div>
          </div>
        }

        <button matButton="filled" class="pt-cta place" [disabled]="!canSubmit()" (click)="submit()">
          @if (submitting()) { <mat-spinner diameter="18" /> Placing order… } @else { Place order }
        </button>
        <p class="fine">You won't pay now. The chemist sends the bill first, and you pay only once you've seen the amount.</p>
      </aside>
    </div>
  `,
  styles: `
    :host { display: block; }
    .sr { position: absolute; width: 1px; height: 1px; overflow: hidden; clip: rect(0 0 0 0); }

    .head { display: flex; flex-direction: column; gap: 6px; margin-bottom: 24px; }
    .back { display: inline-flex; align-items: center; gap: 4px; color: var(--pt-muted); text-decoration: none; font-weight: 600; font-size: 0.9rem; width: fit-content; }
    .back mat-icon { font-size: 18px; width: 18px; height: 18px; }
    h1 { margin: 4px 0 0; font-size: clamp(1.7rem, 3vw, 2.2rem); font-weight: 800; letter-spacing: -0.025em; color: var(--pt-navy-deep); }
    .head p { margin: 0; color: var(--pt-muted); max-width: 62ch; }

    .layout { display: grid; grid-template-columns: minmax(0, 1fr) 340px; gap: 24px; align-items: start; }
    .steps { display: flex; flex-direction: column; gap: 16px; }
    .card { background: var(--pt-card); border: 1px solid var(--pt-line); border-radius: var(--pt-radius); padding: 22px; }
    .card-head { display: flex; align-items: center; gap: 12px; margin-bottom: 18px; }
    .card-head h2 { margin: 0; font-size: 1.15rem; font-weight: 700; }
    .num { width: 30px; height: 30px; border-radius: 50%; display: grid; place-items: center; font-weight: 800; font-size: 0.9rem; background: var(--pt-navy-soft); color: var(--pt-navy); flex: none; }
    .num.ok { background: var(--pt-good); color: #fff; }
    .num mat-icon { font-size: 18px; width: 18px; height: 18px; }

    .modes { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 18px; }
    .mode, .choice, .address {
      font: inherit; color: inherit; cursor: pointer; text-align: left;
      border: 1.5px solid var(--pt-line); background: var(--pt-card); border-radius: 14px;
      transition: border-color 140ms ease, background 140ms ease;
    }
    .mode { display: flex; flex-direction: column; align-items: center; gap: 6px; padding: 14px 8px; font-weight: 600; color: var(--pt-muted); text-align: center; }
    .mode.on, .choice.on, .address.on { border-color: var(--pt-navy); background: var(--pt-navy-soft); color: var(--pt-navy-deep); }
    .mode:focus-visible, .choice:focus-visible, .address:focus-visible, .drop:focus-within, .mic:focus-visible {
      outline: 3px solid color-mix(in srgb, var(--pt-navy) 40%, transparent); outline-offset: 2px;
    }

    .drop {
      position: relative; display: flex; flex-direction: column; align-items: center; gap: 6px; text-align: center;
      padding: 36px 20px; border: 2px dashed color-mix(in srgb, var(--pt-navy) 28%, transparent);
      border-radius: 16px; background: var(--pt-ground); cursor: pointer;
    }
    .drop.over { border-color: var(--pt-orange); background: var(--pt-orange-soft); }
    .drop input { position: absolute; inset: 0; opacity: 0; cursor: pointer; }
    .drop-icon { width: 56px; height: 56px; border-radius: 50%; display: grid; place-items: center; background: var(--pt-orange); color: #fff; margin-bottom: 6px; }
    .drop strong { font-weight: 700; }
    .drop span { color: var(--pt-muted); font-size: 0.88rem; }

    .preview { display: flex; gap: 16px; align-items: center; padding: 12px; border-radius: 16px; background: var(--pt-ground); }
    .preview img { width: 112px; height: 112px; object-fit: cover; border-radius: 12px; border: 1px solid var(--pt-line); }
    .preview-meta { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
    .preview-meta strong { font-weight: 700; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .preview-meta span { color: var(--pt-muted); font-size: 0.88rem; }
    .row { display: flex; gap: 16px; margin-top: 6px; }
    .text-btn { background: none; border: 0; padding: 0; font: inherit; font-weight: 700; color: var(--pt-navy); cursor: pointer; font-size: 0.92rem; }
    .text-btn.danger { color: var(--pt-stop); }

    .field { position: relative; display: block; }
    textarea {
      width: 100%; resize: vertical; font: inherit; font-size: 1rem; line-height: 1.55; color: var(--pt-ink);
      padding: 14px 16px; border-radius: 14px; border: 1.5px solid var(--pt-line); background: var(--pt-ground);
    }
    textarea:focus { outline: none; border-color: var(--pt-navy); background: #fff; }
    .count { position: absolute; right: 12px; bottom: 10px; font-size: 0.78rem; color: var(--pt-faint); }

    .rec { display: flex; flex-direction: column; gap: 10px; padding: 16px; border-radius: 16px; background: var(--pt-ground); }
    .rec audio { width: 100%; }
    .rec.start, .rec.live { flex-direction: row; align-items: center; gap: 16px; }
    .rec.start > div { display: flex; flex-direction: column; gap: 2px; align-items: flex-start; }
    .rec.start strong { font-weight: 700; }
    .rec.start span { color: var(--pt-muted); font-size: 0.88rem; }
    .mic { width: 64px; height: 64px; border-radius: 50%; border: 0; background: var(--pt-orange); color: #fff; cursor: pointer; display: grid; place-items: center; flex: none; box-shadow: 0 6px 18px color-mix(in srgb, var(--pt-orange) 40%, transparent); }
    .mic:disabled { background: var(--pt-line); box-shadow: none; cursor: not-allowed; }
    .mic mat-icon { font-size: 30px; width: 30px; height: 30px; }
    .rec.live { background: var(--pt-orange-soft); }
    .rec-body { display: flex; flex-direction: column; flex: 1; }
    .timer { font: 700 1.3rem Figtree, sans-serif; font-variant-numeric: tabular-nums; }
    .timer small { color: var(--pt-muted); font-weight: 500; font-size: 0.85rem; }
    .pulse { width: 14px; height: 14px; border-radius: 50%; background: var(--pt-stop); animation: pulse 1.2s ease-in-out infinite; }
    @keyframes pulse { 50% { opacity: 0.35; transform: scale(0.8); } }

    .field-error { display: flex; align-items: center; gap: 6px; margin: 12px 0 0; color: var(--pt-stop); font-size: 0.9rem; }
    .field-error mat-icon { font-size: 18px; width: 18px; height: 18px; }

    .choices { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
    .choice { display: flex; gap: 12px; align-items: center; padding: 14px 16px; }
    .choice mat-icon { color: var(--pt-navy); }
    .choice span { display: flex; flex-direction: column; }
    .choice strong { font-weight: 700; }
    .choice small { color: var(--pt-muted); font-size: 0.82rem; }

    .addresses { display: flex; flex-direction: column; gap: 10px; }
    .address { display: flex; gap: 12px; align-items: flex-start; padding: 14px 16px; line-height: 1.45; }
    .address mat-icon { color: var(--pt-navy); flex: none; }
    .address em { font-style: normal; font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; background: var(--pt-orange-soft); color: var(--pt-orange-deep); padding: 2px 7px; border-radius: 6px; margin-right: 6px; }
    .address.add { border-style: dashed; color: var(--pt-navy); font-weight: 700; align-items: center; }

    .summary { position: sticky; top: 92px; display: flex; flex-direction: column; gap: 14px; }
    .summary h2 { margin: 0; font-size: 1.1rem; font-weight: 700; }
    dl { margin: 0; display: grid; grid-template-columns: auto 1fr; gap: 10px 14px; }
    dt { color: var(--pt-muted); font-size: 0.88rem; }
    dd { margin: 0; font-weight: 600; font-size: 0.92rem; text-align: right; word-break: break-word; }
    .place { width: 100%; height: 50px; font-size: 1.02rem; }
    .place mat-spinner { display: inline-block; margin-right: 8px; vertical-align: middle; }
    .fine { margin: 0; color: var(--pt-faint); font-size: 0.82rem; line-height: 1.5; text-align: center; }
    .refusal { display: flex; gap: 10px; padding: 14px; border-radius: 14px; background: var(--pt-stop-soft); color: var(--pt-stop); }
    .refusal strong { font-weight: 700; }
    .refusal p { margin: 2px 0 0; color: var(--pt-ink); font-size: 0.88rem; line-height: 1.45; }

    @media (max-width: 940px) { .layout { grid-template-columns: 1fr; } .summary { position: static; } }
    @media (max-width: 560px) { .choices { grid-template-columns: 1fr; } .mode span { font-size: 0.82rem; } }
    @media (prefers-reduced-motion: reduce) { .pulse { animation: none; } }
  `,
})
export class PortalNewOrder implements OnDestroy {
  protected readonly store = inject(PortalStore);
  private readonly api = inject(PortalApiService);
  private readonly dialog = inject(MatDialog);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);
  private readonly toast = inject(ToastService);

  protected readonly formatAddress = formatAddress;
  protected readonly rx = OrderType.PrescriptionDrugs;
  protected readonly otc = OrderType.OTC;
  protected readonly imageAccept = IMAGE_TYPES.join(',');
  protected readonly audioAccept = AUDIO_TYPES.join(',');
  protected readonly maxSeconds = MAX_RECORDING_SECONDS;
  protected readonly canRecord = VoiceRecorder.isSupported();

  protected readonly modes = [
    { key: 'photo' as const, label: 'Photo', icon: 'photo_camera' },
    { key: 'text' as const, label: 'Type it', icon: 'edit_note' },
    { key: 'voice' as const, label: 'Voice note', icon: 'mic' },
  ];

  protected readonly mode = signal<InputMode>('photo');
  protected readonly orderType = signal<OrderType>(OrderType.PrescriptionDrugs);
  protected readonly addressId = signal<string | null>(null);

  protected readonly photo = signal<File | null>(null);
  protected readonly photoUrl = signal<string | null>(null);
  protected readonly text = signal('');
  protected readonly voice = signal<File | null>(null);
  protected readonly voiceUrl = signal<string | null>(null);

  protected readonly dragOver = signal(false);
  protected readonly fileError = signal<string | null>(null);
  protected readonly recording = signal(false);
  protected readonly elapsed = signal(0);
  protected readonly submitting = signal(false);
  protected readonly refusal = signal<{ title: string; message: string } | null>(null);

  private recorder: VoiceRecorder | null = null;
  private timer: ReturnType<typeof setInterval> | null = null;

  protected readonly inputReady = computed(() => {
    switch (this.mode()) {
      case 'photo': return !!this.photo();
      case 'text': return this.text().trim().length > 0;
      case 'voice': return !!this.voice() && !this.recording();
    }
  });

  protected readonly canSubmit = computed(
    () => this.inputReady() && !!this.addressId() && !this.submitting() && !!this.store.customerId(),
  );

  protected readonly inputSummary = computed(() => {
    switch (this.mode()) {
      case 'photo': return this.photo() ? 'Prescription photo' : 'Photo not added yet';
      case 'text': {
        const lines = this.text().trim().split('\n').filter(Boolean).length;
        return lines ? `${lines} item${lines === 1 ? '' : 's'} typed` : 'Nothing typed yet';
      }
      case 'voice': return this.voice() ? 'Voice note' : 'Not recorded yet';
    }
  });

  protected readonly selectedAddressText = computed(() => {
    const addr = this.store.addresses().find((a) => a.id === this.addressId());
    return addr ? formatAddress(addr) : 'Choose an address';
  });

  constructor() {
    const input = this.route.snapshot.queryParamMap.get('input');
    if (input === 'text' || input === 'voice' || input === 'photo') {
      this.mode.set(input);
      if (input !== 'photo') {
        this.orderType.set(OrderType.OTC);
      }
    }

    // Preselect the default address once the addresses arrive.
    effect(() => {
      const fallback = this.store.defaultAddress();
      if (!this.addressId() && fallback) {
        this.addressId.set(fallback.id);
      }
    });
  }

  protected setMode(mode: InputMode): void {
    if (this.recording()) {
      this.cancelRecording();
    }
    this.fileError.set(null);
    this.mode.set(mode);
  }

  /* ── photo ── */

  protected pickPhoto(event: Event): void {
    const file = (event.target as HTMLInputElement).files?.[0];
    (event.target as HTMLInputElement).value = '';
    if (file) {
      this.setPhoto(file);
    }
  }

  protected dropPhoto(event: DragEvent): void {
    event.preventDefault();
    this.dragOver.set(false);
    const file = event.dataTransfer?.files?.[0];
    if (file) {
      this.setPhoto(file);
    }
  }

  private setPhoto(file: File): void {
    const problem = this.checkFile(file, IMAGE_TYPES, 'a JPG, PNG, GIF or BMP image');
    this.fileError.set(problem);
    if (problem) {
      return;
    }
    this.revoke(this.photoUrl());
    this.photo.set(file);
    this.photoUrl.set(URL.createObjectURL(file));
  }

  protected clearPhoto(): void {
    this.revoke(this.photoUrl());
    this.photo.set(null);
    this.photoUrl.set(null);
  }

  /* ── voice ── */

  protected async startRecording(): Promise<void> {
    this.fileError.set(null);
    this.clearVoice();
    this.recorder = new VoiceRecorder();
    try {
      await this.recorder.start();
    } catch {
      this.recorder = null;
      this.fileError.set('We need permission to use your microphone. Allow it in your browser, or upload an audio file instead.');
      return;
    }
    this.elapsed.set(0);
    this.recording.set(true);
    this.timer = setInterval(() => {
      this.elapsed.update((s) => s + 1);
      if (this.elapsed() >= MAX_RECORDING_SECONDS) {
        void this.stopRecording();
      }
    }, 1000);
  }

  protected async stopRecording(): Promise<void> {
    this.clearTimer();
    if (!this.recorder) {
      return;
    }
    const file = await this.recorder.stop();
    this.recorder = null;
    this.recording.set(false);

    if (this.elapsed() < 1) {
      this.fileError.set('That recording was too short. Hold on a moment longer and try again.');
      return;
    }
    this.voice.set(file);
    this.voiceUrl.set(URL.createObjectURL(file));
  }

  private cancelRecording(): void {
    this.clearTimer();
    this.recorder?.cancel();
    this.recorder = null;
    this.recording.set(false);
  }

  protected pickAudio(event: Event): void {
    const file = (event.target as HTMLInputElement).files?.[0];
    (event.target as HTMLInputElement).value = '';
    if (!file) {
      return;
    }
    const problem = this.checkFile(file, AUDIO_TYPES, 'an MP3, WAV, M4A, AAC or OGG audio file');
    this.fileError.set(problem);
    if (!problem) {
      this.clearVoice();
      this.voice.set(file);
      this.voiceUrl.set(URL.createObjectURL(file));
    }
  }

  protected clearVoice(): void {
    this.revoke(this.voiceUrl());
    this.voice.set(null);
    this.voiceUrl.set(null);
  }

  /* ── address ── */

  protected async addAddress(): Promise<void> {
    const customerId = this.store.customerId();
    if (!customerId) {
      return;
    }
    const before = new Set(this.store.addresses().map((a) => a.id));
    const ref = this.dialog.open<AddressFormDialog, AddressFormData, boolean>(AddressFormDialog, {
      data: { customerId },
      width: '640px',
      maxWidth: '96vw',
      panelClass: 'portal-theme',
    });
    if (await firstValueFrom(ref.afterClosed())) {
      await this.store.refreshAddresses();
      const added = this.store.addresses().find((a) => !before.has(a.id));
      if (added) {
        this.addressId.set(added.id);
      }
    }
  }

  /* ── submit ── */

  protected async submit(): Promise<void> {
    const customerId = this.store.customerId();
    const addressId = this.addressId();
    if (!this.canSubmit() || !customerId || !addressId) {
      return;
    }

    this.refusal.set(null);
    this.submitting.set(true);

    const mode = this.mode();
    try {
      const order = await firstValueFrom(
        this.api.placeOrder({
          customerId,
          customerAddressId: addressId,
          orderType: this.orderType(),
          orderInputType:
            mode === 'photo' ? OrderInputType.Image : mode === 'voice' ? OrderInputType.Voice : OrderInputType.Text,
          text: mode === 'text' ? this.text().trim() : undefined,
          file: mode === 'photo' ? this.photo() ?? undefined : mode === 'voice' ? this.voice() ?? undefined : undefined,
        }),
      );
      this.store.upsertOrder(order);
      this.toast.success(`Order ${order.orderNumber ?? ''} placed.`.replace('  ', ' '));
      void this.router.navigate(['/my/orders', order.orderId]);
    } catch (err) {
      this.refusal.set(describePlaceOrderError(err as HttpErrorResponse));
    } finally {
      this.submitting.set(false);
    }
  }

  /* ── helpers ── */

  private checkFile(file: File, allowed: string[], what: string): string | null {
    const ext = file.name.slice(file.name.lastIndexOf('.')).toLowerCase();
    if (!allowed.includes(ext)) {
      return `Please choose ${what}.`;
    }
    if (file.size > MAX_BYTES) {
      return `That file is ${this.size(file)}. The limit is 10 MB.`;
    }
    return null;
  }

  protected size(file: File): string {
    return file.size > 1024 * 1024 ? `${(file.size / 1024 / 1024).toFixed(1)} MB` : `${Math.max(1, Math.round(file.size / 1024))} KB`;
  }

  protected clock(seconds: number): string {
    return `${Math.floor(seconds / 60)}:${String(seconds % 60).padStart(2, '0')}`;
  }

  private clearTimer(): void {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }

  private revoke(url: string | null): void {
    if (url) {
      URL.revokeObjectURL(url);
    }
  }

  ngOnDestroy(): void {
    this.cancelRecording();
    this.revoke(this.photoUrl());
    this.revoke(this.voiceUrl());
  }
}
