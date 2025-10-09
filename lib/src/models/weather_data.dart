/// Modello dati per le informazioni meteorologiche
class WeatherData {
  final String cityName;
  final double temperature;
  final String description;
  final String weatherCode;
  final int humidity;
  final double windSpeed;
  final DateTime updatedAt;

  const WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeed,
    required this.updatedAt,
  });

  /// Factory per creare WeatherData dalla risposta dell'API OpenWeatherMap
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'] as String,
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      weatherCode: json['weather'][0]['main'] as String,
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      updatedAt: DateTime.now(),
    );
  }

  /// Restituisce la temperatura formattata (senza simboli speciali)
  String get temperatureFormatted => '${temperature.round()} gradi';

  /// Descrizione capitalizzata
  String get descriptionCapitalized {
    return description.split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : word)
        .join(' ');
  }

  @override
  String toString() {
    return 'WeatherData(city: $cityName, temp: $temperatureFormatted, '
           'description: $description, code: $weatherCode)';
  }
}