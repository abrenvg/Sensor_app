import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class FusedAngles {
  final int timeUs;
  final double algo1Deg; // EWMA filtered accel angle
  final double algo2Deg; // complementary fused
  final double rawAccelDeg;

  FusedAngles(this.timeUs, this.algo1Deg, this.algo2Deg, this.rawAccelDeg);
}

/// Computes elevation angle:
/// - Assume phone Y axis is aligned with arm.
/// - Elevation = angle between device Y-axis and gravity vector (from accelerometer).
///   0° when aligned with gravity, 90° when perpendicular.
///
/// Algorithm 1:
/// - theta_acc -> EWMA on the angle.
///
/// Algorithm 2:
/// - Complementary filter:
///   integrate gyro component that changes that angle,
///   then correct using accel angle: theta = a*theta_acc + (1-a)*theta_gyroIntegrated
class SensorFusionService {
  StreamSubscription<AccelerometerEvent>? _accSub;
  StreamSubscription<GyroscopeEvent>? _gyrSub;

  final _controller = StreamController<FusedAngles>.broadcast();

  Stream<FusedAngles> get stream => _controller.stream;

  // Filters
  double ewmaAlpha = 0.20;     // Algo1 smoothing
  double compAlpha = 0.02;     // Algo2 accel weight

  // State
  double? _thetaEwmaDeg;
  double? _thetaFusedDeg;

  int? _lastGyroTimeUs;
  List<double>? _lastGravityNorm; // g normalized in device frame [gx,gy,gz]

  bool get isRunning => _accSub != null || _gyrSub != null;

  Future<void> start() async {
    if (isRunning) return;

    _thetaEwmaDeg = null;
    _thetaFusedDeg = null;
    _lastGyroTimeUs = null;
    _lastGravityNorm = null;

    _accSub = accelerometerEvents.listen(_onAcc);
    _gyrSub = gyroscopeEvents.listen(_onGyro);
  }

  Future<void> stop() async {
    await _accSub?.cancel();
    await _gyrSub?.cancel();
    _accSub = null;
    _gyrSub = null;
  }

  void dispose() {
    _controller.close();
    _accSub?.cancel();
    _gyrSub?.cancel();
  }

  void _onAcc(AccelerometerEvent e) {
    final nowUs = DateTime.now().microsecondsSinceEpoch;

    // Gravity direction ~ accelerometer vector during slow movement
    final ax = e.x, ay = e.y, az = e.z;
    final norm = sqrt(ax * ax + ay * ay + az * az);
    if (norm < 1e-6) return;

    final gx = ax / norm;
    final gy = ay / norm;
    final gz = az / norm;
    _lastGravityNorm = [gx, gy, gz];

    final rawDeg = _angleFromGravityY(gx, gy, gz);

    // Algorithm 1: EWMA on angle
    _thetaEwmaDeg = (_thetaEwmaDeg == null)
        ? rawDeg
        : ewmaAlpha * rawDeg + (1 - ewmaAlpha) * _thetaEwmaDeg!;

    // Algorithm 2: complementary correction step on thetaFused
    _thetaFusedDeg = (_thetaFusedDeg == null)
        ? rawDeg
        : compAlpha * rawDeg + (1 - compAlpha) * _thetaFusedDeg!;

    _controller.add(FusedAngles(nowUs, _thetaEwmaDeg!, _thetaFusedDeg!, rawDeg));
  }

  void _onGyro(GyroscopeEvent e) {
    if (_thetaFusedDeg == null) return; // wait for initial accel angle
    if (_lastGravityNorm == null) return;

    final nowUs = DateTime.now().microsecondsSinceEpoch;
    final lastUs = _lastGyroTimeUs;
    _lastGyroTimeUs = nowUs;

    if (lastUs == null) return;
    final dt = (nowUs - lastUs) / 1e6;
    if (dt <= 0 || dt > 0.2) return; // ignore huge gaps

    // Gyro vector (rad/s) in device frame
    final wx = e.x, wy = e.y, wz = e.z;

    // We want component of angular velocity that changes angle between device Y-axis and gravity.
    // Rotation axis that changes that angle is approximately cross(yAxis, gNorm).
    const yAxis = [0.0, 1.0, 0.0];
    final g = _lastGravityNorm!;

    final axis = _cross(yAxis, g);
    final axisNorm = _norm(axis);
    if (axisNorm < 1e-6) return;

    final axisUnit = [axis[0] / axisNorm, axis[1] / axisNorm, axis[2] / axisNorm];

    final omega = wx * axisUnit[0] + wy * axisUnit[1] + wz * axisUnit[2]; // rad/s along axis
    final omegaDeg = omega * 180.0 / pi; // deg/s

    // Integrate gyro into fused estimate (predict step)
    _thetaFusedDeg = _thetaFusedDeg! + omegaDeg * dt;
  }

  double _angleFromGravityY(double gx, double gy, double gz) {
    // angle = acos( |g · y| ) in degrees, y = [0,1,0] => acos(|gy|)
    final c = gy.abs().clamp(0.0, 1.0);
    return acos(c) * 180.0 / pi;
  }

  List<double> _cross(List<double> a, List<double> b) => [
    a[1] * b[2] - a[2] * b[1],
    a[2] * b[0] - a[0] * b[2],
    a[0] * b[1] - a[1] * b[0],
  ];

  double _norm(List<double> v) => sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
}
