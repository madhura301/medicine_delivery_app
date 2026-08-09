import { test, expect } from '@playwright/test';

/**
 * Flutter Web smoke (Phase 4 foundation).
 *
 * The Flutter mobile app (Customer + DeliveryBoy roles — PDF §2) can be served for
 * web E2E with:
 *   cd Flutter_UI && flutter run -d web-server --web-port 8765 --web-hostname localhost
 * and its dev API base pointed at the local backend (lib/config/environment_config.dart
 * _devApiBaseUrl = http://localhost:5000/api).
 *
 * Flutter web renders to a canvas, so DOM/role selectors used for the React app do
 * NOT apply. This smoke asserts the app boots at the DOM level (renderer-agnostic).
 * Deep customer/delivery journeys (create order, OTP-complete) need Flutter semantics
 * enabled (`flutter run ... --dart-define=FLUTTER_WEB_USE_SKIA=false` / semantics tree)
 * and are tracked as the remaining Phase-4 work.
 */

test.describe('Flutter Web — smoke', () => {
  test('app document loads and Flutter bootstrap is present', async ({ page }) => {
    const resp = await page.goto('/', { waitUntil: 'domcontentloaded' });
    expect(resp?.status(), 'root document should serve').toBeLessThan(400);

    // Flutter injects flutter_bootstrap.js / main.dart.js and a <flutter-view> or
    // <flt-glass-pane> host once the engine mounts. Wait for any of them.
    await expect
      .poll(async () =>
        page.evaluate(() =>
          Boolean(
            document.querySelector('flutter-view, flt-glass-pane, flt-scene-host') ||
            [...document.scripts].some((s) => /flutter_bootstrap\.js|main\.dart\.js/.test(s.src)),
          ),
        ),
        { timeout: 60000, message: 'Flutter engine did not mount' },
      )
      .toBeTruthy();
  });
});
