import { ChangeDetectionStrategy, Component, computed, inject, input, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { environment } from '../../../environments/environment';

/**
 * Shows a stored latitude/longitude on an embedded Google Map.
 *
 * Two embed endpoints, chosen automatically:
 *  - with `environment.googleMapsApiKey` set → the official **Maps Embed API**, which is the
 *    documented and supported route (needs a key with billing enabled);
 *  - without a key → the long-standing keyless `maps.google.com/…&output=embed` form, so the map
 *    works out of the box with no Google Cloud account. It is not a documented API, so treat the
 *    key path as the one to move to for anything customer-facing.
 *
 * The iframe is only created once the map is opened — a list of addresses would otherwise load one
 * Google frame per row.
 */
@Component({
  selector: 'app-location-map',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [MatButtonModule, MatIconModule],
  template: `
    @if (!hasLocation()) {
      <p class="none">
        <mat-icon>location_off</mat-icon>
        <span>No geo location saved{{ label() ? ' for ' + label() : '' }}.</span>
      </p>
    } @else {
      <div class="bar">
        <span class="coords">
          <mat-icon>place</mat-icon>
          {{ latitude() }}, {{ longitude() }}
        </span>

        <span class="actions">
          @if (collapsible()) {
            <button matButton (click)="toggle()">
              <mat-icon>{{ open() ? 'expand_less' : 'map' }}</mat-icon>
              {{ open() ? 'Hide map' : 'Show map' }}
            </button>
          }
          <a matButton [href]="externalUrl()" target="_blank" rel="noopener noreferrer">
            <mat-icon>open_in_new</mat-icon>
            Google Maps
          </a>
        </span>
      </div>

      @if (open()) {
        <div class="frame">
          <iframe
            [src]="embedUrl()"
            [title]="'Map of ' + (label() || 'the selected location')"
            loading="lazy"
            referrerpolicy="no-referrer-when-downgrade"
            allowfullscreen
          ></iframe>
        </div>
      }
    }
  `,
  styles: `
    :host { display: block; }

    .bar {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
    }

    .coords {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      color: var(--mat-sys-on-surface-variant);
      font: var(--mat-sys-body-small);
    }
    .coords mat-icon { font-size: 18px; width: 18px; height: 18px; }

    .actions { display: inline-flex; gap: 4px; flex-wrap: wrap; }

    .frame {
      margin-top: 12px;
      border: 1px solid var(--mat-sys-outline-variant);
      border-radius: 12px;
      overflow: hidden;
      background: var(--mat-sys-surface-container-low);
    }

    iframe {
      display: block;
      width: 100%;
      height: var(--map-height, 260px);
      border: 0;
    }

    .none {
      display: flex;
      align-items: center;
      gap: 8px;
      margin: 0;
      color: var(--mat-sys-on-surface-variant);
      font: var(--mat-sys-body-small);
    }
  `,
})
export class LocationMap {
  private readonly sanitizer = inject(DomSanitizer);

  readonly latitude = input<number | null>(null);
  readonly longitude = input<number | null>(null);
  /** Used in the map's accessible title and the "no location" message. */
  readonly label = input<string>('');
  readonly zoom = input<number>(15);
  /** When false the map is shown immediately and cannot be hidden. */
  readonly collapsible = input<boolean>(true);
  /** Only meaningful when `collapsible` is true. */
  readonly startOpen = input<boolean>(false);

  private readonly manualOpen = signal<boolean | null>(null);

  readonly hasLocation = computed(() => {
    const lat = this.latitude();
    const lng = this.longitude();
    return (
      lat !== null &&
      lng !== null &&
      Number.isFinite(lat) &&
      Number.isFinite(lng) &&
      // 0,0 is in the Atlantic — it always means "never captured", not a real address.
      !(lat === 0 && lng === 0)
    );
  });

  protected readonly open = computed(() => {
    if (!this.collapsible()) {
      return true;
    }
    return this.manualOpen() ?? this.startOpen();
  });

  private readonly query = computed(() => `${this.latitude()},${this.longitude()}`);

  protected readonly embedUrl = computed<SafeResourceUrl>(() => {
    const key = environment.googleMapsApiKey;
    const url = key
      ? `https://www.google.com/maps/embed/v1/place?key=${encodeURIComponent(key)}&q=${encodeURIComponent(this.query())}&zoom=${this.zoom()}`
      : `https://maps.google.com/maps?q=${encodeURIComponent(this.query())}&z=${this.zoom()}&hl=en&output=embed`;

    return this.sanitizer.bypassSecurityTrustResourceUrl(url);
  });

  /** Plain link — always works, key or not, and gives directions and Street View. */
  protected readonly externalUrl = computed(
    () => `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(this.query())}`,
  );

  protected toggle(): void {
    this.manualOpen.set(!this.open());
  }
}
