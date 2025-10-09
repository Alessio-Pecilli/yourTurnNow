import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';

final weatherProvider = FutureProvider<WeatherData>((ref) {
  return WeatherService.getCurrentWeatherForRoma();
});

class WeatherWidget extends ConsumerWidget {
  final bool isCompact;

  const WeatherWidget({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: weatherAsync.when(
          data: (weather) => _buildWeatherInfo(context, weather),
          loading: () => const Text('Caricamento...'),
          error: (error, stack) => const Text('Errore meteo'),
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(BuildContext context, WeatherData weather) {
    // Pulisce TUTTO: emoji, accenti strani, simboli non ASCII
    final safeDescription = _clean(weather.descriptionCapitalized);
    final safeTemp = weather.temperature.round().toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Roma: $safeTemp gradi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Arial',
              ),
        ),
        Text(
          safeDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontFamily: 'Arial',
              ),
        ),
      ],
    );
  }

  String _clean(String text) {
    // Sostituisce caratteri non ASCII e simboli speciali
    String cleaned = text
        .replaceAll(RegExp(r'[^\x00-\x7F]'), ' ') // rimuove non-ASCII
        .replaceAll(RegExp(r'[°℃℉]'), '') // rimuove simboli di temperatura
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // rimuove simboli speciali
        .replaceAll(RegExp(r'\s+'), ' ') // rimuove spazi doppi
        .trim();
    
    return cleaned.isEmpty ? 'Tempo' : cleaned;
  }
}
