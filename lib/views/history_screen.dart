import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/history_viewmodel.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Saved Measurements")),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.sessions.isEmpty
          ? const Center(child: Text("No saved sessions yet"))
          : ListView.separated(
        itemCount: vm.sessions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final s = vm.sessions[i];
          final dur = (s.durationMs / 1000.0).toStringAsFixed(1);
          return ListTile(
            title: Text("Session #${s.id}  •  ${s.startTime.toLocal()}"),
            subtitle: Text("Duration: $dur s"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/session', arguments: s.id);
            },
          );
        },
      ),
    );
  }
}
