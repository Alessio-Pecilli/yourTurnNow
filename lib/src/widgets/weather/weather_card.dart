import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:your_turn/l10n/app_localizations.dart';

class WeatherInfo {
  final String description;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String iconCode;

  WeatherInfo({
    required this.description,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;

    return WeatherInfo(
      description: (weather['description'] as String).toLowerCase(),
      temp: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      humidity: (main['humidity'] as num).toInt(),
      windSpeed: (wind['speed'] as num).toDouble(),
      iconCode: weather['icon'] as String,
    );
  }
}

// Provider che recupera il meteo per una città
final weatherProvider = FutureProvider.family<WeatherInfo, String>((ref, city) async {
  if (city.trim().isEmpty) {
    throw const FormatException('Nessuna località specificata.');
  }

  final apiKey = dotenv.env['API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    throw const WeatherFetchException('Chiave API mancante. Controlla il file .env o i GitHub Secrets.');
  }

  final queryParameters = {
    'q': city,
    'appid': apiKey,
    'units': 'metric',
    'lang': 'it',
  };

  final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', queryParameters);

  http.Response res;
  try {
    res = await http.get(uri).timeout(const Duration(seconds: 8));
  } on TimeoutException {
    throw const WeatherFetchException('Timeout: il servizio meteo non ha risposto in tempo.');
  } on SocketException {
    throw const WeatherFetchException('Errore di rete: impossibile contattare il servizio meteo.');
  } on HttpException catch (e) {
    throw WeatherFetchException('Errore HTTP: ${e.message}');
  }

  if (res.statusCode == 200) {
    try {
      final Map<String, dynamic> json = jsonDecode(res.body) as Map<String, dynamic>;
      return WeatherInfo.fromJson(json);
    } catch (e) {
      throw WeatherFetchException('Risposta non valida: $e');
    }
  }

  if (res.statusCode == 401) {
    throw const WeatherFetchException('Chiave API non valida (401).');
  }
  if (res.statusCode == 404) {
    throw WeatherFetchException('Località non trovata (404): "$city".');
  }
  if (res.statusCode == 429) {
    throw const WeatherFetchException('Limite di richieste superato (429).');
  }

  throw WeatherFetchException('Errore dal servizio meteo (codice ${res.statusCode}).');
});

class WeatherFetchException implements Exception {
  final String message;
  const WeatherFetchException(this.message);
  @override
  String toString() => 'WeatherFetchException: $message';
}

// 🔹 CARD COMPLETA (grande)
class WeatherCard extends ConsumerWidget {
  final String city;
  const WeatherCard({super.key, this.city = 'Roma,IT'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherProvider(city));

    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Card(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: state.when(
              data: (w) => _buildData(context, ref, w),
              loading: () => _buildLoading(context),
              error: (err, stack) => _buildError(context, ref, err),
            ),
          ),
        ),
      );
  }

  Widget _buildLoading(BuildContext context) => Row(
        children: [
          const SizedBox(width: 8),
          const CircularProgressIndicator(strokeWidth: 2.5),
          const SizedBox(width: 12),
          Text(AppLocalizations.of(context)!.weather_loading_city.replaceFirst('{city}', city), style: Theme.of(context).textTheme.bodyMedium),
        ],
      );

  Widget _buildError(BuildContext context, WidgetRef ref, Object err) {
    final message = (err is WeatherFetchException) ? err.message : err.toString();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.cloud_off, size: 36, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Impossibile recuperare il meteo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(weatherProvider(city)),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(AppLocalizations.of(context)!.common_retry),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildData(BuildContext context, WidgetRef ref, WeatherInfo w) {
    final tempStr = '${w.temp.toStringAsFixed(1)}°C';
    final feelsStr = 'Sensazione: ${w.feelsLike.toStringAsFixed(1)}°C';
    final iconUrl = 'https://openweathermap.org/img/wn/${w.iconCode}@2x.png';

    return Row(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Image.network(iconUrl, fit: BoxFit.contain),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(city, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${w.description} · $tempStr', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  Text(feelsStr),
                  Text(AppLocalizations.of(context)!.weather_humidity.replaceFirst('{value}', w.humidity.toString())),
                  Text(AppLocalizations.of(context)!.weather_wind.replaceFirst('{value}', w.windSpeed.toString())),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 🔹 VERSIONE COMPATTA (toolbar)
class CompactWeather extends ConsumerWidget {
  final String city;
  const CompactWeather({super.key, this.city = 'Roma,IT'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherProvider(city));
    final displayCity = city.split(',').first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      constraints: const BoxConstraints(minWidth: 96, minHeight: 40),
      child: state.when(
        loading: () => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2.0)),
            const SizedBox(width: 8),
            Text(displayCity, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        error: (err, stack) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(displayCity, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700)),
          ],
        ),
        data: (w) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'https://openweathermap.org/img/wn/${w.iconCode}.png',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 4),
            Text('$displayCity ${w.temp.toStringAsFixed(0)}°',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
