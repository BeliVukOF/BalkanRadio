class RadioStation {
  const RadioStation({
    required this.name,
    required this.streamUrl,
    required this.region,
  });

  final String name;
  final String streamUrl;
  final String region;

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      name: json['name'] as String? ?? '',
      streamUrl: json['streamUrl'] as String? ?? '',
      region: json['region'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'streamUrl': streamUrl,
        'region': region,
      };

  // Two entries with the same stream are the same station, whatever their label.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RadioStation && streamUrl == other.streamUrl;

  @override
  int get hashCode => streamUrl.hashCode;
}
