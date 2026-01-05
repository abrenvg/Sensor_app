class MeasurementSample {
  final int? id;
  final int sessionId;
  final int timeUs;
  final double angleAlgo1Deg; // EWMA filtered accel angle
  final double angleAlgo2Deg; // complementary fused

  MeasurementSample({
    this.id,
    required this.sessionId,
    required this.timeUs,
    required this.angleAlgo1Deg,
    required this.angleAlgo2Deg,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'session_id': sessionId,
    'time_us': timeUs,
    'angle1_deg': angleAlgo1Deg,
    'angle2_deg': angleAlgo2Deg,
  };

  static MeasurementSample fromMap(Map<String, Object?> map) => MeasurementSample(
    id: map['id'] as int,
    sessionId: map['session_id'] as int,
    timeUs: map['time_us'] as int,
    angleAlgo1Deg: (map['angle1_deg'] as num).toDouble(),
    angleAlgo2Deg: (map['angle2_deg'] as num).toDouble(),
  );
}
