// lib/views/insights/insights_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import '../../providers/task_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 📊 Data fetching from Provider
    final stats = ref.watch(taskProvider.notifier).getCategoryStats();
    final completionRate = ref.watch(taskProvider.notifier).getCompletionRate();
    final totalTasks = ref.watch(taskProvider).length;
    final completedTasks = ref.watch(taskProvider).where((t) => t.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mission Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: totalTasks == 0
          ? _buildEmptyState(context)
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🚀 CARD 1: Overall Efficiency (Delay 0ms)
            _buildAnimatedSection(
              delayMs: 0,
              child: _buildStatCard(
                "Overall Efficiency",
                "${completionRate.toInt()}%",
                completionRate > 70 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 32),

            // 🏆 CARD 2: Badges (Delay 150ms)
            _buildAnimatedSection(
              delayMs: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Your Achievements", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBadge(context, "Task Master", completedTasks >= 5, Colors.amber),
                      _buildBadge(context, "Mood Expert", completedTasks >= 3, Colors.purple),
                      _buildBadge(context, "Early Bird", totalTasks >= 1, Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 🥧 CARD 3: Pie Chart (Delay 300ms)
            _buildAnimatedSection(
              delayMs: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Task Distribution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(enabled: true),
                        sectionsSpace: 4,
                        centerSpaceRadius: 40,
                        sections: stats.entries.map((e) {
                          return PieChartSectionData(
                            value: e.value.toDouble(),
                            title: e.value > 0 ? '${e.value}' : '',
                            radius: 50,
                            color: _getCatColor(e.key),
                            titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLegend(stats),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 📊 CARD 4: Bar Chart (Delay 450ms)
            _buildAnimatedSection(
              delayMs: 450,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Category Volume", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: stats.entries.toList().asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.value.toDouble(),
                                color: _getCatColor(entry.value.key),
                                width: 22,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER COMPONENTS (Now inside the class body) ---

  Widget _buildAnimatedSection({required int delayMs, required Widget child}) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delayMs)),
      builder: (context, snapshot) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: snapshot.connectionState == ConnectionState.done
              ? Tween(begin: 0.0, end: 1.0)
              : Tween(begin: 0.0, end: 0.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, childWidget) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: childWidget),
            );
          },
          child: child,
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.25), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: color, fontSize: 56, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String label, bool isEarned, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(isEarned ? Icons.verified_rounded : Icons.lock_outline_rounded, color: color, size: 32),
        ),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: isEarned ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildLegend(Map<String, int> stats) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: stats.keys.map((cat) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: _getCatColor(cat), borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 8),
          Text(cat, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      )).toList(),
    );
  }

  Color _getCatColor(String name) {
    switch (name) {
      case "Study": return Colors.indigoAccent;
      case "Health": return Colors.greenAccent.shade700;
      case "Work": return Colors.orangeAccent.shade700;
      case "Personal": return Colors.pinkAccent;
      default: return Colors.grey;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network('https://lottie.host/7f72eb50-6a98-4b77-b844-3d9db2f518e3/qJ9zB0CqU9.json', height: 200),
          const SizedBox(height: 16),
          const Text("No data to analyze yet!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}