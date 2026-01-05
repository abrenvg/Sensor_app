// import 'package:flutter/material.dart';
// import 'sensor_logger_page.dart';
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: SensorLoggerPage());
//   }
// }
//

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/app_database.dart';
import 'data/measurement_repository.dart';
import 'services/sensor_fusion_service.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/history_viewmodel.dart';
import 'views/home_screen.dart';
import 'views/history_screen.dart';
import 'views/session_detail_screen.dart';
import 'package:bluetooth_app/viewmodels/session_detail_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await AppDatabase.create();
  final repo = MeasurementRepository(db);
  final sensorService = SensorFusionService();

  runApp(MyApp(repo: repo, sensorService: sensorService));
}

class MyApp extends StatelessWidget {
  final MeasurementRepository repo;
  final SensorFusionService sensorService;

  const MyApp({super.key, required this.repo, required this.sensorService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: repo),
        Provider.value(value: sensorService),
        ChangeNotifierProvider(
          create: (ctx) => HomeViewModel(
            repo: ctx.read<MeasurementRepository>(),
            sensors: ctx.read<SensorFusionService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => HistoryViewModel(repo: ctx.read<MeasurementRepository>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shoulder Elevation Logger',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        routes: {
          '/': (_) => const HomeScreen(),
          '/history': (_) => const HistoryScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/session') {
            final sessionId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (ctx) => ChangeNotifierProvider(
                create: (_) => SessionDetailViewModel(
                  repo: ctx.read<MeasurementRepository>(),
                  sessionId: sessionId,
                )..load(),
                child: const SessionDetailScreen(),
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}

