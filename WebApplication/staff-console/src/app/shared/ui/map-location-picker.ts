import {
  AfterViewInit,
  ChangeDetectionStrategy,
  Component,
  ElementRef,
  OnDestroy,
  inject,
  input,
  model,
  signal,
  viewChild,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { LocationMap } from './location-map';
import { GoogleMapsLoader } from './google-maps-loader';

/**
 * Sets a latitude/longitude by clicking a Google map.
 *
 * Needs `environment.googleMapsApiKey`. Without one the Maps JavaScript API cannot be loaded, so
 * the component degrades to typed coordinates plus the keyless read-only preview — still usable,
 * just not click-to-place. See docs/GOOGLE_MAPS_SETUP.md.
 */
@Component({
  selector: 'app-map-location-picker',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    FormsModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    MatProgressSpinnerModule,
    LocationMap,
  ],
  template: `
    <div class="head">
      <span class="title">
        <mat-icon>place</mat-icon>
        Geo location
      </span>
      @if (hasValue()) {
        <button matButton type="button" (click)="clear()">
          <mat-icon>backspace</mat-icon>
          Clear
        </button>
      }
    </div>

    @if (loaderState() === 'loading') {
      <div class="centered"><mat-spinner diameter="28" /></div>
    }

    @if (loaderState() === 'ready') {
      <p class="help">Click the map, or drag the pin, to set the exact delivery point.</p>
      <div #mapHost class="map-host"></div>
    }

    @if (loaderState() === 'unavailable') {
      <p class="notice">
        <mat-icon>info</mat-icon>
        <span>
          Click-to-place needs a Google Maps API key, which is not configured. Enter the
          coordinates below — the preview updates as you type.
        </span>
      </p>
    }

    <div class="coords">
      <mat-form-field appearance="outline" subscriptSizing="dynamic">
        <mat-label>Latitude</mat-label>
        <input
          matInput
          type="number"
          step="any"
          inputmode="decimal"
          [ngModel]="latitude()"
          (ngModelChange)="onLatitude($event)"
          name="latitude"
        />
      </mat-form-field>

      <mat-form-field appearance="outline" subscriptSizing="dynamic">
        <mat-label>Longitude</mat-label>
        <input
          matInput
          type="number"
          step="any"
          inputmode="decimal"
          [ngModel]="longitude()"
          (ngModelChange)="onLongitude($event)"
          name="longitude"
        />
      </mat-form-field>
    </div>

    @if (loaderState() === 'unavailable') {
      <app-location-map
        class="preview"
        [latitude]="latitude()"
        [longitude]="longitude()"
        [label]="label()"
        [collapsible]="false"
      />
    }
  `,
  styles: `
    :host { display: block; }

    .head {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
      margin-bottom: 4px;
    }
    .title {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      font: var(--mat-sys-title-small);
    }

    .help,
    .notice {
      margin: 0 0 8px;
      color: var(--mat-sys-on-surface-variant);
      font: var(--mat-sys-body-small);
    }
    .notice { display: flex; gap: 8px; align-items: flex-start; }
    .notice mat-icon { flex: none; font-size: 18px; width: 18px; height: 18px; }

    .map-host {
      width: 100%;
      height: 260px;
      border: 1px solid var(--mat-sys-outline-variant);
      border-radius: 12px;
      overflow: hidden;
      margin-bottom: 8px;
    }

    .centered { display: flex; justify-content: center; padding: 24px; }

    .coords {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 12px;
    }
    .preview { display: block; margin-top: 12px; --map-height: 200px; }

    @media (max-width: 599px) {
      .coords { grid-template-columns: 1fr; }
    }
  `,
})
export class MapLocationPicker implements AfterViewInit, OnDestroy {
  readonly latitude = model<number | null>(null);
  readonly longitude = model<number | null>(null);
  readonly label = input<string>('');
  /** Where the map centres when nothing is set yet. Defaults to Pune. */
  readonly fallbackCentre = input<{ lat: number; lng: number }>({ lat: 18.5204, lng: 73.8567 });

  private readonly loader = inject(GoogleMapsLoader);
  private readonly mapHost = viewChild<ElementRef<HTMLElement>>('mapHost');

  protected readonly loaderState = signal<'loading' | 'ready' | 'unavailable'>(
    // Skip the spinner entirely when we already know there is no key.
    inject(GoogleMapsLoader).available ? 'loading' : 'unavailable',
  );

  private map: google.maps.Map | null = null;
  private marker: google.maps.Marker | null = null;

  protected hasValue(): boolean {
    return this.latitude() !== null && this.longitude() !== null;
  }

  async ngAfterViewInit(): Promise<void> {
    if (!this.loader.available) {
      return;
    }

    const ok = await this.loader.load();
    if (!ok) {
      this.loaderState.set('unavailable');
      return;
    }

    this.loaderState.set('ready');
    // The map host only exists after the state flips, so wait a tick for it to render.
    setTimeout(() => this.initMap(), 0);
  }

  private initMap(): void {
    const host = this.mapHost()?.nativeElement;
    if (!host || this.map) {
      return;
    }

    const centre = this.hasValue()
      ? { lat: this.latitude()!, lng: this.longitude()! }
      : this.fallbackCentre();

    this.map = new google.maps.Map(host, {
      center: centre,
      zoom: this.hasValue() ? 16 : 12,
      mapTypeControl: false,
      streetViewControl: false,
      fullscreenControl: false,
    });

    if (this.hasValue()) {
      this.placeMarker(centre);
    }

    this.map.addListener('click', (event: google.maps.MapMouseEvent) => {
      if (event.latLng) {
        this.setPosition(event.latLng.lat(), event.latLng.lng());
      }
    });
  }

  private placeMarker(position: google.maps.LatLngLiteral): void {
    if (!this.map) {
      return;
    }

    if (this.marker) {
      this.marker.setPosition(position);
      return;
    }

    this.marker = new google.maps.Marker({
      map: this.map,
      position,
      draggable: true,
    });

    this.marker.addListener('dragend', () => {
      const pos = this.marker?.getPosition();
      if (pos) {
        this.setPosition(pos.lat(), pos.lng());
      }
    });
  }

  /** Six decimals is roughly 0.1 m — more precision than a delivery address ever needs. */
  private round(value: number): number {
    return Number(value.toFixed(6));
  }

  private setPosition(lat: number, lng: number): void {
    const position = { lat: this.round(lat), lng: this.round(lng) };
    this.latitude.set(position.lat);
    this.longitude.set(position.lng);
    this.placeMarker(position);
    this.map?.panTo(position);
  }

  protected onLatitude(value: number | string | null): void {
    this.latitude.set(this.toNumber(value));
    this.syncMapFromInputs();
  }

  protected onLongitude(value: number | string | null): void {
    this.longitude.set(this.toNumber(value));
    this.syncMapFromInputs();
  }

  private toNumber(value: number | string | null): number | null {
    if (value === null || value === '' || value === undefined) {
      return null;
    }
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : null;
  }

  /** Keeps the pin in step when coordinates are typed rather than clicked. */
  private syncMapFromInputs(): void {
    if (!this.map || !this.hasValue()) {
      return;
    }
    const position = { lat: this.latitude()!, lng: this.longitude()! };
    this.placeMarker(position);
    this.map.panTo(position);
  }

  protected clear(): void {
    this.latitude.set(null);
    this.longitude.set(null);
    this.marker?.setMap(null);
    this.marker = null;
  }

  ngOnDestroy(): void {
    this.marker?.setMap(null);
    this.marker = null;
    this.map = null;
  }
}
