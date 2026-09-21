import 'package:flutter/material.dart';
import 'screens/add_crop_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/buyer_matching_screen.dart';
import 'screens/crop_passport_screen.dart';
import 'screens/crop_quality_screen.dart';
import 'screens/demand_prediction_screen.dart';
import 'screens/fair_price_screen.dart';
import 'screens/farm_map_screen.dart';
import 'screens/market_price_screen.dart';
import 'screens/my_crops_screen.dart';
import 'screens/negotiation_screen.dart';
import 'screens/price_leakage_screen.dart';
import 'screens/sell_crop_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/bank_details_screen.dart';
import 'screens/supply_chain_screen.dart';
import 'services/auth_service.dart';
import 'services/market_price_service.dart';
import 'services/offline_service.dart';
import 'models/market_price.dart';
import 'widgets/offline_banner.dart';

void main() {
  runApp(const FarmTradingApp());
}

class FarmTradingApp extends StatelessWidget {
  const FarmTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farm Trading',

      routes: {
        '/add-crop': (context) => const AddCropScreen(),
        '/sell-crop': (context) => FutureBuilder<String?>(
          future: AuthService.getToken(),
          builder: (context, snapshot) =>
              SellCropScreen(token: snapshot.data ?? ''),
        ),
        '/profile-details': (context) => FutureBuilder<String?>(
          future: AuthService.getToken(),
          builder: (context, snapshot) =>
              ProfileScreen(token: snapshot.data ?? ''),
        ),
        '/bank-details': (context) => FutureBuilder<String?>(
          future: AuthService.getToken(),
          builder: (context, snapshot) =>
              BankDetailsScreen(token: snapshot.data ?? ''),
        ),
        '/my-crops': (context) => const MyCropsScreen(),
        '/market-prices': (context) => const MarketPriceScreen(),
        '/fair-price': (context) => const FairPriceScreen(),
        '/demand-prediction': (context) => const DemandPredictionScreen(),
        '/buyer-matching': (context) => const BuyerMatchingScreen(),
        '/price-leakage': (context) => const PriceLeakageScreen(),
        '/supply-chain': (context) => const SupplyChainScreen(),
        '/negotiation': (context) => const NegotiationScreen(),
        '/crop-quality': (context) => const CropQualityScreen(),
        '/crop-passport': (context) => const CropPassportScreen(),
        '/farm-map': (context) => const FarmMapScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
      },

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        scaffoldBackgroundColor: const Color(0xFFF6F9F6),
      ),

      home: const SplashScreen(),
    );
  }
}

// ======================================================
// SPLASH SCREEN
// ======================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.agriculture,
                size: 58,
                color: Color(0xFF2E7D32),
              ),
            ),

            const SizedBox(height: 25),

            // APP NAME
            const Text(
              'Farm Trading',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Direct farm-to-market trading',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// ROLE SELECTION
// ======================================================

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Farm Trading',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),

            const Text(
              'Welcome 👋',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Choose how you want to use Farm Trading.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 25),

            roleCard(
              context,
              Icons.agriculture,
              'Farmer',
              'Sell your crops directly to buyers',
            ),

            roleCard(
              context,
              Icons.storefront,
              'Buyer',
              'Buy fresh crops directly from farmers',
            ),

            roleCard(
              context,
              Icons.shopping_cart,
              'Consumer',
              'Explore products and transparent prices',
            ),

            roleCard(
              context,
              Icons.admin_panel_settings,
              'Admin',
              'Monitor platform, users, crops and AI modules',
            ),
          ],
        ),
      ),
    );
  }

  Widget roleCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen(role: title)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(icon, color: const Color(0xFF2E7D32), size: 30),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// LOGIN SCREEN
// ======================================================

