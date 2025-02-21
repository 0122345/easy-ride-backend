import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RideService {
  final Dio _dio;
  final String baseUrl = 'https://easy-ride-backend-xl8m.onrender.com/api';
  static const customerToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjQxZWMyMTFhLWUwMzktNGZhZi05OTFkLTY2N2RlZTA1MGQzNSIsInVzZXJUeXBlIjoiQ1VTVE9NRVIiLCJpYXQiOjE3Mzk1MTc3NzEsImV4cCI6MTc0MjEwOTc3MX0.a3JyMcbOdg1TBAivhVJFO9P8yFt8z_QRpMKEUHPNudw';
  static const driverToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4YWU5ODM3LTFkMGYtNDAyNC1iMzczLWJjYTNjYTY0NzZhZSIsInVzZXJUeXBlIjoiRFJJVkVSIiwiaWF0IjoxNzM5NTE3Nzk5LCJleHAiOjE3NDIxMDk3OTl9.23rYk_ry_e_WIKhwSy4QW496sDJB_5wYe2Q_24iAfDQ';

  RideService() : _dio = Dio() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 5);
    _dio.options.validateStatus = (status) => status! < 500;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getNearbyDrivers(
      double lat, double lon, double radius) async {
    try {
      final response = await _dio.get(
        '/rides/nearby',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'radius': radius,
          'type': 'DRIVER'
        },
      );
      return List<Map<String, dynamic>>.from(response.data['drivers']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getNearbyRides(
      double lat, double lon) async {
    try {
      final response = await _dio.get(
        '/rides/nearby',
        queryParameters: {'lat': lat, 'lon': lon, 'radius': 40, 'type': 'RIDE'},
      );
      return List<Map<String, dynamic>>.from(response.data['rides']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> acceptRide(String rideId, String driverId) async {
    try {
      await _dio.put(
        '/rides/accept',
        data: {
          'rideId': rideId,
          'driverId': driverId,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timed out');
      case DioExceptionType.receiveTimeout:
        return Exception('Server not responding');
      case DioExceptionType.connectionError:
        return Exception('No internet connection');
      default:
        return Exception(
            e.response?.data['message'] ?? 'Network error occurred');
    }
  }
}
