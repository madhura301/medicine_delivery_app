import { DecimalPipe } from '@angular/common';
import { HttpErrorResponse } from '@angular/common/http';
import {
  ChangeDetectionStrategy,
  Component,
  ElementRef,
  OnDestroy,
  computed,
  effect,
  inject,
  input,
  signal,
  viewChild,
} from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { RouterLink } from '@angular/router';
import type * as Leaflet from 'leaflet';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { ChemistNearLocation, ChemistsNearLocation } from '../../../core/models/api.models';
import { ChemistsApiService } from '../../chemists/data/chemists-api.service';

/** Brand colours, kept in step with the portal theme. */
const COLOUR = {
  customer: '#e2701d',
  receives: '#1b7f53',
  blocked: '#8a94a8',
  radius: '#0b3a8f',
};

/**
 * A customer address on a map with every chemist inside the order-routing radius.
 *
 * Replaces the Google embed on the customer page: an embed shows one pin, and the point here is the
 * relationship between the address and the stores around it. Green stores would receive an order
 * placed at this address; grey ones are close but excluded — deactivated, no active payout account,
 * or activation fee unpaid — with the reason listed.
 *
 * Leaflet and OpenStreetMap need no API key. Leaflet is imported on first open so its ~40 KB only
 * loads for people who actually look at a map.
 */