class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.role} Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            Text(
              'Hello ${widget.role} 👋',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              'Enter your mobile number to continue.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),

            const SizedBox(height: 35),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  if (phoneController.text.trim().length < 10) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid mobile number'),
                      ),
                    );
                    return;
                  }

                  await AuthService.login(
                    role: widget.role,
                    phone: phoneController.text.trim(),
                  );

                  if (!context.mounted) return;

                  if (widget.role == 'Admin') {
                    Navigator.pushReplacementNamed(context, '/admin-dashboard');
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(role: widget.role),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// HOME SCREEN
// ======================================================

class HomeScreen extends StatefulWidget {
  final String role;

  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(role: widget.role),
      const MarketPriceScreen(),
      const OrdersPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Market',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ======================================================
// DASHBOARD
// ======================================================

class DashboardPage extends StatelessWidget {
  final String role;

  const DashboardPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    // Show farmer dashboard only for Farmer role.
    if (role == 'Farmer') {
      return const FarmerDashboard();
    }

    if (role == 'Admin') {
      return const AdminDashboardScreen();
    }

    return SafeArea(
      child: Center(
        child: Text(
          '$role Dashboard\nComing Soon',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  int pendingSync = 0;

  @override
  void initState() {
    super.initState();
    loadOfflineStatus();
  }

  Future<void> loadOfflineStatus() async {
    final count = await OfflineService.getPendingCount();

    if (!mounted) return;

    setState(() {
      pendingSync = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pendingSync > 0) ...[
              OfflineBanner(pendingItems: pendingSync),
              const SizedBox(height: 16),
            ],
            // ─────────────────────────────
            // HEADER
            // ─────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning 👋',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Farmer',
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 15,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Panruti, Tamil Nadu',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ─────────────────────────────
            // EARNINGS CARD
            // ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'This Month\'s Earnings',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '+12.5%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '₹12,450',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Compared with last month',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ─────────────────────────────
            // STAT CARDS
            // ─────────────────────────────
            Row(
              children: [
                Expanded(
                  child: statCard(
                    icon: Icons.eco,
                    title: 'Active Crops',
                    value: '4',
                    onTap: () {
                      Navigator.pushNamed(context, '/my-crops');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: statCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Orders',
                    value: '3',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ─────────────────────────────
            // SELL MY CROP (MARKET DRIVEN)
            // ─────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F2E7D32),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.sell, color: Color(0xFF167D39), size: 26),
                ),
                title: const Text(
                  'Sell My Crop',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                subtitle: const Text(
                  'Check Chennai market price & list your crop',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF167D39)),
                onTap: () async {
                  final token = await AuthService.getToken() ?? '';
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SellCropScreen(token: token),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // ─────────────────────────────
            // QUICK ACTIONS
            // ─────────────────────────────
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: quickAction(
                    icon: Icons.add_circle,
                    title: 'Add Crop',
                    color: const Color(0xFF2E7D32),
                    onTap: () {
                      Navigator.pushNamed(context, '/add-crop');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: quickAction(
                    icon: Icons.show_chart,
                    title: 'Market Price',
                    color: const Color(0xFF1565C0),
                    onTap: () {
                      Navigator.pushNamed(context, '/market-prices');
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: quickAction(
                    icon: Icons.auto_awesome,
                    title: 'AI Fair Price',
                    color: const Color(0xFF7B1FA2),
                    onTap: () {
                      Navigator.pushNamed(context, '/fair-price');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: quickAction(
                    icon: Icons.auto_graph,
                    title: 'Demand Forecast',
                    color: const Color(0xFF1565C0),
                    onTap: () {
                      Navigator.pushNamed(context, '/demand-prediction');
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: quickAction(
                    icon: Icons.people_alt,
                    title: 'Find Buyers',
                    color: const Color(0xFFE65100),
                    onTap: () {
                      Navigator.pushNamed(context, '/buyer-matching');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: quickAction(
                    icon: Icons.account_tree,
                    title: 'Price Leakage',
                    color: const Color(0xFFD84315),
                    onTap: () {
                      Navigator.pushNamed(context, '/price-leakage');
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: quickAction(
                    icon: Icons.hub_outlined,
                    title: 'Supply Chain',
                    color: const Color(0xFF00897B),
                    onTap: () {
                      Navigator.pushNamed(context, '/supply-chain');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: quickAction(
                    icon: Icons.handshake,
                    title: 'AI Negotiation',
                    color: const Color(0xFF5E35B1),
                    onTap: () {
                      Navigator.pushNamed(context, '/negotiation');
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: quickAction(
                    icon: Icons.camera_alt,
                    title: 'Crop Quality',
                    color: const Color(0xFF2E7D32),
                    onTap: () {
                      Navigator.pushNamed(context, '/crop-quality');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: quickAction(
                    icon: Icons.qr_code_2,
                    title: 'Crop Passport',
                    color: const Color(0xFF00897B),
                    onTap: () {
                      Navigator.pushNamed(context, '/crop-passport');
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: quickAction(
                    icon: Icons.map,
                    title: 'Farm Map',
                    color: const Color(0xFF1976D2),
                    onTap: () {
                      Navigator.pushNamed(context, '/farm-map');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: quickAction(
                    icon: Icons.sync,
                    title: 'Sync Data',
                    color: const Color(0xFFE65100),
                    onTap: () async {
                      final count = await OfflineService.getPendingCount();

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            count == 0
                                ? 'Everything is already synced'
                                : '$count item(s) ready for server sync',
                          ),
                        ),
                      );

                      loadOfflineStatus();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ─────────────────────────────
            // MARKET
            // ─────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Market Today',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/market-prices');
                  },
                  child: const Text('View All'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            FutureBuilder<List<MarketPrice>>(
              future: MarketPriceService.getMarketPrices(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final prices = snapshot.data!.take(3).toList();
                return Column(
                  children: prices.map((item) {
                    final isUp = item.changePercent >= 0;
                    return marketCard(
                      crop: item.commodity,
                      price: '₹${item.modalPrice.toStringAsFixed(0)}/kg',
                      change: '${isUp ? '+' : ''}${item.changePercent}%',
                      isUp: isUp,
                      onTap: () {
                        Navigator.pushNamed(context, '/market-prices');
                      },
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            // ─────────────────────────────
            // ALERT
            // ─────────────────────────────
            const Text(
              'Smart Alerts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECB3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: Color(0xFFF57F17),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tomato demand is increasing',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Demand increased by 18%. '
                          'Check the AI Fair Price before selling.',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
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

  // ─────────────────────────────────────────
  // STAT CARD
  // ─────────────────────────────────────────
  Widget statCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // QUICK ACTION
  // ─────────────────────────────────────────
  Widget quickAction({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 9),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // MARKET CARD
  // ─────────────────────────────────────────
  Widget marketCard({
    required String crop,
    required String price,
    required String change,
    required bool isUp,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.eco, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                crop,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      isUp ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 13,
                      color: isUp ? Colors.green : Colors.red,
                    ),
                    Text(
                      change,
                      style: TextStyle(
                        color: isUp ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// MARKET PAGE
// ======================================================

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Live Market Prices\nComing in Step 5',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ======================================================
// ORDERS PAGE
// ======================================================

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Orders\nComing Soon',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ======================================================
// PROFILE PAGE
// ======================================================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<String?>(
        future: AuthService.getPhone(),
        builder: (context, snapshot) {
          final phone = snapshot.data ?? 'Not available';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'My Profile',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 42,
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(
                          Icons.person,
                          size: 45,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 15),
                      FutureBuilder<String?>(
                        future: AuthService.getRole(),
                        builder: (context, roleSnapshot) {
                          return Text(
                            roleSnapshot.data ?? 'User',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      Text(
                        phone,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                profileOption(Icons.person_outline, 'Edit Profile'),
                profileOption(
                  Icons.person_outline,
                  'Edit Profile',
                  onTap: () async {
                    final token = await AuthService.getToken() ?? '';
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(token: token),
                      ),
                    );
                  },
                ),
                profileOption(
                  Icons.account_balance,
                  'Bank & Payment Details',
                  onTap: () async {
                    final token = await AuthService.getToken() ?? '';
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BankDetailsScreen(token: token),
                      ),
                    );
                  },
                ),
                profileOption(Icons.notifications_outlined, 'Notifications'),
                profileOption(Icons.security_outlined, 'Privacy & Security'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await AuthService.logout();

                      if (!context.mounted) return;

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoleSelectionScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget profileOption(IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E7D32)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
