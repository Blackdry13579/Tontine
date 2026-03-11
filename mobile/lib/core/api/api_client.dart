import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Singleton pattern (optional, but useful for a centralized client)
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      // Configure for emulator (10.0.2.2) or web/device (localhost/IP)
      // Using kIsWeb or Platform check is ideal here, but default to localhost for now
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    ));

    // Ajout de l'intercepteur
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1. Essayer de récupérer le token Firebase JWT
          // 1. Récupérer le token de la session locale (vrai JWT ou mock)
          String? token = await _storage.read(key: 'jwt_token');
          
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Extraire directement le champ 'data' de l'API standardisée (success, message, data, timestamp)
          if (response.data is Map<String, dynamic>) {
            final data = response.data['data'];
            
            if (data != null) {
               response.data = data; 
            }
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Gestion centralisée des erreurs
          String errorMessage = "Une erreur inattendue s'est produite";
          
          if (e.response != null) {
            final statusCode = e.response?.statusCode;
            final data = e.response?.data;
            
            if (data is Map<String, dynamic> && data['message'] != null) {
              errorMessage = data['message'];
            } else {
              if (statusCode == 401) {
                errorMessage = "Non autorisé. Veuillez vous reconnecter.";
                // TODO: Gérer la déconnexion de l'utilisateur
              } else if (statusCode == 404) {
                errorMessage = "Ressource introuvable.";
              } else if (statusCode == 500) {
                errorMessage = "Erreur interne du serveur.";
              }
            }
          } else if (e.type == DioExceptionType.connectionTimeout) {
            errorMessage = "Délai de connexion dépassé.";
          } else if (e.type == DioExceptionType.connectionError) {
            errorMessage = "Erreur de connexion impossible de joindre le serveur.";
          }
          
          // Propager l'erreur avec un message clair
          return handler.next(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: errorMessage,
            ),
          );
        },
      ),
    );
  }

  // Helper privé pour dev mode
  bool _isDevMode() {
    return kDebugMode;
  }

  Dio get dio => _dio;

  // Helpers pour les requêtes basiques
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) {
    return _dio.delete(path, data: data);
  }
}
