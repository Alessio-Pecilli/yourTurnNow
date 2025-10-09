import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

/// Servizio per ottenere dati meteorologici tramite OpenWeatherMap API
class WeatherService {
  // API Key pubblica di OpenWeatherMap (sostituire con la propria)
  // Questa è una key demo - per produzione usare una key personale
  static const String _apiKey = '007d7ec7890c74e0c8884df8ec410e11';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // Coordinate di Roma
  static const double _romaLatitude = 41.9028;
  static const double _romaLongitude = 12.4964;

  /// Ottiene il meteo attuale per Roma
  /// 
  /// Restituisce [WeatherData] con le informazioni attuali
  /// Lancia [WeatherException] in caso di errori
  static Future<WeatherData> getCurrentWeatherForRoma() async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$_romaLatitude&lon=$_romaLongitude'
        '&appid=$_apiKey&units=metric&lang=it'
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw WeatherException('Timeout della richiesta meteo');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw WeatherException('API Key non valida');
      } else if (response.statusCode == 404) {
        throw WeatherException('Città non trovata');
      } else if (response.statusCode == 429) {
        throw WeatherException('Troppi richieste. Riprova più tardi');
      } else {
        throw WeatherException(
          'Errore server: ${response.statusCode} - ${response.reasonPhrase}'
        );
      }
    } on http.ClientException catch (e) {
      throw WeatherException('Errore di connessione: ${e.message}');
    } on FormatException catch (e) {
      throw WeatherException('Errore nel formato dei dati: ${e.message}');
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw WeatherException('Errore imprevisto: ${e.toString()}');
    }
  }

  /// Verifica se il servizio è disponibile
  /// 
  /// Utile per test di connettività
  static Future<bool> isServiceAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?q=Rome&appid=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Eccezione personalizzata per errori del servizio meteo
class WeatherException implements Exception {
  final String message;
  const WeatherException(this.message);

  @override
  String toString() => 'WeatherException: $message';
}