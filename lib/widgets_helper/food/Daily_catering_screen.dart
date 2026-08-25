import 'package:flutter/material.dart';
import '../../CateringModels/DailyCatering_model.dart';
import '../../Catering_authservices/Auth_Services.dart';
import 'CompanyHistoryScreen.dart';

class CorporateLunchScreen extends StatefulWidget {
  const CorporateLunchScreen({super.key});

  @override
  State<CorporateLunchScreen> createState() => _CorporateLunchScreenState();
}

class _CorporateLunchScreenState extends State<CorporateLunchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  int _selectedCompanyIndex = -1;

  // State variables - now using CompanySummary
  List<CompanySummary> _companySummaries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchDailyCatering();
  }

  Future<void> _fetchDailyCatering() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use the new method that matches the API response
      final dailyCatering = await ApiService.fetchVendorDailyCatering();

      if (dailyCatering != null && dailyCatering.isNotEmpty) {
        final summaries = ApiService.getCompanySummaries(dailyCatering);
        setState(() {
          _companySummaries = summaries;
          _isLoading = false;
        });
        print("✅ Found ${summaries.length} unique companies");
      } else {
        setState(() {
          _errorMessage = 'No daily catering data found';
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

  void _handleTabSelection() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedFilter = 'All';
          break;
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to get company initial
  String _getCompanyInitial(String companyName) {
    if (companyName.isEmpty) return '?';
    return companyName[0].toUpperCase();
  }

  // Get filtered companies based on selected filter
  List<CompanySummary> get _filteredCompanies {
    return _companySummaries.where((company) {
      if (_selectedFilter == 'All') return true;
      // You can add more filters here if needed
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const double toolbarHeight = 30;
    const double bottomHeight = 60;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        toolbarHeight: toolbarHeight,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Management',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(bottomHeight),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: const [Tab(text: 'All Companies')],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDailyCatering,
        child: _isLoading
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
                      onPressed: _fetchDailyCatering,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _companySummaries.isEmpty
            ? const Center(child: Text('No companies found'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _filteredCompanies.length,
                itemBuilder: (context, index) {
                  final company = _filteredCompanies[index];
                  return _buildCorporateCard(company, index);
                },
              ),
      ),
    );
  }

  Widget _buildCorporateCard(CompanySummary company, int index) {
    final isSelected = _selectedCompanyIndex == index;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: company.orderStatus == 'COMPLETED'
              ? Colors.green
              : Colors.orange,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Company Header
          ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: company.orderStatus == 'COMPLETED'
                    ? Colors.green[50]
                    : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _getCompanyInitial(company.companyName),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: company.orderStatus == 'COMPLETED'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    company.companyName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: company.orderStatus == 'COMPLETED'
                        ? Colors.green
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    company.orderStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '${company.dailyEntries.length} days • ${company.totalVegMeals + company.totalNonVegMeals} meals',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            trailing: IconButton(
              icon: Icon(
                isSelected ? Icons.expand_less : Icons.expand_more,
                color: Colors.orange,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _selectedCompanyIndex = isSelected ? -1 : index;
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),

          const SizedBox(height: 6),

          // Quick Stats
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  '₹${company.total.toStringAsFixed(0)}',
                  Icons.currency_rupee,
                  Colors.orange,
                ),
                _buildStatItem(
                  'Veg',
                  '${company.totalVegMeals}',
                  Icons.eco,
                  Colors.green,
                ),
                _buildStatItem(
                  'Non-Veg',
                  '${company.totalNonVegMeals}',
                  Icons.restaurant,
                  Colors.red,
                ),
                _buildStatItem(
                  'Days',
                  '${company.dailyEntries.length}',
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ],
            ),
          ),

          if (isSelected) ...[
            const Divider(height: 8),

            // Expanded Details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Details
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Company:', company.companyName),
                        _buildDetailRow(
                          'Total Amount:',
                          '₹${company.total.toStringAsFixed(2)}',
                        ),
                        _buildDetailRow('Latest Date:', company.cateringDate),
                        _buildDetailRow(
                          'Total Days:',
                          '${company.dailyEntries.length}',
                        ),
                        _buildDetailRow(
                          'Total Veg Meals:',
                          '${company.totalVegMeals}',
                        ),
                        _buildDetailRow(
                          'Total Non-Veg Meals:',
                          '${company.totalNonVegMeals}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Recent entries preview
                  if (company.dailyEntries.length > 0)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Entries:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...company.dailyEntries
                              .take(3)
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        entry.serviceDate,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'V:${entry.vegCount} NV:${entry.nonVegCount}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '₹${entry.dailyAmount.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          if (company.dailyEntries.length > 3)
                            Text(
                              '+${company.dailyEntries.length - 3} more days',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompanyHistoryScreen(
                                  companyName: company.companyName,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            textStyle: const TextStyle(fontSize: 15),
                          ),
                          child: const Text('View Full History'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 12, color: color),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 8, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
          Text(value, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
