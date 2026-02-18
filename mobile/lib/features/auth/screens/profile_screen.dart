import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../shop/screens/order_history_screen.dart';
import '../../shop/screens/wishlist_screen.dart';
import '../../shop/screens/address_management_screen.dart';
import '../../vendor/screens/vendor_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: user?.userMetadata?['avatar_url'] != null
                        ? NetworkImage(user!.userMetadata!['avatar_url'] as String)
                        : null,
                    child: user?.userMetadata?['avatar_url'] == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.userMetadata?['full_name'] ?? 'Guest User',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? '',
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Menu Items
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('SHOPPING', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
            _buildMenuItem(context, icon: Icons.shopping_bag, title: 'My Orders', color: Colors.blue, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
            }),
            _buildMenuItem(context, icon: Icons.favorite, title: 'Wishlist', color: Colors.blue, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
            }),
            _buildMenuItem(context, icon: Icons.location_on, title: 'Delivery Addresses', color: Colors.blue, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressManagementScreen()));
            }),
            
            _buildMenuItem(context, icon: Icons.store, title: 'Vendor Dashboard', color: Colors.blue, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorDashboardScreen()));
            }),
            const Divider(height: 32),
             const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('SETTINGS', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
            _buildMenuItem(context, icon: Icons.notifications, title: 'Notifications', color: Colors.grey.shade200, iconColor: Colors.black, onTap: () {}),
            _buildMenuItem(context, icon: Icons.security, title: 'Security', color: Colors.grey.shade200, iconColor: Colors.black, onTap: () {}),
            _buildMenuItem(context, icon: Icons.help, title: 'Help & Support', color: Colors.grey.shade200, iconColor: Colors.black, onTap: () {}),

            const SizedBox(height: 32),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await AuthService().signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required Color color, Color iconColor = Colors.white, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