@Component({
  selector: 'app-nearby-chemists-map',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [DecimalPipe, RouterLink, MatButtonModule, MatIconModule],
  template: `
    @if (!hasLocation()) {
      <p class="none">
        <mat-icon>location_off</mat-icon>
        <span>
          No map location saved for this address, so nearby chemists can't be found by distance —
          orders from it are matched by pin code only.
        </span>
      </p>
    } @else {
      <div class="bar">
        <span class="summary" [class.warn]="loaded() && data()?.receivingOrdersCount === 0">
          @if (loading()) {
            Finding chemists within {{ radiusLabel() }}…
          } @else if (error()) {
            <mat-icon>error_outline</mat-icon>{{ error() }}
          } @else if (data(); as d) {
            <mat-icon>{{ d.receivingOrdersCount > 0 ? 'local_pharmacy' : 'wrong_location' }}</mat-icon>
            <span>
              <strong>{{ d.chemists.length }}</strong>
              chemist{{ d.chemists.length === 1 ? '' : 's' }} within {{ d.radiusKm }} km ·
              <strong>{{ d.receivingOrdersCount }}</strong> receive{{ d.receivingOrdersCount === 1 ? 's' : '' }} orders
            </span>
          }
        </span>
        <button matButton type="button" (click)="toggle()">
          <mat-icon>{{ open() ? 'expand_less' : 'map' }}</mat-icon>
          {{ open() ? 'Hide map' : 'Show map' }}
        </button>
      </div>

      @if (loaded() && data()?.receivingOrdersCount === 0) {
        <p class="alert">
          <mat-icon>info</mat-icon>
          No chemist that receives orders is within {{ data()?.radiusKm }} km. An order placed at this
          address will be refused, and recorded in the Order Log.
        </p>
      }

      @if (open()) {
        <div class="map" #mapHost role="application" aria-label="Map of the address and nearby chemists"></div>
        <div class="legend" aria-hidden="true">
          <span><i [style.background]="colour.customer"></i>Delivery address</span>
          <span><i [style.background]="colour.receives"></i>Receives orders</span>
          <span><i [style.background]="colour.blocked"></i>Excluded from routing</span>
          <span><i class="ring" [style.border-color]="colour.radius"></i>{{ radiusLabel() }} radius</span>
        </div>

        @if (data()?.chemists?.length) {
          <ul class="list">
            @for (c of data()!.chemists; track c.medicalStoreId) {
              <li [class.focused]="focusedId() === c.medicalStoreId">
                <button type="button" class="dot-btn" (click)="focus(c)" [attr.aria-label]="'Show ' + c.medicalName + ' on the map'">
                  <i [style.background]="c.receivesOrders ? colour.receives : colour.blocked"></i>
                </button>
                <div class="who">
                  <a [routerLink]="['/chemists', c.medicalStoreId]">{{ c.medicalName }}</a>
                  <span class="addr">{{ c.address }}{{ c.postalCode ? ' · ' + c.postalCode : '' }}</span>
                  @if (!c.receivesOrders) {
                    <span class="why">{{ c.notReceivingReasons.join(' · ') }}</span>
                  }
                </div>
                <span class="km">{{ c.distanceKm | number: '1.2-2' }} km</span>
              </li>
            }
          </ul>
        } @else if (loaded()) {
          <p class="empty">No chemists at all within {{ radiusLabel() }} of this address.</p>
        }
      }
    }
  `,
  styles: `
    :host { display: block; }
    .none { display: flex; gap: 8px; align-items: flex-start; margin: 0; color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }
    .none mat-icon { font-size: 18px; width: 18px; height: 18px; flex: none; }

    .bar { display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; }
    .summary { display: inline-flex; align-items: center; gap: 6px; font: var(--mat-sys-body-medium); color: var(--mat-sys-on-surface-variant); }
    .summary mat-icon { font-size: 18px; width: 18px; height: 18px; color: #1b7f53; }
    .summary.warn mat-icon { color: var(--mat-sys-error); }
    .summary strong { color: var(--mat-sys-on-surface); }

    .alert { display: flex; gap: 8px; align-items: flex-start; margin: 8px 0 0; padding: 10px 12px; border-radius: 8px;
             background: var(--mat-sys-error-container); color: var(--mat-sys-on-error-container); font: var(--mat-sys-body-small); }
    .alert mat-icon { font-size: 18px; width: 18px; height: 18px; flex: none; }

    .map { height: var(--map-height, 320px); margin-top: 10px; border-radius: 10px; overflow: hidden;
           border: 1px solid var(--mat-sys-outline-variant); z-index: 0; }

    .legend { display: flex; flex-wrap: wrap; gap: 6px 16px; margin: 8px 0 4px; font: var(--mat-sys-body-small); color: var(--mat-sys-on-surface-variant); }
    .legend span { display: inline-flex; align-items: center; gap: 6px; }
    .legend i { width: 10px; height: 10px; border-radius: 50%; display: inline-block; }
    .legend i.ring { background: transparent; border: 2px dashed; width: 8px; height: 8px; }

    .list { list-style: none; margin: 8px 0 0; padding: 0; display: flex; flex-direction: column; }
    .list li { display: flex; align-items: flex-start; gap: 10px; padding: 8px 6px; border-top: 1px solid var(--mat-sys-outline-variant); border-radius: 6px; }
    .list li.focused { background: var(--mat-sys-surface-container-low); }
    .dot-btn { background: none; border: 0; padding: 4px; cursor: pointer; border-radius: 50%; margin-top: 1px; }
    .dot-btn:focus-visible { outline: 2px solid var(--mat-sys-primary); }
    .dot-btn i { display: block; width: 12px; height: 12px; border-radius: 50%; }
    .who { flex: 1; min-width: 0; display: flex; flex-direction: column; gap: 1px; }
    .who a { font: var(--mat-sys-title-small); color: var(--mat-sys-primary); text-decoration: none; }
    .who a:hover { text-decoration: underline; }
    .addr { font: var(--mat-sys-body-small); color: var(--mat-sys-on-surface-variant); }
    .why { font: var(--mat-sys-body-small); color: var(--mat-sys-error); }
    .km { font: var(--mat-sys-body-medium); font-variant-numeric: tabular-nums; white-space: nowrap; color: var(--mat-sys-on-surface-variant); }
    .empty { margin: 8px 0 0; font: var(--mat-sys-body-small); color: var(--mat-sys-on-surface-variant); }
  `,
})
export class NearbyChemistsMap implements OnDestroy {
  private readonly api = inject(ChemistsApiService);

  readonly latitude = input<number | null>(null);
  readonly longitude = input<number | null>(null);
  readonly label = input<string>('');
  readonly startOpen = input<boolean>(false);

  private readonly mapHost = viewChild<ElementRef<HTMLDivElement>>('mapHost');

  protected readonly colour = COLOUR;
  protected readonly data = signal<ChemistsNearLocation | null>(null);
  protected readonly loading = signal(false);
  protected readonly loaded = signal(false);
  protected readonly error = signal<string | null>(null);
  protected readonly open = signal(false);
  protected readonly focusedId = signal<string | null>(null);

  protected readonly hasLocation = computed(() => this.latitude() != null && this.longitude() != null);
  protected readonly radiusLabel = computed(() => `${this.data()?.radiusKm ?? 5} km`);

  private map: Leaflet.Map | null = null;
  private markers = new Map<string, Leaflet.CircleMarker>();

