import 'package:clean_riverpod_starter/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_service.g.dart';

class ApiService {
  const ApiService(this._dio);

  final Dio _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
    );
    return response.data;
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final response = await _dio.post<dynamic>(path, data: body);
    return response.data;
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final response = await _dio.patch<dynamic>(path, data: body);
    return response.data;
  }

  Future<void> delete(String path) async {
    await _dio.delete<void>(path);
  }

  Future<dynamic> postMultipart(String path, FormData data) async {
    final response = await _dio.post<dynamic>(path, data: data);
    return response.data;
  }
}

@Riverpod(keepAlive: true)
ApiService apiService(Ref ref) => ApiService(ref.watch(dioProvider));
