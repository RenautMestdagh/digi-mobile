class UsageData {
  final String type;
  final String limit;
  final String used;
  final bool progressBar;
  final double percentage;

  UsageData({
    required this.type,
    required this.limit,
    required this.used,
    this.progressBar = false,
    this.percentage = 0.0,
  });

  factory UsageData.fromJson(Map<String, dynamic> json) {
    return UsageData(
      type: json['type'] ?? '',
      limit: json['limit'] ?? '',
      used: json['used'] ?? '',
      progressBar: json['progressBar'] ?? false,
      percentage: json['percentage']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'limit': limit,
      'used': used,
      'progressBar': progressBar,
      'percentage': percentage,
    };
  }
}
