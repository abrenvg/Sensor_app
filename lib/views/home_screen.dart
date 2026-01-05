import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/home_viewmodel.dart';
import '../widgets/angle_chart.dart';
import '../viewmodels/history_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shoulder Elevation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () async {
              await context.read<HistoryViewModel>().load();
              // ignore: use_build_context_synchronously
              Navigator.pushNamed(context, '/history');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Live angles", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text("Algorithm 1 (EWMA accel): ${vm.lastAlgo1.toStringAsFixed(2)}°"),
            Text("Algorithm 2 (Fused):         ${vm.lastAlgo2.toStringAsFixed(2)}°"),
            const SizedBox(height: 12),

            // Filter tuning
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Filters"),
                    const SizedBox(height: 8),
                    Text("EWMA α = ${vm.ewmaAlpha.toStringAsFixed(2)}"),
                    Slider(
                      min: 0.01,
                      max: 1.0,
                      value: vm.ewmaAlpha,
                      onChanged: (v) => context.read<HomeViewModel>().setEwmaAlpha(v),
                    ),
                    Text("Complementary α (accel weight) = ${vm.compAlpha.toStringAsFixed(2)}"),
                    Slider(
                      min: 0.001,
                      max: 0.20,
                      value: vm.compAlpha,
                      onChanged: (v) => context.read<HomeViewModel>().setCompAlpha(v),
                    ),
                    const Text("Tip: keep complementary α small (e.g. 0.01–0.05) to reduce gyro drift but still follow motion."),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start"),
                  onPressed: vm.isRecording ? null : () => context.read<HomeViewModel>().start(),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text("Stop"),
                  onPressed: vm.isRecording ? () => context.read<HomeViewModel>().stop() : null,
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Export CSV"),
                  onPressed: vm.points.isEmpty ? null : () => context.read<HomeViewModel>().exportCurrentCsv(),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AngleChart.live(livePoints: vm.points),
                ),
              ),
            ),

            if (!vm.isRecording && vm.lastSavedSessionId != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Saved to DB as session #${vm.lastSavedSessionId}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
          ],
        ),
      ),
    );
  }
}
