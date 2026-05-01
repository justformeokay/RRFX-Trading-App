class ActivityLog {
  final String device;
  final String activity;
  final String description;
  final String ipAddress;
  final String createdAt;

  ActivityLog({
    required this.device,
    required this.activity,
    required this.description,
    required this.ipAddress,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      device: json['device'] ?? 'Unknown',
      activity: json['activity'] ?? 'General',
      description: json['description'] ?? '',
      ipAddress: json['ip_address'] ?? '0.0.0.0',
      createdAt: json['created_at'] ?? '',
    );
  }
}