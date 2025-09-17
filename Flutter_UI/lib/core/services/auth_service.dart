import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  static Future<User?> login(String username, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (AppConstants.demoUsers.containsKey(username) &&
        AppConstants.demoUsers[username]!['password'] == password) {
      
      final userInfo = AppConstants.demoUsers[username]!;
      return User(
        username: username,
        role: userInfo['role']!,
        email: userInfo['email']!,
        mobile: userInfo['mobile']!,
      );
    }
    
    return null;
  }

  static Future<bool> register(Map<String, dynamic> userData) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real app, this would save to a database
    return true;
  }

  static Future<bool> sendResetCode(String username) async {
    await Future.delayed(const Duration(seconds: 2));
    return AppConstants.demoUsers.containsKey(username);
  }

  static Future<bool> verifyOTP(String otp, String expectedOtp) async {
    await Future.delayed(const Duration(seconds: 1));
    return otp == expectedOtp;
  }

  static Future<bool> resetPassword(String username, String newPassword) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  //  static Future<void> storeTokens(String token, String? refreshToken) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('auth_token', token);
  //   if (refreshToken != null) {
  //     await prefs.setString('refresh_token', refreshToken);
  //   }
  // }
  
  // static Future<String?> getToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('auth_token');
  // }
  
  // static Future<void> clearTokens() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('auth_token');
  //   await prefs.remove('refresh_token');
  // }
}
