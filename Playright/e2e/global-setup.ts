import { waitForApi, seed } from './helpers/seed';

/** Runs once before all projects: wait for the API, then seed roles/permissions/users. */
export default async function globalSetup(): Promise<void> {
  await waitForApi();
  await seed();
}
