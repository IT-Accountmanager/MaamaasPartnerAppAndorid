import 'package:flutter/material.dart';

import '../../CateringModels/CompanyScheduleItem_model.dart';
import '../../Catering_authservices/Auth_Services.dart';

class CompanyHistoryScreen extends StatefulWidget {
  final String companyName;

  const CompanyHistoryScreen({super.key, required this.companyName});

  @override
  State<CompanyHistoryScreen> createState() => _CompanyHistoryScreenState();
}

class _CompanyHistoryScreenState extends State<CompanyHistoryScreen> {
  List<MonthlyScheduleSummary> _monthlySummaries = [];
  bool _isLoading = true;
  String? _errorMessage;

  // For filtering/sorting
  int _selectedYear = DateTime.now().year;
  List<int> _availableYears = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final schedule = await ApiService.fetchCompanySchedule(
        widget.companyName,
      );

      if (schedule != null && schedule.isNotEmpty) {
        final summaries = ApiService.groupScheduleByMonth(schedule);

        // Get available years from the data
        final years = summaries.map((s) => s.year).toSet().toList()..sort();

        setState(() {
          _monthlySummaries = summaries;
          _availableYears = years;
          _selectedYear = years.isNotEmpty ? years.last : DateTime.now().year;
          _isLoading = false;
        });
        print(
          "✅ Found ${summaries.length} months of data across ${years.length} years",
        );
      } else {
        setState(() {
          _errorMessage = 'No schedule found for this company';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Get summaries for selected year
  List<MonthlyScheduleSummary> get _filteredSummaries {
    return _monthlySummaries.where((s) => s.year == _selectedYear).toList()
      ..sort((a, b) {
        // Sort by month number (January = 1, December = 12)
        int monthA = _getMonthNumber(a.month);
        int monthB = _getMonthNumber(b.month);
        return monthA.compareTo(monthB);
      });
  }

  int _getMonthNumber(String monthName) {
    const months = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };
    return months[monthName] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.companyName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text('Schedule History', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchSchedule,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _monthlySummaries.isEmpty
          ? const Center(child: Text('No schedule data available'))
          : Column(
              children: [
                // Year Selector
                if (_availableYears.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.white,
                    child: Row(
                      children: [
                        const Text(
                          'Select Year: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: DropdownButton<int>(
                            value: _selectedYear,
                            isExpanded: true,
                            items: _availableYears.map((year) {
                              return DropdownMenuItem<int>(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedYear = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                // Months List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredSummaries.length,
                    itemBuilder: (context, index) {
                      final summary = _filteredSummaries[index];
                      return _buildMonthCard(summary);
                    },
                  ),
                ),

                // Summary Footer
                if (_filteredSummaries.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: _buildYearlySummary(),
                  ),
              ],
            ),
    );
  }

  Widget _buildYearlySummary() {
    int totalDays = 0;
    int totalVeg = 0;
    int totalNonVeg = 0;
    double totalAmount = 0;

    for (var summary in _filteredSummaries) {
      totalDays += summary.totalDays;
      totalVeg += summary.totalVegMeals;
      totalNonVeg += summary.totalNonVegMeals;
      totalAmount += summary.totalAmount;
    }

    return Column(
      children: [
        const Text(
          'Yearly Summary',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryChip(
              'Total Days',
              '$totalDays',
              Icons.calendar_today,
              Colors.blue,
            ),
            _buildSummaryChip(
              'Total Meals',
              '${totalVeg + totalNonVeg}',
              Icons.fastfood,
              Colors.orange,
            ),
            _buildSummaryChip(
              'Total Amount',
              '₹${totalAmount.toStringAsFixed(0)}',
              Icons.currency_rupee,
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryChip(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 8, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCard(MonthlyScheduleSummary summary) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.calendar_month, color: Colors.blue[700], size: 24),
        ),
        title: Text(
          '${summary.month} ${summary.year}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${summary.totalDays} days • ${summary.totalVegMeals + summary.totalNonVegMeals} total meals',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        children: [
          // Month Summary Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      'Total Meals',
                      '${summary.totalVegMeals + summary.totalNonVegMeals}',
                      Icons.fastfood,
                      Colors.orange,
                    ),
                    _buildStatColumn(
                      'Veg',
                      '${summary.totalVegMeals}',
                      Icons.eco,
                      Colors.green,
                    ),
                    _buildStatColumn(
                      'Non-Veg',
                      '${summary.totalNonVegMeals}',
                      Icons.restaurant,
                      Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Amount and Status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          Text(
                            '₹${summary.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatusChip(
                            'Pending',
                            summary.pendingCount,
                            Colors.orange,
                          ),
                          _buildStatusChip(
                            'Completed',
                            summary.completedCount,
                            Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Daily Details Button
                TextButton.icon(
                  onPressed: () {
                    _showDailyDetails(summary.items);
                  },
                  icon: const Icon(Icons.list_alt, size: 16),
                  label: const Text('View Daily Details'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  void _showDailyDetails(List<ScheduleItem> items) {
    // Sort items by date
    items.sort((a, b) => a.serviceDate.compareTo(b.serviceDate));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Daily Schedule Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildDailyItemCard(item);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDailyItemCard(ScheduleItem item) {
    // Parse date for display
    String displayDate = '';
    String dayName = '';
    try {
      DateTime date = DateTime.parse(item.serviceDate);
      displayDate = '${date.day} ${_getMonthName(date.month)} ${date.year}';

      // Get day name
      switch (date.weekday) {
        case 1:
          dayName = 'Monday';
          break;
        case 2:
          dayName = 'Tuesday';
          break;
        case 3:
          dayName = 'Wednesday';
          break;
        case 4:
          dayName = 'Thursday';
          break;
        case 5:
          dayName = 'Friday';
          break;
        case 6:
          dayName = 'Saturday';
          break;
        case 7:
          dayName = 'Sunday';
          break;
      }
    } catch (e) {
      displayDate = item.serviceDate;
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: item.status == 'PENDING'
                        ? Colors.orange[50]
                        : Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayDate.split(' ')[0],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: item.status == 'PENDING'
                                ? Colors.orange[700]
                                : Colors.green[700],
                          ),
                        ),
                        Text(
                          dayName.substring(0, 3),
                          style: TextStyle(
                            fontSize: 8,
                            color: item.status == 'PENDING'
                                ? Colors.orange[700]
                                : Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayDate,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Veg: ${item.vegCount} • Non-Veg: ${item.nonVegCount}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      Text(
                        'User ID: ${item.userId}',
                        style: TextStyle(fontSize: 9, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.status == 'PENDING'
                        ? Colors.orange[50]
                        : Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: item.status == 'PENDING'
                          ? Colors.orange[700]
                          : Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount:', style: TextStyle(fontSize: 11)),
                  Text(
                    '₹${item.dailyAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
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

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
}
