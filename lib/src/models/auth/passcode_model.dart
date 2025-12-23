class PasscodeModel {
  final String passcode;
  final DateTime createdAt;
  final bool isSetup;
  final bool useBiometric;
  final String? biometricType;

  PasscodeModel({
    required this.passcode,
    required this.createdAt,
    this.isSetup = true,
    this.useBiometric = false,
    this.biometricType,
  });

  factory PasscodeModel.fromJson(Map<String, dynamic> json) {
    return PasscodeModel(
      passcode: json['passcode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isSetup: json['isSetup'] as bool? ?? true,
      useBiometric: json['useBiometric'] as bool? ?? false,
      biometricType: json['biometricType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passcode': passcode,
      'createdAt': createdAt.toIso8601String(),
      'isSetup': isSetup,
      'useBiometric': useBiometric,
      'biometricType': biometricType,
    };
  }

  /// Create copy with modified fields
  PasscodeModel copyWith({
    String? passcode,
    DateTime? createdAt,
    bool? isSetup,
    bool? useBiometric,
    String? biometricType,
  }) {
    return PasscodeModel(
      passcode: passcode ?? this.passcode,
      createdAt: createdAt ?? this.createdAt,
      isSetup: isSetup ?? this.isSetup,
      useBiometric: useBiometric ?? this.useBiometric,
      biometricType: biometricType ?? this.biometricType,
    );
  }
}

