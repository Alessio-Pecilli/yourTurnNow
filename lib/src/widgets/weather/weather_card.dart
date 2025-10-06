import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const _openWeatherApiKey = '007d7ec7890c74e0c8884df8ec410e11';

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

// Provider that fetches weather for a given city string (e.g. "Roma,IT" or "London,UK")
final weatherProvider = FutureProvider.family<WeatherInfo, String>((ref, city) async {
  if (city.trim().isEmpty) {
    throw const FormatException('Nessuna località specificata.');
  }

  final queryParameters = {
    'q': city,
    'appid': _openWeatherApiKey,
    'units': 'metric',
    'lang': 'it',
  };

  final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', queryParameters);

  http.Response res;
  try {
    res = await http.get(uri).timeout(const Duration(seconds: 8));
  } on TimeoutException catch (_) {
    // timeout della richiesta
    throw const WeatherFetchException('Timeout: il servizio meteo non ha risposto in tempo. Riprova.');
  } on SocketException catch (_) {
    // errori di connettività (DNS, no network, ecc.)
    throw const WeatherFetchException('Errore di rete: impossibile contattare il servizio meteo. Controlla la connessione internet.');
  } on HttpException catch (e) {
    throw WeatherFetchException('Errore HTTP: ${e.message}');
  }

  if (res.statusCode == 200) {
    try {
      final Map<String, dynamic> json = jsonDecode(res.body) as Map<String, dynamic>;
      return WeatherInfo.fromJson(json);
    } catch (e) {
      throw WeatherFetchException('Risposta non valida dal servizio meteo: $e');
    }
  }

  // Try to produce helpful error messages based on status code
  if (res.statusCode == 401) {
    throw const WeatherFetchException('Chiave API non valida (401). Controlla la API key configurata.');
  }

  if (res.statusCode == 404) {
    throw WeatherFetchException('Località non trovata (404). Controlla il nome della città: "$city".');
  }

  if (res.statusCode == 429) {
    throw const WeatherFetchException('Limite di richieste superato (429). Riprova più tardi.');
  }

  // fallback: include body for debugging
  String bodyPreview;
  try {
    bodyPreview = res.body;
  } catch (_) {
    bodyPreview = '<impossibile leggere body>'; 
  }
  throw WeatherFetchException('Errore dal servizio meteo (codice ${res.statusCode}). Risposta: $bodyPreview');
});

class WeatherFetchException implements Exception {
  final String message;
  const WeatherFetchException(this.message);
  @override
  String toString() => 'WeatherFetchException: $message';
}

class WeatherCard extends ConsumerWidget {
  final String city;
  const WeatherCard({super.key, this.city = 'Roma,IT'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherProvider(city));

    return SliverToBoxAdapter(
      child: Padding(
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
      ),
    );
  }

  Widget _buildLoading(BuildContext context) => Row(
    children: [
      const SizedBox(width: 8),
      const CircularProgressIndicator(strokeWidth: 2.5),
      const SizedBox(width: 12),
      Text('Caricamento meteo per $city...', style: Theme.of(context).textTheme.bodyMedium),
    ],
  );

  Widget _buildError(BuildContext context, WidgetRef ref, Object err) {
    final message = (err is WeatherFetchException)
        ? err.message
        : err.toString();

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
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => ref.refresh(weatherProvider(city)),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Riprova'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      // Fornisce suggerimenti utili: aprire documentazione o cambiare città
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Suggerimenti'),
                          content: const Text('Verifica: 1) connessione internet; 2) nome città corretto (es: "Roma,IT"); 3) API key valida su OpenWeatherMap.\nSe il problema persiste, controlla il log per dettagli.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Chiudi')),
                          ],
                        ),
                      );
                    },
                    child: const Text('Suggerimenti'),
                  ),
                ],
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
        // Icona meteo
        SizedBox(
          width: 72,
          height: 72,
          child: Image.network(
            iconUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.wb_sunny, size: 48, color: Colors.orangeAccent),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      city,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.refresh(weatherProvider(city)),
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Aggiorna meteo',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${w.description[0].toUpperCase()}${w.description.substring(1)} · $tempStr',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _smallInfo(context, Icons.thermostat_outlined, feelsStr),
                  _smallInfo(context, Icons.opacity, 'Umidità: ${w.humidity}%'),
                  _smallInfo(context, Icons.air, 'Vento: ${w.windSpeed} m/s'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _smallInfo(BuildContext context, IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade700),
        const SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade800)),
      ],
    ),
  );
}

/// Compact inline version suitable for toolbar/filter row.
class CompactWeather extends ConsumerWidget {
  final String city;
  const CompactWeather({super.key, this.city = 'Roma,IT'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherProvider(city));
    // short city name for display (e.g. 'Roma' from 'Roma,IT')
    final displayCity = city.split(',').first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
      ),
      constraints: const BoxConstraints(minWidth: 96),
      child: state.when(
        loading: () => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2.0)),
            const SizedBox(width: 8),
            Text(displayCity, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        error: (err, stack) => GestureDetector(
          onTap: () => ref.refresh(weatherProvider(city)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(displayCity, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700)),
            ],
          ),
        ),
        data: (w) => GestureDetector(
          onTap: () => ref.refresh(weatherProvider(city)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // small icon
              Image.network(
                'https://openweathermap.org/img/wn/${w.iconCode}.png',
                width: 22,
                height: 22,
                errorBuilder: (_, __, ___) => const Icon(Icons.wb_sunny, size: 18, color: Colors.orangeAccent),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayCity,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${w.description[0].toUpperCase()}${w.description.substring(1)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    '${w.temp.toStringAsFixed(0)}°',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
