/**
 * Azure PRODUCTION environment - the `pharmaish-api-prod` Container App in resource group
 * ImageStorageRG. Selected by `ng build --configuration azure-prod`.
 *
 * Kept separate from `environment.production.ts`, which still points at the legacy
 * 188.241.187.172 host; repointing that file would silently change what everyone else's
 * "production" build targets.
 */
export const environment = {
  production: true,
  apiBaseUrl: 'https://pharmaish-api-prod.mangodesert-af3f37ba.centralindia.azurecontainerapps.io/api',
  /**
   * Optional. Leave blank to use the keyless Google Maps embed, which needs no billing account.
   * Supplying a Maps Embed API key switches to the officially supported endpoint.
   */
  googleMapsApiKey: '',
  docBaseUrl: 'https://pharmaish-api-prod.mangodesert-af3f37ba.centralindia.azurecontainerapps.io',
};