  constructor() {
    // The summary line is the useful part even with the map closed, so fetch as soon as there's a point.
    effect(() => {
      const lat = this.latitude();
      const lng = this.longitude();
      if (lat != null && lng != null) {
        void this.load(lat, lng);
      }
    });

    effect(() => {
      if (this.startOpen()) {
        this.open.set(true);
      }
    });

    // Draw once the container exists and the data has arrived; redraw if either changes.
    effect(() => {
      const host = this.mapHost();
      const data = this.data();
      if (host && data && this.open()) {
        void this.draw(host.nativeElement, data);
      }
    });
  }

  protected toggle(): void {
    if (this.open()) {
      this.destroyMap();
    }
    this.open.update((v) => !v);
  }

  protected focus(chemist: ChemistNearLocation): void {
    this.focusedId.set(chemist.medicalStoreId);
    const marker = this.markers.get(chemist.medicalStoreId);
    if (marker && this.map) {
      this.map.panTo(marker.getLatLng());
      marker.openPopup();
    }
  }

  private async load(lat: number, lng: number): Promise<void> {
    this.loading.set(true);
    this.error.set(null);
    try {
      this.data.set(await firstValueFrom(this.api.nearby(lat, lng)));
      this.loaded.set(true);
    } catch (err) {
      const e = err as HttpErrorResponse;
      this.error.set(e.status === 403 ? 'You do not have access to chemist locations.' : describeHttpError(e));
    } finally {
      this.loading.set(false);
    }
  }

  private async draw(host: HTMLElement, data: ChemistsNearLocation): Promise<void> {
    const lat = this.latitude();
    const lng = this.longitude();
    if (lat == null || lng == null) return;

    const L = await import('leaflet');
    this.destroyMap();

    const map = L.map(host, { scrollWheelZoom: false, attributionControl: true });
    this.map = map;

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    }).addTo(map);

    const centre = L.latLng(lat, lng);
    const radius = L.circle(centre, {
      radius: data.radiusKm * 1000,
      color: COLOUR.radius,
      weight: 1.5,
      dashArray: '6 6',
      fillColor: COLOUR.radius,
      fillOpacity: 0.05,
    }).addTo(map);

    L.circleMarker(centre, {
      radius: 9,
      color: '#fff',
      weight: 3,
      fillColor: COLOUR.customer,
      fillOpacity: 1,
    })
      .bindPopup(this.popup(this.label() || 'Delivery address', 'Delivery address'))
      .addTo(map);

    this.markers.clear();
    for (const c of data.chemists) {
      const marker = L.circleMarker(L.latLng(c.latitude, c.longitude), {
        radius: 7,
        color: '#fff',
        weight: 2,
        fillColor: c.receivesOrders ? COLOUR.receives : COLOUR.blocked,
        fillOpacity: 1,
      })
        .bindPopup(
          this.popup(
            c.medicalName,
            `${c.distanceKm.toFixed(2)} km away`,
            c.receivesOrders ? 'Receives orders' : c.notReceivingReasons.join(' · '),
            c.receivesOrders,
          ),
        )
        .on('click', () => this.focusedId.set(c.medicalStoreId))
        .addTo(map);
      this.markers.set(c.medicalStoreId, marker);
    }

    map.fitBounds(radius.getBounds(), { padding: [8, 8] });
    // The container may have been laid out after Leaflet measured it.
    setTimeout(() => map.invalidateSize(), 0);
  }

  /** Built from DOM nodes, not an HTML string: store names come from user input. */
  private popup(title: string, line: string, status?: string, ok?: boolean): HTMLElement {
    const box = document.createElement('div');
    box.style.font = '13px/1.4 Roboto, sans-serif';
    const heading = document.createElement('strong');
    heading.textContent = title;
    box.appendChild(heading);
    const detail = document.createElement('div');
    detail.textContent = line;
    detail.style.color = '#5a6680';
    box.appendChild(detail);
    if (status) {
      const s = document.createElement('div');
      s.textContent = status;
      s.style.color = ok ? COLOUR.receives : '#b3261e';
      s.style.marginTop = '2px';
      box.appendChild(s);
    }
    return box;
  }

  private destroyMap(): void {
    this.map?.remove();
    this.map = null;
    this.markers.clear();
  }

  ngOnDestroy(): void {
    this.destroyMap();
  }
}
