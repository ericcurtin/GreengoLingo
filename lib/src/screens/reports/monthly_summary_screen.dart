import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../theme/colors.dart';
import '../../providers/statistics_provider.dart';

/// Monthly summary report screen
class MonthlySummaryScreen extends ConsumerWidget {
  const MonthlySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(statisticsProvider);
    final recentStats = statsState.recentStats(30);
    final xpTrend = statsState.xpTrend(30);
    final accuracyTrend = statsState.accuracyTrend(30);
    final lifetime = statsState.lifetime;

    // Calculate monthly totals
    final monthlyXp = recentStats.fold<int>(0, (sum, s) => sum + s.xpEarned);
    final monthlyLessons =
        recentStats.fold<int>(0, (sum, s) => sum + s.lessonsCompleted);
    final monthlyQuestions =
        recentStats.fold<int>(0, (sum, s) => sum + s.questionsAnswered);
    final monthlyCorrect =
        recentStats.fold<int>(0, (sum, s) => sum + s.questionsCorrect);
    final monthlyTimeSeconds =
        recentStats.fold<int>(0, (sum, s) => sum + s.timeSpentSeconds);
    final monthlySrsReviews =
        recentStats.fold<int>(0, (sum, s) => sum + s.srsReviews);
    final monthlyWordsLearned =
        recentStats.fold<int>(0, (sum, s) => sum + s.wordsLearned);
    final monthlyAccuracy =
        monthlyQuestions > 0 ? (monthlyCorrect / monthlyQuestions) * 100 : 0.0;
    final activeDays = recentStats.length;
    final monthlyTimeHours = monthlyTimeSeconds / 3600;

    // Calculate averages
    final avgXpPerDay = activeDays > 0 ? monthlyXp / activeDays : 0.0;
    final avgLessonsPerDay = activeDays > 0 ? monthlyLessons / activeDays : 0.0;
    final avgTimePerDay =
        activeDays > 0 ? (monthlyTimeSeconds / activeDays) / 60 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Summary'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with month
            _buildMonthHeader(context).animate().fadeIn(),
            const SizedBox(height: 24),

            // Key metrics row
            Row(
              children: [
                Expanded(
                  child: _SummaryStatCard(
                    title: 'Total XP',
                    value: '$monthlyXp',
                    icon: Icons.bolt,
                    color: AppColors.xpGold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryStatCard(
                    title: 'Active Days',
                    value: '$activeDays/30',
                    icon: Icons.calendar_today,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryStatCard(
                    title: 'Study Time',
                    value: '${monthlyTimeHours.toStringAsFixed(1)}h',
                    icon: Icons.timer,
                    color: AppColors.levelC1,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            // XP Trend Chart
            _ChartCard(
              title: 'XP Progress (30 Days)',
              child: SizedBox(
                height: 180,
                child: _MonthlyLineChart(data: xpTrend),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Accuracy Trend Chart
            _ChartCard(
              title: 'Accuracy Trend',
              child: SizedBox(
                height: 180,
                child: _AccuracyLineChart(data: accuracyTrend),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            // Monthly totals
            Text(
              'Monthly Totals',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _DetailCard(
                  title: 'Lessons',
                  value: '$monthlyLessons',
                  subtitle: 'completed',
                  icon: Icons.school,
                  color: AppColors.primaryGreen,
                ),
                _DetailCard(
                  title: 'Questions',
                  value: '$monthlyQuestions',
                  subtitle: 'answered',
                  icon: Icons.quiz,
                  color: AppColors.levelB1,
                ),
                _DetailCard(
                  title: 'Accuracy',
                  value: '${monthlyAccuracy.toStringAsFixed(0)}%',
                  subtitle: '$monthlyCorrect correct',
                  icon: Icons.check_circle,
                  color: AppColors.xpGold,
                ),
                _DetailCard(
                  title: 'SRS Reviews',
                  value: '$monthlySrsReviews',
                  subtitle: 'cards reviewed',
                  icon: Icons.replay,
                  color: AppColors.levelA2,
                ),
                _DetailCard(
                  title: 'New Words',
                  value: '$monthlyWordsLearned',
                  subtitle: 'learned',
                  icon: Icons.translate,
                  color: AppColors.levelB2,
                ),
                _DetailCard(
                  title: 'Best Streak',
                  value: '${lifetime.longestStreak}',
                  subtitle: 'days',
                  icon: Icons.local_fire_department,
                  color: AppColors.streakOrange,
                ),
              ],
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 24),

            // Averages section
            Text(
              'Daily Averages',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _AverageCard(
                    title: 'XP/Day',
                    value: avgXpPerDay.toStringAsFixed(0),
                    color: AppColors.xpGold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AverageCard(
                    title: 'Lessons/Day',
                    value: avgLessonsPerDay.toStringAsFixed(1),
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AverageCard(
                    title: 'Minutes/Day',
                    value: avgTimePerDay.toStringAsFixed(0),
                    color: AppColors.levelC1,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 24),

            // Comparison with lifetime
            _buildLifetimeComparison(
              context,
              monthlyXp: monthlyXp,
              lifetime: lifetime,
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    final now = DateTime.now();
    final monthName = _monthFullName(now.month);
    final year = now.year;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.levelB1,
            AppColors.levelB1.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$monthName $year',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your monthly learning report',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLifetimeComparison(
    BuildContext context, {
    required int monthlyXp,
    required LifetimeStats lifetime,
  }) {
    final percentOfTotal =
        lifetime.totalXp > 0 ? (monthlyXp / lifetime.totalXp) * 100 : 0.0;

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
          Text(
            'Lifetime Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LifetimeStatItem(
                label: 'Total XP',
                value: '${lifetime.totalXp}',
                icon: Icons.bolt,
              ),
              _LifetimeStatItem(
                label: 'Total Lessons',
                value: '${lifetime.totalLessons}',
                icon: Icons.school,
              ),
              _LifetimeStatItem(
                label: 'Total Hours',
                value: lifetime.totalHours.toStringAsFixed(1),
                icon: Icons.timer,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'This month contributed ${percentOfTotal.toStringAsFixed(1)}% of your total XP',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _monthFullName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

class _SummaryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({
    required this.title,
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
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MonthlyLineChart extends StatelessWidget {
  final List<XPTrendPoint> data;

  const _MonthlyLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxY = data.map((p) => p.xp.toDouble()).fold<double>(100, (a, b) => a > b ? a : b);
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
              interval: 6,
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
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
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

class _AccuracyLineChart extends StatelessWidget {
  final List<AccuracyTrendPoint> data;

  const _AccuracyLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final spots = data
        .asMap()
        .entries
        .where((e) => e.value.accuracy > 0)
        .map((e) => FlSpot(e.key.toDouble(), e.value.accuracy))
        .toList();

    if (spots.isEmpty) {
      return const Center(child: Text('No accuracy data'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
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
              interval: 6,
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
            color: AppColors.xpGold,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.xpGold.withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: 100,
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _DetailCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _AverageCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _AverageCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
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
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _LifetimeStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _LifetimeStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
