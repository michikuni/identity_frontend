import 'package:dio/dio.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/core/routes/app_router.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';

class ApiClient {
  ApiClient._();

  static late Dio _dio;
  static bool _initialized = false;

  static Dio get instance {
    assert(_initialized, 'ApiClient.init(baseUrl) must be called before use');
    return _dio;
  }

  // baseUrl bắt buộc — injection.dart truyền vào từ RemoteConfigService
  static void init({required String baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          ApiConstants.contentType: ApiConstants.applicationJson,
        },
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: false,
        responseHeader: false,
      ),
    ]);

    _initialized = true;
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.authHeader] =
          '${ApiConstants.bearerPrefix}$token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      SecureStorage.clearAll().then((_) {
        appRouter?.go('/auth/sign-in');
      });
    }
    handler.next(err);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
            message: 'Connection timeout. Please try again.', statusCode: 408);
      case DioExceptionType.connectionError:
        return const ApiException(
            message: 'No internet connection.', statusCode: 503);
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        final data = error.response?.data;
        String msg;
        if (data is Map) {
          msg = (data['message'] ?? data['error'] ?? _messageForStatus(code)).toString();
        } else if (data is String && data.isNotEmpty && !data.trimLeft().startsWith('<')) {
          msg = data;
        } else {
          msg = _messageForStatus(code);
        }
        return ApiException(message: msg, statusCode: code);
      default:
        return ApiException(
            message: error.message ?? 'Unknown error occurred.',
            statusCode: null);
    }
  }

  @override
  String toString() => message;
}

String _messageForStatus(int? code) {
  switch (code) {
    case 400: return 'Invalid request. Please check your input.';
    case 401: return 'Session expired. Please sign in again.';
    case 403: return 'You do not have permission to perform this action.';
    case 404: return 'The requested resource was not found.';
    case 409: return 'Conflict — this action cannot be completed due to existing data.';
    case 422: return 'Unprocessable request. Please check your input.';
    case 429: return 'Too many requests. Please wait a moment and try again.';
    case 500: return 'Server error. Please try again later.';
    case 502: return 'Service temporarily unavailable. Please try again later.';
    case 503: return 'Service temporarily unavailable. Please try again later.';
    default:  return code != null ? 'Request failed (HTTP $code).' : 'Server error.';
  }
}
