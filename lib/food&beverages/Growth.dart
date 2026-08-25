import 'package:flutter/material.dart';
import 'PromotionsDiscounts.dart'; // Make sure this page exists

void main() {
  runApp(
    MaterialApp(home: GrowthBoostersPage(), debugShowCheckedModeBanner: false),
  );
}

class GrowthBoostersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F0FF), // Changed to light purple background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Header - Made more colorful
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF9C27B0), // Purple
                      Color(0xFF673AB7), // Deep Purple
                      Color(0xFF3F51B5), // Indigo
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🚀 GROWTH BOOSTERS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.rocket_launch,
                            color: Colors.yellow,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      '✨ Partner-friendly solutions to skyrocket your sales!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.yellow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: Color(0xFFFFEB3B),
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.monetization_on,
                            color: Color(0xFFFF9800),
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.brown.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.coffee,
                            color: Color(0xFF795548),
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),

              // Options Cards - Made more colorful
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildOptionCard(
                      icon: Icons.percent,
                      title: '🎯 RUN DISCOUNTS',
                      subtitle:
                          'Increase orders, improve sales & target specific customers to increase loyalty',
                      iconColor: Colors.redAccent,
                      bgColor: Color(0xFFFFF0F0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PromotionDiscountPage(),
                          ),
                        );
                      },
                    ),
                    _buildOptionCard(
                      icon: Icons.campaign,
                      title: '📢 RUN ADS TO BOOST VISIBILITY',
                      subtitle:
                          'Better visibility on Maamaas, improved sales for you',
                      iconColor: Colors.blueAccent,
                      bgColor: Color(0xFFF0F8FF),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PromotionDiscountPage(),
                          ),
                        );
                      },
                    ),
                    _buildOptionCard(
                      icon: Icons.link,
                      title: '🔗 MAAMAAS SMART LINK',
                      subtitle:
                          'Share your unique brand links on Facebook, Instagram, etc to bring more users to your restaurant page on Maamaas app',
                      iconColor: Colors.greenAccent,
                      bgColor: Color(0xFFF0FFF4),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SmartLinkPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // All benefits section - Made more colorful
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFF8E1), Color(0xFFFFF3E0)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFFF6B35),
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '🌈 ALL BENEFITS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                              fontSize: 18,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      _buildBenefitItem(
                        '🎨 Easily manage your menu and update items instantly',
                        Color(0xFF4CAF50),
                      ),
                      _buildBenefitItem(
                        '📊 Track orders and monitor kitchen performance',
                        Color(0xFF2196F3),
                      ),
                      _buildBenefitItem(
                        '📈 Analyze sales trends to plan promotions and growth',
                        Color(0xFF9C27B0),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }

  // Option Card Widget - Enhanced with colors
  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = Colors.purple,
    Color bgColor = Colors.white,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      color: bgColor,
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Color(0xFFFF5722),
          ),
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // Benefit Item Widget - Enhanced with colors
  Widget _buildBenefitItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.check_circle, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder for SmartLinkPage - Made more colorful
class SmartLinkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🔗 MAAMAAS SMART LINK',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF673AB7),
        elevation: 5,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3E5F5), Color(0xFFE8EAF6)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              '✨ Here you can display your smart link or open external URL. ✨',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.deepPurple[800],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
