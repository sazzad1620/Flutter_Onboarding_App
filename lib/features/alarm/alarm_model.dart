class AlarmModel {
  DateTime time;
  bool isEnabled;

  AlarmModel({required this.time, this.isEnabled = true});

  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'isEnabled': isEnabled,
  };

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      time: DateTime.parse(json['time']),
      isEnabled: json['isEnabled'] ?? true,
    );
  }
}
