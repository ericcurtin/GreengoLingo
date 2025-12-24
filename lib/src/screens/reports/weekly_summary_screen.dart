import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../theme/colors.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/gamification_provider.dart';

/// Weekly summary report screen
class WeeklySummaryScreen extends ConsumerWidget {
  const WeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(statisticsProvider);
    final recentStats = statsState.recentStats(7);
    final xpTrend = statsState.xpTrend(7);
    final streakInfo = ref.watch(streakInfoProvider);

    // Calculate weekly totals
    final weeklyXp = recentStats.fold<int>(0, (sum, s) => sum + s.xpEarned);
    final weeklyLessons =
        recentStats.fold<int>(0, (sum, s) => sum + s.lessonsCompleted);
    final weeklyQuestions =
        recentStats.fold<int>(0, (sum, s) => sum + s.questionsAnswered);
    final weeklyCorrect =
        recentStats.fold<int>(0, (sum, s) => sum + s.questionsCorrect);
    final weeklyTimeSeconds =
        recentStats.fold<int>(0, (sum, s) => sum + s.timeSpentSeconds);
    final weeklySrsReviews =
        recentStats.fold<int>(0, (sum, s) => sum + s.srsReviews);
    final weeklyWordsLearned =
        recentStats.fold<int>(0, (sum, s) => sum + s.wordsLearned);
    final weeklyAccuracy =
        weeklyQuestions > 0 ? (weeklyCorrect / weeklyQuestions) * 100 : 0.0;
    final activeDays = recentStats.length;
    final weeklyTimeMinutes = weeklyTimeSeconds ~/ 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Summary'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with week range
            _buildWeekHeader(context).animate().fadeIn(),
            const SizedBox(height: 24),

            // Key metrics row
            Row(
              children: [
                Expanded(
                  child: _SummaryStatCard(
                    title: 'XP Earned',
                    value: '$weeklyXp',
                    icon: Icons.bolt,
                    color: AppColors.xpGold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryStatCard(
                    title: 'Active Days',
                    value: '$activeDays/7',
                    icon: Icons.calendar_today,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryStatCard(
                    title: 'Streak',
                    value: '${streakInfo.currentStreak}',
                    icon: Icons.local_fire_department,
                    color: AppColors.streakOrange,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            // XP Trend Chart
            _ChartCard(
              title: 'Daily XP',
              child: SizedBox(
                height: 180,
                child: _WeeklyBarChart(data: xpTrend),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            // Detailed stats grid
            Text(
              'This Week\'s Activity',
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
              childAspectRatio: 1.6,
              children: [
                _DetailCard(
                  title: 'Lessons',
                  value: '$weeklyLessons',
                  subtitle: 'completed',
                  icon: Icons.school,
                  color: AppColors.primaryGreen,
                ),
                _DetailCard(
                  title: 'Questions',
                  value: '$weeklyQuestions',
                  subtitle: 'answered',
                  icon: Icons.quiz,
                  color: AppColors.levelB1,
                ),
                _DetailCard(
                  title: 'Accuracy',
                  value: '${weeklyAccuracy.toStringAsFixed(0)}%',
                  subtitle: '$weeklyCorrect correct',
                  icon: Icons.check_circle,
                  color: AppColors.xpGold,
                ),
                _DetailCard(
                  title: 'Study Time',
                  value: '$weeklyTimeMinutes',
                  subtitle: 'minutes',
                  icon: Icons.timer,
                  color: AppColors.levelC1,
                ),
                _DetailCard(
                  title: 'SRS Reviews',
                  value: '$weeklySrsReviews',
                  subtitle: 'cards reviewed',
                  icon: Icons.replay,
                  color: AppColors.levelA2,
                ),
                _DetailCard(
                  title: 'New Words',
                  value: '$weeklyWordsLearned',
                  subtitle: 'learned',
                  icon: Icons.translate,
                  color: AppColors.levelB2,
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 24),

            // Motivational message
            _buildMotivationalCard(
              context,
              weeklyXp: weeklyXp,
              activeDays: activeDays,
              weeklyAccuracy: weeklyAccuracy,
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekHeader(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final startStr = '${_monthName(weekStart.month)} ${weekStart.day}';
    final endStr = '${_monthName(weekEnd.month)} ${weekEnd.day}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withOpacity(0.7),
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
                'Week of $startStr - $endStr',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your weekly learning report',
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

  Widget _buildMotivationalCard(
    BuildContext context, {
    required int weeklyXp,
    required int activeDays,
    required double weeklyAccuracy,
  }) {
    String message;
    IconData icon;
    Color color;

    if (activeDays >= 5 && weeklyAccuracy >= 80) {
      message = 'Amazing week! You\'re making incredible progress!';
      icon = Icons.emoji_events;
      color = AppColors.xpGold;
    } else if (activeDays >= 3) {
      message = 'Great consistency! Keep up the good work!';
      icon = Icons.thumb_up;
      color = AppColors.primaryGreen;
    } else if (weeklyXp > 0) {
      message = 'Every bit of practice counts. Try to study more often!';
      icon = Icons.lightbulb;
      color = AppColors.levelB1;
    } else {
      message = 'Start your learning journey this week!';
      icon = Icons.rocket_launch;
      color = AppColors.streakOrange;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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

class _WeeklyBarChart extends StatelessWidget {
  final List<XPTrendPoint> data;

  const _WeeklyBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxY = data.map((p) => p.xp.toDouble()).fold<double>(100, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
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
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final date = data[index].date;
                  final parts = date.split('-');
                  final dayNum = int.parse(parts[2]);
                  final monthNum = int.parse(parts[1]);
                  final dateObj = DateTime(2024, monthNum, dayNum);
                  final dayName = _dayName(dateObj.weekday);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dayName,
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
        barGroups: data.asMap().entries.map((e) {
          final hasValue = e.value.xp > 0;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.xp.toDouble(),
                color: hasValue ? AppColors.primaryGreen : Colors.grey.withOpacity(0.3),
                width: 24,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
        maxY: maxY * 1.2,
      ),
    );
  }

  String _dayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
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
