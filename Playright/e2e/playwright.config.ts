import { defineConfig, devices } from '@playwright/test';
import { config as appConfig } from './helpers/config';

export default defineConfig({
  testDir: '.',
  globalSetup: require.resolve('./global-setup'),
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 2 : undefined,
  reporter: [
    ['list'],
    ['html', { outputFolder: 'reports/html', open: 'never' }],
    ['junit', { outputFile: 'reports/junit/results.xml' }],
  ],
  use: {
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    {
      name: 'api',
      testDir: './api',
      use: { baseURL: appConfig.apiBaseUrl },
    },
    {
      name: 'webapp-chromium',
      testDir: './webapp',
      use: { ...devices['Desktop Chrome'], baseURL: appConfig.webappBaseUrl },
    },
    {
      name: 'webapp-firefox',
      testDir: './webapp',
      grep: /@smoke/,
      use: { ...devices['Desktop Firefox'], baseURL: appConfig.webappBaseUrl },
    },
    {
      name: 'webapp-webkit',
      testDir: './webapp',
      grep: /@smoke/,
      use: { ...devices['Desktop Safari'], baseURL: appConfig.webappBaseUrl },
    },
    {
      name: 'flutter-web',
      testDir: './flutter-web',
      use: { ...devices['Desktop Chrome'], baseURL: appConfig.flutterBaseUrl },
    },
  ],
});
