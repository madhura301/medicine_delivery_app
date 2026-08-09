export const environment = {
  production: false,
  /** Pharmaish API root. Run the backend with FileStorage__Provider=Local — see docs/IMPLEMENTATION_PLAN.md §7a. */
  apiBaseUrl: 'http://localhost:5000/api',
  /**
   * Optional. Leave blank to use the keyless Google Maps embed, which needs no billing account.
   * Supplying a Maps Embed API key switches to the officially supported endpoint.
   */
  googleMapsApiKey: '',
  docBaseUrl: 'http://localhost:5000',
};
