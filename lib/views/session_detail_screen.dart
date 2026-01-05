import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/session_detail_viewmodel.dart';
import '../widgets/angle_chart.dart';
import '../viewmodels/home_viewmodel.dart';

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SessionDetailViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Session #${vm.sessionId}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: vm.samples.isEmpty
                ? null
                : () => context.read<HomeViewModel>().exportSessionCsv(vm.sessionId),
          ),
        ],
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vm.session != null) ...[
              Text("Start: ${vm.session!.startTime.toLocal()}"),
              Text("End:   ${vm.session!.endTime.toLocal()}"),
              Text("Samples: ${vm.samples.length}"),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AngleChart.saved(dbSamples: vm.samples),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Graph shows: Line 1 = Algo1 (EWMA accel), Line 2 = Algo2 (fused)"),
          ],
        ),
      ),
    );
  }
}
