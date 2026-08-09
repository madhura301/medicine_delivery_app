/**
 * Azure test environment — the `pharmaish-api-test` Container App in resource group
 * ImageStorageRG. Selected by `ng build --configuration test`.
 */
export const environment = {
  production: true,
  apiBaseUrl: 'https://pharmaish-api-test.mangodesert-af3f37ba.centralindia.azurecontainerapps.io/api',
  /**
   * Optional. Leave blank to use the keyless Google Maps embed, which needs no billing account.
   * Supplying a Maps Embed API key switches to the officially supported endpoint.
   */
  googleMapsApiKey: '',
  docBaseUrl: 'https://pharmaish-api-test.mangodesert-af3f37ba.centralindia.azurecontainerapps.io',
};
