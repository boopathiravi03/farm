import 'package:flutter/material.dart';

import '../services/offline_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int pendingSync = 0;

  @override
  void initState() {
    super.initState();
    loadSyncStatus();
  }

  Future<void> loadSyncStatus() async {
    final count = await OfflineService.getPendingCount();

    if (!mounted) return;

    setState(() {
      pendingSync = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: loadSyncStatus,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),

              const SizedBox(height: 20),

              const Text(
                'Platform Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              _buildStatistics(),

              const SizedBox(height: 24),

              const Text(
                'AI & Platform Modules',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              _buildModuleGrid(),

              const SizedBox(height: 24),

              const Text(
                'Trading Insights',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              _buildTradingInsights(),

              const SizedBox(height: 24),

              _buildSyncCard(),

              const SizedBox(height: 24),

              _buildAdminActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [Colors.green.shade800, Colors.green.shade500],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.admin_panel_settings, color: Colors.white, size: 42),
          SizedBox(height: 14),
          Text(
            'Farm Trading Admin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Monitor farmers, buyers, crops, AI services and platform activity.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _statCard(
          icon: Icons.people,
          title: 'Farmers',
          value: '1,248',
          subtitle: '+12.4%',
        ),
        _statCard(
          icon: Icons.storefront,
          title: 'Buyers',
          value: '386',
          subtitle: '+8.7%',
        ),
        _statCard(
          icon: Icons.agriculture,
          title: 'Active Crops',
          value: '2,764',
          subtitle: '+15.2%',
        ),
        _statCard(
          icon: Icons.shopping_cart,
          title: 'Trades',
          value: '1,932',
          subtitle: '+18.6%',
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 28),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleGrid() {
    final modules = [
      {
        'icon': Icons.currency_rupee,
        'title': 'Fair Price AI',
        'status': 'Active',
      },
      {'icon': Icons.trending_up, 'title': 'Demand AI', 'status': 'Active'},
      {'icon': Icons.camera_alt, 'title': 'Quality AI', 'status': 'Active'},
      {'icon': Icons.handshake, 'title': 'Buyer Matching', 'status': 'Active'},
      {'icon': Icons.account_tree, 'title': 'Supply Chain', 'status': 'Active'},
      {'icon': Icons.qr_code_2, 'title': 'Crop Passport', 'status': 'Active'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final module = modules[index];

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(module['icon'] as IconData, color: Colors.green, size: 30),
              const SizedBox(height: 7),
              Text(
                module['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '● ${module['status']}',
                style: const TextStyle(color: Colors.green, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTradingInsights() {
    return Column(
      children: [
        _insightCard(
          icon: Icons.trending_up,
          title: 'Top traded crop',
          value: 'Tomato',
          detail: '34% of platform trades',
        ),
        const SizedBox(height: 10),
        _insightCard(
          icon: Icons.location_on,
          title: 'High activity region',
          value: 'Cuddalore',
          detail: '286 active listings',
        ),
        const SizedBox(height: 10),
        _insightCard(
          icon: Icons.account_balance_wallet,
          title: 'Estimated farmer value',
          value: '₹18.6 L',
          detail: 'Current active listings',
        ),
        const SizedBox(height: 10),
        _insightCard(
          icon: Icons.compare_arrows,
          title: 'Price gap detected',
          value: '12.8%',
          detail: 'Estimated average gap',
        ),
      ],
    );
  }

  Widget _insightCard({
    required IconData icon,
    required String title,
    required String value,
    required String detail,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.shade50,
            child: Icon(icon, color: Colors.green),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  detail,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        children: [
          Icon(
            pendingSync == 0 ? Icons.cloud_done : Icons.cloud_upload,
            color: Colors.orange.shade800,
            size: 32,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Offline Sync',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  pendingSync == 0
                      ? 'No pending local records'
                      : '$pendingSync record(s) waiting for sync',
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: loadSyncStatus,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admin Actions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _actionTile(Icons.people, 'Manage Users', 'View farmers and buyers'),
        _actionTile(
          Icons.agriculture,
          'Manage Crop Listings',
          'Review active crop listings',
        ),
        _actionTile(
          Icons.warning_amber,
          'Review Alerts',
          'Check platform alerts',
        ),
        _actionTile(Icons.analytics, 'Analytics', 'View platform performance'),
      ],
    );
  }

  Widget _actionTile(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade50,
          child: Icon(icon, color: Colors.green),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$title module will be connected to the backend in final integration.',
              ),
            ),
          );
        },
      ),
    );
  }
}
