// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:sensors_plus/sensors_plus.dart';
//
//
//
// class SensorLoggerPage extends StatefulWidget {
//   const SensorLoggerPage({super.key});
//
//   @override
//   State<SensorLoggerPage> createState() => _SensorLoggerPageState();
// }
//
// class _SensorLoggerPageState extends State<SensorLoggerPage> {
//   StreamSubscription<UserAccelerometerEvent>? _accSub;
//   StreamSubscription<GyroscopeEvent>? _gyrSub;
//
//   bool _isLogging = false;
//
//   // Latest values (for UI)
//   UserAccelerometerEvent? _acc;
//   GyroscopeEvent? _gyr;
//
//   // Simple in-memory log (you can write to file later)
//   final List<String> _logLines = [];
//
//   void _startLogging() {
//     if (_isLogging) return;
//
//     _logLines.clear();
//
//     _accSub = userAccelerometerEvents.listen((e) {
//       _acc = e;
//       _logLines.add(
//         "${DateTime.now().toIso8601String()},ACC,${e.x.toStringAsFixed(4)},${e.y.toStringAsFixed(4)},${e.z.toStringAsFixed(4)}",
//       );
//       if (mounted) setState(() {});
//     });
//
//     _gyrSub = gyroscopeEvents.listen((e) {
//       _gyr = e;
//       _logLines.add(
//         "${DateTime.now().toIso8601String()},GYR,${e.x.toStringAsFixed(4)},${e.y.toStringAsFixed(4)},${e.z.toStringAsFixed(4)}",
//       );
//       if (mounted) setState(() {});
//     });
//
//     setState(() => _isLogging = true);
//   }
//
//   Future<void> _stopLogging() async {
//     if (!_isLogging) return;
//
//     await _accSub?.cancel();
//     await _gyrSub?.cancel();
//     _accSub = null;
//     _gyrSub = null;
//
//     setState(() => _isLogging = false);
//
//     // For now just print to console:
//     debugPrint("Logged ${_logLines.length} lines");
//     // You can export to CSV/file later.
//   }
//
//   @override
//   void dispose() {
//     _accSub?.cancel();
//     _gyrSub?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final accText = _acc == null
//         ? "ACC: -"
//         : "ACC: x=${_acc!.x.toStringAsFixed(3)}  y=${_acc!.y.toStringAsFixed(3)}  z=${_acc!.z.toStringAsFixed(3)}";
//
//     final gyrText = _gyr == null
//         ? "GYR: -"
//         : "GYR: x=${_gyr!.x.toStringAsFixed(3)}  y=${_gyr!.y.toStringAsFixed(3)}  z=${_gyr!.z.toStringAsFixed(3)}";
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Sensor Logger (sensors_plus)")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(accText, style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 8),
//             Text(gyrText, style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 ElevatedButton(
//                   onPressed: _isLogging ? null : _startLogging,
//                   child: const Text("Start Logging"),
//                 ),
//                 const SizedBox(width: 12),
//                 ElevatedButton(
//                   onPressed: _isLogging ? _stopLogging : null,
//                   child: const Text("Stop Logging"),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text("Lines logged: ${_logLines.length}"),
//             const SizedBox(height: 8),
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: ListView.builder(
//                   itemCount: _logLines.length.clamp(0, 200), // show last 200
//                   itemBuilder: (_, i) {
//                     // show the most recent lines at bottom
//                     final idx = (_logLines.length - 1) - i;
//                     if (idx < 0) return const SizedBox.shrink();
//                     return Text(_logLines[idx], style: const TextStyle(fontSize: 12));
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
