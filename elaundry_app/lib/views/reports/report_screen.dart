import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/themes/theme.dart';
import '../../shared/laundry_navigation_fab.dart';
import '../catalog/widgets/icon_section_card.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // 0: Today, 1: Weekly, 2: Monthly
  int _selectedTimeframe = 2;

  // Mock metric dynamic data depending on timeframe
  int get _totalOrders =>
      _selectedTimeframe == 0 ? 14 : (_selectedTimeframe == 1 ? 48 : 67);
  double get _netSales =>
      _selectedTimeframe == 0
          ? 4250.00
          : (_selectedTimeframe == 1 ? 14890.00 : 20052.00);
  double get _grossSales =>
      _selectedTimeframe == 0
          ? 5100.00
          : (_selectedTimeframe == 1 ? 18320.00 : 25670.00);

  // Breakdown percentages
  double get _cashPct => _selectedTimeframe == 0 ? 60 : 67;
  double get _cashlessPct => 100 - _cashPct;

  // Category counts
  double get _servicesCount =>
      _selectedTimeframe == 0 ? 18 : (_selectedTimeframe == 1 ? 45 : 72);
  double get _addonsCount =>
      _selectedTimeframe == 0 ? 8 : (_selectedTimeframe == 1 ? 22 : 30);
  double get _othersCount =>
      _selectedTimeframe == 0 ? 12 : (_selectedTimeframe == 1 ? 34 : 54);

  String _selectedDonutMetric = 'Payment Method';

  final List<Map<String, dynamic>> _employeeStats = [
    {'name': 'Juan D.', 'pct': 45.0, 'color': const Color(0xFF005B52)},
    {'name': 'Maria S.', 'pct': 35.0, 'color': const Color(0xFF388E83)},
    {'name': 'John D.', 'pct': 20.0, 'color': const Color(0xFF7FA8A2)},
  ];

  @override
  Widget build(BuildContext context) {
    final pageBgColor = AppColors.neutral[400];

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        title: Text(
          'Analytics & Report',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary[900],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const LaundryNavigationFab(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- TIMEFRAME SELECTOR PILL ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.neutral[500]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTimeframeBtn(label: 'Today', index: 0),
                          _buildTimeframeBtn(label: 'Weekly', index: 1),
                          _buildTimeframeBtn(label: 'Monthly', index: 2),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // --- TOP SUMMARY KPI STATS ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total Orders Large Card
                      Expanded(
                        flex: 5,
                        child: Container(
                          height: 140,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary[600],
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$_totalOrders',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Total Orders',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Net & Gross Sales Side Cards
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            _buildSalesCard(
                              label: 'Net Sales',
                              amount: _netSales,
                              icon: Icons.payments_outlined,
                            ),
                            const SizedBox(height: 10),
                            _buildSalesCard(
                              label: 'Gross Sales',
                              amount: _grossSales,
                              icon: Icons.receipt_long_outlined,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- PAYMENT METHOD / EMPLOYEE PERFORMANCE DONUT CARD ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    _selectedDonutMetric == 'Payment Method'
                                        ? Icons.pie_chart_outline_rounded
                                        : Icons.badge_outlined,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedDonutMetric == 'Payment Method'
                                      ? 'PAYMENT METHOD'
                                      : 'EMPLOYEE PERFORMANCE',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF454746),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),

                            // Minimal Toggle Button with Down Arrow Indicator
                            Tooltip(
                              message:
                                  _selectedDonutMetric == 'Payment Method'
                                      ? 'Switch to Employee Performance'
                                      : 'Switch to Payment Method',
                              child: Material(
                                color: AppColors.neutral[200],
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    setState(() {
                                      _selectedDonutMetric =
                                          _selectedDonutMetric ==
                                                  'Payment Method'
                                              ? 'Employee Performance'
                                              : 'Payment Method';
                                    });
                                  },
                                  child: Container(
                                    height: 32,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.neutral[400]!,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _selectedDonutMetric ==
                                                  'Payment Method'
                                              ? Icons.credit_card_rounded
                                              : Icons.groups_outlined,
                                          color: AppColors.secondary[700],
                                          size: 17,
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.secondary[700],
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 160,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    PieChart(
                                      PieChartData(
                                        sectionsSpace: 3,
                                        centerSpaceRadius: 40,
                                        startDegreeOffset: 270,
                                        sections:
                                            _selectedDonutMetric ==
                                                    'Payment Method'
                                                ? [
                                                  PieChartSectionData(
                                                    value: _cashPct,
                                                    title:
                                                        '${_cashPct.toInt()}%',
                                                    color:
                                                        AppColors.primary[600]!,
                                                    radius: 30,
                                                    titleStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  PieChartSectionData(
                                                    value: _cashlessPct,
                                                    title:
                                                        '${_cashlessPct.toInt()}%',
                                                    color: const Color(
                                                      0xFF7FA8A2,
                                                    ),
                                                    radius: 30,
                                                    titleStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ]
                                                : _employeeStats.map((emp) {
                                                  return PieChartSectionData(
                                                    value: emp['pct'] as double,
                                                    title:
                                                        '${(emp['pct'] as double).toInt()}%',
                                                    color:
                                                        emp['color'] as Color,
                                                    radius: 30,
                                                    titleStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  );
                                                }).toList(),
                                      ),
                                    ),
                                    Icon(
                                      _selectedDonutMetric == 'Payment Method'
                                          ? Icons.credit_card_rounded
                                          : Icons.groups_rounded,
                                      color: const Color(0xFF555B5A),
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      _selectedDonutMetric == 'Payment Method'
                                          ? [
                                            _buildLegendItem(
                                              color: AppColors.primary[600]!,
                                              label: 'Cash',
                                              pct: '${_cashPct.toInt()}%',
                                            ),
                                            const SizedBox(height: 12),
                                            _buildLegendItem(
                                              color: const Color(0xFF7FA8A2),
                                              label: 'Cashless',
                                              pct: '${_cashlessPct.toInt()}%',
                                            ),
                                          ]
                                          : _employeeStats.map((emp) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              child: _buildLegendItem(
                                                color: emp['color'] as Color,
                                                label: emp['name'] as String,
                                                pct:
                                                    '${(emp['pct'] as double).toInt()}%',
                                              ),
                                            );
                                          }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- CATEGORY DISTRIBUTION BAR CHART ---
                  IconSectionCard(
                    icon: Icons.bar_chart_rounded,
                    title: 'CATEGORY DISTRIBUTION',
                    children: [
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 100,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 25,
                              getDrawingHorizontalLine:
                                  (value) => FlLine(
                                    color: AppColors.neutral[400]!,
                                    strokeWidth: 0.8,
                                  ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  interval: 25,
                                  getTitlesWidget:
                                      (val, meta) => Text(
                                        val.toInt().toString(),
                                        style: TextStyle(
                                          color: AppColors.secondary[400],
                                          fontSize: 10,
                                        ),
                                      ),
                                ),
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
                                  getTitlesWidget: (val, meta) {
                                    String text = '';
                                    if (val.toInt() == 0) text = 'Services';
                                    if (val.toInt() == 1) text = 'Add-ons';
                                    if (val.toInt() == 2) text = 'Others';
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        text,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.secondary[600],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              _buildBar(
                                0,
                                _servicesCount,
                                AppColors.primary[600]!,
                              ),
                              _buildBar(
                                1,
                                _addonsCount,
                                const Color(0xFF2C7D75),
                              ),
                              _buildBar(
                                2,
                                _othersCount,
                                const Color(0xFF7FA8A2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframeBtn({required String label, required int index}) {
    final isSelected = _selectedTimeframe == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeframe = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.secondary[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesCard({
    required String label,
    required double amount,
    required IconData icon,
  }) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral[500]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: AppColors.primary[700], size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '₱${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C2D2D),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: AppColors.secondary[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String pct,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C2D2D),
          ),
        ),
        const Spacer(),
        Text(
          pct,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary[600],
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBar(int x, double val, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: val,
          color: color,
          width: 28,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: AppColors.neutral[300]!.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
