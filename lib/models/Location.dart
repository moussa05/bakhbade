class Location {
  final int id;
  final String name;
  final String order;
  final String valuation;
  final String longitude;
  final String latitude;
  final String timeMin;
  final String timeMax;

  Location({
    required this.id,
    required this.name,
    required this.order,
    required this.valuation,
    required this.longitude,
    required this.latitude,
    required this.timeMin,
    required this.timeMax,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      order: json['order'],
      valuation: json['valuation'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      timeMin: json['time_min'],
      timeMax: json['time_max'],
    );
  }
  @override
  String toString() {
    return 'Location{id: $id, name: $name, order: $order, valuation: $valuation, longitude: $longitude, latitude: $latitude, timeMin: $timeMin, timeMax: $timeMax}';
  }
}
