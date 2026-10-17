import 'package:flutter/material.dart';
import 'package:pharmaish/core/app_routes.dart';
import 'package:pharmaish/core/services/auth_service.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/storage.dart';

/// Outcome of [SessionService.renewSession].
enum SessionRenewal {
  /// A new token was obtained and stored.
  renewed,

  /// Remember Me is off, or the saved credentials were rejected — the user has
  /// to log in again.
  notPossible,

  /// The login call couldn't be completed (offline, timeout, server error).
  /// The session isn't known to be dead, so it must not be ended over this.
  failed,
}

/// Keeps a "Remember Me" session alive and ends it cleanly when it can't be.
///
/// The backend has no refresh endpoint: a Remember Me login is issued a 30-day
/// token, and that token's lifetime is the session's lifetime. Renewing a
/// session therefore means signing in again with the credentials saved by
/// Remember Me, which is what the splash screen has always done on app start.
class SessionService {
  SessionService._();

  /// Lets session handling navigate without a [BuildContext] (e.g. from the
  /// Dio interceptor). Attached to the app's [MaterialApp].
  static final navigatorKey = GlobalKey<NavigatorState>();

  static const sessionExpiredMessage =
      'Your session has expired. Please log in again.';

  static Future<SessionRenewal>? _renewal;
  static DateTime? _lastEnded;

  /// Signs in again with the saved Remember Me credentials and stores the new
  /// token. Concurrent callers share one attempt, so a burst of 401s triggers a
  /// single login call.
  static Future<SessionRenewal> renewSession() {
    return _renewal ??= _renew().whenComplete(() => _renewal = null);
  }

  static Future<SessionRenewal> _renew() async {
    final credentials = await StorageService.loadSavedCredentials();
    final username = credentials['username'] as String;
    final password = credentials['password'] as String;
    if (credentials['rememberPassword'] != true ||
        username.isEmpty ||
        password.isEmpty) {
      return SessionRenewal.notPossible;
    }

    try {
      final response = await AuthService.login(
        mobileNumber: username,
        password: password,
        stayLoggedIn: true,
      ).timeout(const Duration(seconds: 15));

      if (response.success && response.token != null) {
        await storeSession(response);
        AppLogger.info('Session renewed with saved credentials');
        return SessionRenewal.renewed;
      }
      // 400/401 or success=false: the saved credentials no longer work (e.g.
      // the password was changed elsewhere). They're kept, so the login screen
      // can prefill the username, but the user has to sign in themselves.
      if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.isHttpSuccess) {
        AppLogger.warning(
            'Saved credentials rejected (HTTP ${response.statusCode})');
        return SessionRenewal.notPossible;
      }
      AppLogger.warning('Session renewal failed: HTTP ${response.statusCode}');
      return SessionRenewal.failed;
    } catch (e) {
      AppLogger.error('Session renewal failed', e);
      return SessionRenewal.failed;
    }
  }

  /// Stores the token and user details from a successful login response.
  static Future<void> storeSession(AuthResponse response) async {
    final token = response.token!;
    // Renewal only ever uses the Remember Me credentials, so the session is
    // always a persistent one.
    await StorageService.storeAuthTokens(
      token: token,
      refreshToken: response.refreshToken,
      persistent: true,
    );
    final userId = response.userId ?? '';
    if (userId.isNotEmpty) {
      await StorageService.storeUserId(userId);
    }
    final userInfo =
        StorageService.extractUserInfo(StorageService.decodeJwtToken(token));
    if (userInfo.isNotEmpty) {
      await StorageService.storeUserInfo(userInfo);
    }
  }

  /// Ends a session the server no longer accepts: clears the token (but not
  /// the saved Remember Me credentials — that's what logout is for) and returns
  /// to the login screen with [message].
  ///
  /// Several requests can fail at once, and both the Dio interceptor and the
  /// screen that made the request may call this, so repeat calls within a few
  /// seconds are ignored.
  static Future<void> endSession({String message = sessionExpiredMessage}) async {
    final now = DateTime.now();
    if (_lastEnded != null &&
        now.difference(_lastEnded!) < const Duration(seconds: 5)) {
      return;
    }
    _lastEnded = now;

    AppLogger.warning('Session ended: $message');
    try {
      await StorageService.clearAuthTokens();
    } catch (_) {
      // Already logged by StorageService; still send the user to login.
    }
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
      arguments: message,
    );
  }
}
