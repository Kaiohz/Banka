import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:banka/src/sqlite/banka_database.dart';
import 'package:banka/src/sqlite/model/transaction.dart';
import 'package:intl/intl.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late Future<List<BankaTransaction>> _billsFuture;
  late Future<List<BankaTransaction>> _expensesFuture;
  String _timelineGranularity = 'Days';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    _billsFuture = BankaDatabase.instance.transactions(type: 'Bills');
    _expensesFuture = BankaDatabase.instance.transactions(type: 'Expenses');
  }

  List<PieChartSectionData> _getSections(List<BankaTransaction> transactions) {
    // Grouper les transactions par catégorie
    Map<String, double> categoryTotals = {};
    for (var transaction in transactions) {
      categoryTotals[transaction.category] = (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    // Convertir en sections de graphique
    List<PieChartSectionData> sections = [];
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];

    int colorIndex = 0;
    categoryTotals.forEach((category, amount) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: amount,
          title: '$category\n${amount.toStringAsFixed(2)}€',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return sections;
  }

  List<FlSpot> _getLineSpots(List<BankaTransaction> transactions) {
    transactions.sort((a, b) => a.paymentDate.compareTo(b.paymentDate));
    
    if (_timelineGranularity == 'Days') {
      return _getDailySpots(transactions);
    } else {
      return _getMonthlySpots(transactions);
    }
  }

  List<FlSpot> _getDailySpots(List<BankaTransaction> transactions) {
    Map<int, double> dailyTotals = {};
    
    for (var transaction in transactions) {
      final date = DateTime.fromMillisecondsSinceEpoch(transaction.paymentDate * 1000);
      final day = date.day;
      dailyTotals[day] = (dailyTotals[day] ?? 0) + transaction.amount;
    }

    return dailyTotals.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  List<FlSpot> _getMonthlySpots(List<BankaTransaction> transactions) {
    Map<int, double> monthlyTotals = {};
    
    for (var transaction in transactions) {
      final date = DateTime.fromMillisecondsSinceEpoch(transaction.paymentDate * 1000);
      final month = date.month;
      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + transaction.amount;
    }

    return monthlyTotals.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  Widget _buildLineChart(Future<List<BankaTransaction>> transactionsFuture) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('View by: '),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Days', label: Text('Days')),
                ButtonSegment(value: 'Months', label: Text('Months')),
              ],
              selected: {_timelineGranularity},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _timelineGranularity = newSelection.first;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: FutureBuilder<List<BankaTransaction>>(
            future: transactionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No data available'));
              }

              final spots = _getLineSpots(snapshot.data!);
              
              return LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _timelineGranularity == 'Days' ? 5 : 1,
                        getTitlesWidget: (value, meta) {
                          if (_timelineGranularity == 'Months') {
                            return Text(DateFormat('MMM').format(
                              DateTime(2024, value.toInt())
                            ));
                          }
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 100,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}€');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(String title, Future<List<BankaTransaction>> transactionsFuture) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 300,
          child: FutureBuilder<List<BankaTransaction>>(
            future: transactionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No data available'));
              }

              return PieChart(
                PieChartData(
                  sections: _getSections(snapshot.data!),
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildPieChart('Bills Distribution', _billsFuture),
              const SizedBox(height: 32),
              _buildPieChart('Expenses Distribution', _expensesFuture),
              const SizedBox(height: 32),
              const Text(
                'Expenses Timeline',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildLineChart(_expensesFuture),
            ],
          ),
        ),
      ),
    );
  }
}