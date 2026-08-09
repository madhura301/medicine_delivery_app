import { Injectable } from '@angular/core';
import { environment } from '../../../environments/environment';

declare global {
  interface Window {
    /** Present only once the Maps JavaScript API script has finished loading. */
    google?: typeof google;
  }
}

/**
 * Loads the Google Maps JavaScript API on demand, once per page.
 *
 * The interactive picker needs the JS API — the keyless iframe embed used by `LocationMap` is
 * opaque, so a click inside it cannot be read back. That means a picker is only possible with an
 * API key; `available` reports whether we have one.
 */
@Injectable({ providedIn: 'root' })
export class GoogleMapsLoader {
  private loading: Promise<boolean> | null = null;

  /** False when no API key is configured — callers should offer manual entry instead. */
  get available(): boolean {
    return !!environment.googleMapsApiKey;
  }

  load(): Promise<boolean> {
    if (!this.available) {
      return Promise.resolve(false);
    }

    if (window.google?.maps) {
      return Promise.resolve(true);
    }

    this.loading ??= new Promise<boolean>((resolve) => {
      const existing = document.getElementById('google-maps-js') as HTMLScriptElement | null;
      if (existing) {
        existing.addEventListener('load', () => resolve(!!window.google?.maps));
        existing.addEventListener('error', () => resolve(false));
        return;
      }

      const script = document.createElement('script');
      script.id = 'google-maps-js';
      script.async = true;
      script.defer = true;
      script.src =
        `https://maps.googleapis.com/maps/api/js?key=${encodeURIComponent(environment.googleMapsApiKey)}` +
        `&libraries=marker&loading=async&v=weekly`;
      script.onload = () => resolve(!!window.google?.maps);
      script.onerror = () => {
        // A bad key, a referrer restriction or billing not enabled all land here.
        this.loading = null;
        resolve(false);
      };
      document.head.appendChild(script);
    });

    return this.loading;
  }
}
