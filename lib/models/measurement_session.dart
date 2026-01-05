class MeasurementSession {
  final int? id;
  final int startTimeUs;
  final int endTimeUs;

  MeasurementSession({
    this.id,
    required this.startTimeUs,
    required this.endTimeUs,
  });

  int get durationMs => ((endTimeUs - startTimeUs) / 1000).round();

  DateTime get startTime => DateTime.fromMicrosecondsSinceEpoch(startTimeUs);
  DateTime get endTime => DateTime.fromMicrosecondsSinceEpoch(endTimeUs);

  Map<String, Object?> toMap() => {
    'id': id,
    'start_time_us': startTimeUs,
    'end_time_us': endTimeUs,
  };

  static MeasurementSession fromMap(Map<String, Object?> map) => MeasurementSession(
    id: map['id'] as int,
    startTimeUs: map['start_time_us'] as int,
    endTimeUs: map['end_time_us'] as int,
  );
}
