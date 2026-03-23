import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kumar_pay/app/router/app_router.dart';
import '../../app/config/storage_keys.dart';
import '../error/error_handler.dart';

class DioClient {
  final Dio dio;
  static bool _isHandlingAuthInvalid = false;

  DioClient._internal(this.dio);

  factory DioClient({String? baseUrl}) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        baseUrl: baseUrl ?? '',
      ),
    );

    void handleAuthInvalid() {
      if (_isHandlingAuthInvalid) {
        return;
      }
      _isHandlingAuthInvalid = true;
      final box = GetStorage();
      box.remove(StorageKeys.token);
      box.remove(StorageKeys.userInfo);
      box.remove(StorageKeys.reward);
      box.remove(StorageKeys.customerServiceLink);
      box.remove(StorageKeys.usdtExchangerate);
      box.remove(StorageKeys.ctTypes);
      box.remove(StorageKeys.newbieDialogShow);

      final navigator = AppRouter.navigatorKey.currentState;
      final context = AppRouter.navigatorKey.currentContext;
      final currentRoute = context != null
          ? ModalRoute.of(context)?.settings.name
          : null;
      if (currentRoute == '/login') {
        _isHandlingAuthInvalid = false;
        return;
      }

      if (navigator == null) {
        _isHandlingAuthInvalid = false;
        return;
      }

      navigator
          .pushNamedAndRemoveUntil('/login', (route) => false)
          .whenComplete(() {
            _isHandlingAuthInvalid = false;
          });
    }

    // 添加拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final box = GetStorage();
          final token = box.read(StorageKeys.token);
          if (token is String && token.isNotEmpty) {
            options.headers['indiatoken'] = token;
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          try {
            final data = response.data;
            if (data is Map<String, dynamic>) {
              final code = data['code'];
              if (code == 403 || code == '403') {
                handleAuthInvalid();
              }
            }
          } catch (_) {}
          handler.next(response);
        },
        onError: (err, handler) {
          // 统一处理 401/403：清理本地 token 并跳转登录页（使用全局导航器）
          if (err.response?.statusCode == 401 ||
              err.response?.statusCode == 403) {
            handleAuthInvalid();
          }
          handler.next(err);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ),
    );

    return DioClient._internal(dio);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
