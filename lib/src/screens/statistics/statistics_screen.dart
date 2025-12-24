import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../theme/colors.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../services/haptic_service.dart';
import '../reports/weekly_summary_screen.dart';
import '../reports/monthly_summary_screen.dart';

/// Statistics dashboard screen
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  bool _showWeekly = true; // Toggle between 7 and 30 days

  @override
  Widget build(BuildContext context) {
    final statsState = ref.watch(statisticsProvider);
    final lifetime = statsState.lifetime;
    final xpInfo = ref.watch(xpInfoProvider);
    final streakInfo = ref.watch(streakInfoProvider);

    return Scaffold(
      primary: false,
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header stats
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total XP',
                    value: '${lifetime.totalXp}',
                    icon: Icons.bolt,
                    color: AppColors.xpGold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Streak',
                    value: '${streakInfo.currentStreak}',
                    icon: Icons.local_fire_department,
                    color: AppColors.streakOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Level',
                    value: '${xpInfo.currentLevel}',
                    icon: Icons.star,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ).animate().fadeIn().slideY(begin: -0.1),

            const SizedBox(height: 24),

            // XP Trend Chart
            _ChartCard(
              title: 'XP Trend',
              trailing: _PeriodToggle(
                isWeekly: _showWeekly,
                onChanged: (value) => setState(() => _showWeekly = value),
              ),
              child: SizedBox(
                height: 200,
                child: _XPLineChart(
                  data: _showWeekly
                      ? statsState.xpTrend(7)
                      : statsState.xpTrend(30),
                ),
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Accuracy by Question Type
            _ChartCard(
              title: 'Accuracy by Question Type',
              child: SizedBox(
                height: 200,
                child: _AccuracyPieChart(
                  data: lifetime.accuracyByType,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Lifetime stats grid
            Text(
              'Lifetime Stats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _DetailStatCard(
                  title: 'Lessons',
                  value: '${lifetime.totalLessons}',
                  icon: Icons.school,
                  color: AppColors.primaryGreen,
                ),
                _DetailStatCard(
                  title: 'Words Learned',
                  value: '${lifetime.totalWords}',
                  icon: Icons.translate,
                  color: AppColors.levelB1,
                ),
                _DetailStatCard(
                  title: 'Study Time',
                  value: '${lifetime.totalHours.toStringAsFixed(1)}h',
                  icon: Icons.timer,
                  color: AppColors.levelC1,
                ),
                _DetailStatCard(
                  title: 'Accuracy',
                  value: '${lifetime.accuracy.toStringAsFixed(0)}%',
                  icon: Icons.check_circle,
                  color: AppColors.xpGold,
                ),
                _DetailStatCard(
                  title: 'Days Active',
                  value: '${lifetime.daysActive}',
                  icon: Icons.calendar_today,
                  color: AppColors.streakOrange,
                ),
                _DetailStatCard(
                  title: 'SRS Reviews',
                  value: '${lifetime.totalSrsReviews}',
                  icon: Icons.replay,
                  color: AppColors.levelA2,
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 24),

            // Reports section
            Text(
              'Reports',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ReportCard(
                    title: 'Weekly',
                    subtitle: 'Last 7 days',
                    icon: Icons.calendar_view_week,
                    color: AppColors.primaryGreen,
                    onTap: () {
                      HapticService.instance.lightTap();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const WeeklySummaryScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ReportCard(
                    title: 'Monthly',
                    subtitle: 'Last 30 days',
                    icon: Icons.calendar_month,
                    color: AppColors.levelB1,
                    onTap: () {
                      HapticService.instance.lightTap();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MonthlySummaryScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const _ChartCard({
    required this.title,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final bool isWeekly;
  final ValueChanged<bool> onChanged;

  const _PeriodToggle({
    required this.isWeekly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            label: '7D',
            selected: isWeekly,
            onTap: () => onChanged(true),
          ),
          _ToggleButton(
            label: '30D',
            selected: !isWeekly,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _DetailStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DetailStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _XPLineChart extends StatelessWidget {
  final List<XPTrendPoint> data;

  const _XPLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final maxY = data.map((p) => p.xp.toDouble()).reduce((a, b) => a > b ? a : b);
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.xp.toDouble()))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: data.length > 7 ? (data.length / 5).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final date = data[index].date;
                  final day = date.split('-').last;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      day,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primaryGreen,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: data.length <= 7,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.primaryGreen,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryGreen.withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: maxY > 0 ? maxY * 1.1 : 100,
      ),
    );
  }
}

class _AccuracyPieChart extends StatelessWidget {
  final Map<String, QuestionTypeStats> data;

  const _AccuracyPieChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final colors = [
      AppColors.primaryGreen,
      AppColors.levelB1,
      AppColors.streakOrange,
      AppColors.levelC1,
    ];

    final sections = data.entries.toList().asMap().entries.map((e) {
      final index = e.key;
      final entry = e.value;
      final accuracy = entry.value.accuracy;

      return PieChartSectionData(
        value: accuracy > 0 ? accuracy : 1,
        title: '${accuracy.toStringAsFixed(0)}%',
        color: colors[index % colors.length],
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.entries.toList().asMap().entries.map((e) {
            final index = e.key;
            final entry = e.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatQuestionType(entry.key),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatQuestionType(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Multiple Choice';
      case 'typing':
        return 'Typing';
      case 'matching_pairs':
        return 'Matching';
      case 'sentence_builder':
        return 'Sentence';
      default:
        return type.replaceAll('_', ' ');
    }
  }
}
