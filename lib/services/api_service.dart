import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:uni_app/services/auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Logger _logger = Logger();
  final Dio _dio = Dio();

  String baseUrl = const String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8000/',
  );

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '${baseUrl}api/token/',
        data: {
          'username': username,
          'password': password,
        },
      );
      final accessToken = response.data['access'];
      final refreshToken = response.data['refresh'];
      await _secureStorage.write(key: 'accessToken', value: accessToken);
      await _secureStorage.write(key: 'refreshToken', value: refreshToken);

      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<bool> validateAutoLogIn() async {
    // isLoggedIn 체크
    if (!await isLoggedIn()) return false;

    // Token 유효성 체크
    final accessToken = await _secureStorage.read(key: 'accessToken');
    final refreshToken = await _secureStorage.read(key: 'refreshToken');

    if (accessToken == null || refreshToken == null) {
      _logger.w("토큰이 없습니다.");
      return false;
    }

    try {
      // refreshToken의 유효성 확인 => 유효하면 accessToken 재발급 가능
      // 따라서, accessToken의 유효성 확인은 불필요함
      // header 추가는 불필요하고, 다른 logic을 방지하기 위해, authService를 이용하지 않음
      final response = await _dio.post(
        '${baseUrl}api/token/verify/',
        data: {'token': refreshToken},
        // options: Options(
        //   extra: {'interceptor': false}, // interceptor 무시 설정
        // ),
      );
      _logger.i("Refresh token is valid.");
      return response.statusCode == 200; // Token 모두 유효
    } catch (e) {
      _logger.w("Token is invalid or expired. Log out...");
      logout();
      return false;
    }
  }

  Future<dynamic> getMe() async {
    try {
      _logger.i("Calling URL: ${baseUrl}api/me/");

      final response = await _authService.dio.get(
        'api/me/',
      );

      return response.data;
    } catch (e) {
      _logger.e("Error: $e");
      return null;
    }
  }

  Future<dynamic> workRecord() async {
    try {
      final response = await _authService.dio.post(
        'api/work/',
        data: {
          'username': '01085253411',
          'work_code': 'A',
        },
      );

      return response.data;
    } catch (e) {
      _logger.e("Error: $e");
      return null;
    }
  }
}
