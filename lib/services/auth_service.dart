import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:uni_app/services/api_service.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  AuthService() {
    _dio.options.baseUrl = const String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'http://localhost:8000/',
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          _logger.d("Requesting: ${options.method} ${options.path}");

          await _addAuthorizationHeader(options);
          return handler.next(options);
        },
        onError: (error, handler) async {
          // 인증 오류 발생 시
          _logger.e("Error on request: ${error.response?.statusCode}");
          _logger.d("Error : ${error.response}");

          if (error.response?.statusCode == 401) {
            final errorData = error.response?.data;

            _logger.d(errorData['code']);

            if (errorData != null && errorData['code'] == 'token_not_valid') {
              final tokenClass = errorData['messages'][0]['token_class'];

              // accessToken 만료시 갱신 처리
              if (tokenClass == 'AccessToken') {
                final success = await _handleTokenRefresh();

                if (success) {
                  // 토큰 갱신 성공시 요청 재시도
                  final retryResponse =
                      await _retryRequest(error.requestOptions);
                  return handler.resolve(retryResponse);
                }
              }
            }
          }
          // 기타 에러
          _logger.e("기타 Error: $error");
          return handler.reject(error);
        },
        // onError: (error, handler) async {
        //   // 인증 오류 발생 시
        //   _logger.e("Error on request: ${error.response?.statusCode}");
        //   _logger.d("Error1 : ${error.response}");

        //   if (error.response?.statusCode == 401 && !_isRefreshing) {
        //     final errorData = error.response?.data;
        //     _logger.d("Error2 : ${error.response}");

        //     if (errorData != null && errorData['error'] != null) {
        //       final errorType = errorData['error'];
        //       _logger.d("Error3 : $errorType");

        //       // 비밀번호 오류 시 재시도 하지 않음
        //       if (errorType == 'invalid_credentials') {
        //         _logger.d('Authentication failed: Invalid credentials.');
        //         return handler.reject(error);
        //       }

        //       // 토큰 만료 시 처리
        //       if (errorType == 'token_expired') {
        //         final success = await _handleTokenRefresh();

        //         if (success) {
        //           // 토큰 갱신 성공시 요청 재시도
        //           final retryResponse =
        //               await _retryRequest(error.requestOptions);
        //           return handler.resolve(retryResponse);
        //         }
        //       }
        //     }
        //   }
        //   // 기타 에러
        //   _logger.e("기타 Error: $error");
        //   return handler.reject(error);
        // },
      ),
    );
  }

  Future<void> _addAuthorizationHeader(RequestOptions options) async {
    try {
      // 기기에 저장된 accessToken 로드
      final token = await _secureStorage.read(key: 'accessToken');

      // 토큰이 있으면, 매 요청마다 헤더에 accessToken 포함
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      _logger.d("Authorization header: ${options.headers['Authorization']}");
    } catch (e) {
      _logger.e("Failed to read accessToken: $e");
    }
  }

  Future<bool> _handleTokenRefresh() async {
    try {
      _logger.i('Refreshing token...');

      // 기기에 저장된 refreshToken 로드
      final refreshToken = await _secureStorage.read(key: 'refreshToken');

      // 토큰이 있으면, 이를 이용해서 accessToken을 다시 받아온다.
      if (refreshToken != null) {
        final response = await _dio.post(
          'api/token/refresh/',
          data: {'refresh': refreshToken},
        );

        final newAccessToken = response.data['access'];
        final newRefreshToken = response.data['refresh'];

        await _secureStorage.write(key: 'accessToken', value: newAccessToken);
        await _secureStorage.write(key: 'refreshToken', value: newRefreshToken);
        _logger.i("Tokens refreshed successfully.");
        return true;
      }
    } catch (e) {
      _logger.e("Failed to refresh token: $e");
      await _clearTokens(); // 실패 시 토큰 제거
    }
    return false;
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    _logger.i("Retrying request: ${requestOptions.path}");
    return _dio.request(
      requestOptions.path,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
      data: requestOptions.data,
    );
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
    _logger.w("Tokens cleared from secure storage.");
  }

  Dio get dio => _dio;
}
