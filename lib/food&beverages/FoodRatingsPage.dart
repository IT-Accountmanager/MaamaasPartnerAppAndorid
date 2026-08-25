import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FoodRatingsPage extends StatefulWidget {
  const FoodRatingsPage({Key? key}) : super(key: key);

  @override
  State<FoodRatingsPage> createState() => _FoodRatingsPageState();
}

class _FoodRatingsPageState extends State<FoodRatingsPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 768;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2A0947), size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Ratings & Reviews',
          style: TextStyle(
            color: Color(0xFF2A0947),
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(30),
                isSelected: [_selectedIndex == 0, _selectedIndex == 1],
                onPressed: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                color: Colors.grey[600],
                selectedColor: Colors.white,
                fillColor: Color(0xFFB15CD6),
                borderColor: Colors.grey[300],
                selectedBorderColor: Color(0xFFB15CD6),
                constraints: BoxConstraints(
                  minHeight: 40,
                  minWidth: isMobile ? 140 : 180,
                ),
                children: [
                  _buildToggleItem('Reviews & Ratings'),
                  _buildToggleItem('Response Management'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 8),
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            RatingsTab(isMobile: isMobile),
            ResponseManagementTab(isMobile: isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

enum ReviewStatus { published, pending, archived }

class Review {
  final int id;
  final String orderId;
  final String date;
  final String product;
  final int rating;
  final String comment;
  final String user;
  final ReviewStatus status;

  Review({
    required this.id,
    required this.orderId,
    required this.date,
    required this.product,
    required this.rating,
    required this.comment,
    required this.user,
    required this.status,
  });
}

class RatingsTab extends StatefulWidget {
  final bool isMobile;

  const RatingsTab({Key? key, required this.isMobile}) : super(key: key);

  @override
  State<RatingsTab> createState() => _RatingsTabState();
}

class _RatingsTabState extends State<RatingsTab> {
  List<int> _selectedReviews = [];
  final List<Review> _reviews = [
    Review(
      id: 1,
      orderId: "Order-99121",
      date: "Oct 12, 2023",
      product: "Paneer Tikka",
      rating: 2,
      comment:
          "I'm disappointed. The quality isn't as expected, especially the spices.",
      user: "Wade Warren",
      status: ReviewStatus.pending,
    ),
    Review(
      id: 2,
      orderId: "Order-99122",
      date: "Oct 13, 2023",
      product: "Butter Chicken",
      rating: 5,
      comment:
          "Absolutely amazing! The taste exceeded all my expectations. Best ever!",
      user: "Emma Wilson",
      status: ReviewStatus.published,
    ),
    Review(
      id: 3,
      orderId: "Order-99123",
      date: "Oct 14, 2023",
      product: "Biryani",
      rating: 4,
      comment:
          "Great dish overall. The spices are fantastic, could be less oily.",
      user: "Michael Chen",
      status: ReviewStatus.published,
    ),
    Review(
      id: 4,
      orderId: "Order-99124",
      date: "Oct 15, 2023",
      product: "Masala Dosa",
      rating: 3,
      comment: "Good but the chutney could be better. Crispiness is decent.",
      user: "Sarah Johnson",
      status: ReviewStatus.archived,
    ),
    Review(
      id: 5,
      orderId: "Order-99125",
      date: "Oct 16, 2023",
      product: "Chole Bhature",
      rating: 5,
      comment: "Love the spices! Perfect for breakfast.",
      user: "David Kim",
      status: ReviewStatus.pending,
    ),
    Review(
      id: 6,
      orderId: "Order-99126",
      date: "Oct 17, 2023",
      product: "Samosa",
      rating: 1,
      comment:
          "Multiple issues with the order. Returning it. Very disappointed.",
      user: "Robert Garcia",
      status: ReviewStatus.pending,
    ),
  ];

  void _toggleReview(int id) {
    setState(() {
      if (_selectedReviews.contains(id)) {
        _selectedReviews.remove(id);
      } else {
        _selectedReviews.add(id);
      }
    });
  }

  void _selectAllReviews() {
    setState(() {
      if (_selectedReviews.length == _reviews.length) {
        _selectedReviews.clear();
      } else {
        _selectedReviews = _reviews.map((review) => review.id).toList();
      }
    });
  }

  Color _getStatusColor(ReviewStatus status) {
    switch (status) {
      case ReviewStatus.published:
        return Color(0xFF10B981);
      case ReviewStatus.pending:
        return Color(0xFFF59E0B);
      case ReviewStatus.archived:
        return Color(0xFF6B7280);
      default:
        return Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = widget.isMobile || screenWidth < 768;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters Bar
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  if (isMobile)
                    Column(
                      children: [
                        _buildFilterRow(),
                        SizedBox(height: 10),
                        _buildRequestButton(),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(child: _buildFilterRow()),
                        SizedBox(width: 10),
                        _buildRequestButton(),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Reviews Grid - Using ListView.builder instead of GridView for better control
            Container(
              constraints: BoxConstraints(minHeight: 400),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : (screenWidth < 1024 ? 2 : 3),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: isMobile
                      ? 1.3
                      : 1.2, // Adjusted aspect ratio
                  mainAxisExtent: isMobile
                      ? 280
                      : 260, // Fixed height for each card
                ),
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  final review = _reviews[index];
                  final isSelected = _selectedReviews.contains(review.id);

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with checkbox and status
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (_) => _toggleReview(review.id),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  SizedBox(width: 6),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFD1FAE5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      review.orderId,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(review.status),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  review.status
                                      .toString()
                                      .split('.')
                                      .last
                                      .capitalize(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Rating and Date
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < review.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Color(0xFFFBBF24),
                                    size: 16,
                                  );
                                }),
                              ),
                              Text(
                                review.date,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),

                        // Product Name
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            review.product,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B82F6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 8),

                        // Comment
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: 54, // 3 lines * 18px line height
                            ),
                            child: Text(
                              review.comment,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF333333),
                                height: 1.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),

                        // User Info
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Color(0xFFB15CD6),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    review.user.substring(0, 1),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  review.user,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF333333),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),

                        // Action Buttons
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 32,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF4CAF50),
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: Text(
                                      review.status == ReviewStatus.pending
                                          ? 'Publish & Respond'
                                          : 'View',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  height: 32,
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Color(0xFFDDDDDD),
                                      ),
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: Text(
                                      'Archive',
                                      style: TextStyle(
                                        color: Color(0xFF666666),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            // Bulk Actions
            if (_selectedReviews.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${_selectedReviews.length} reviews selected',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        SizedBox(width: 15),
                        TextButton(
                          onPressed: _selectAllReviews,
                          child: Text(
                            _selectedReviews.length == _reviews.length
                                ? 'Deselect All'
                                : 'Select All',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Color(0xFFFFFFFF).withOpacity(0.2),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          child: Text(
                            'Publish Selected',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                        SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Color(0xFFFFFFFF).withOpacity(0.2),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          child: Text(
                            'Archive Selected',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          // Mobile layout - vertical stacking
          return Column(
            children: [
              DropdownButtonFormField<String>(
                value: 'All Ratings',
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items:
                    [
                      'All Ratings',
                      '5 Stars',
                      '4 Stars',
                      '3 Stars',
                      '2 Stars',
                      '1 Star',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (_) {},
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: 'All Status',
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: ['All Status', 'Published', 'Pending', 'Archived'].map((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search reviews...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
          );
        } else {
          // Desktop layout - horizontal row with Expanded
          return Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: 'All Ratings',
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items:
                      [
                        'All Ratings',
                        '5 Stars',
                        '4 Stars',
                        '3 Stars',
                        '2 Stars',
                        '1 Star',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (_) {},
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: 'All Status',
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: ['All Status', 'Published', 'Pending', 'Archived'].map(
                    (String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    },
                  ).toList(),
                  onChanged: (_) {},
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search reviews...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildRequestButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFB15CD6),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 18),
          SizedBox(width: 8),
          Text(
            'Request Review',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class ResponseManagementTab extends StatelessWidget {
  final bool isMobile;

  const ResponseManagementTab({Key? key, required this.isMobile})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
            SizedBox(height: 20),
            Text(
              'Response Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Manage your responses to customer reviews here',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFB15CD6),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                'Configure Response Templates',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
