import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/supabase_product_repository.dart';
import '../../../data/repositories/supabase_order_repository.dart';
import 'vendor_orders_screen.dart';
import 'add_edit_product_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  final _productRepository = SupabaseProductRepository();
  final _orderRepository = SupabaseOrderRepository();
  
  List<Product> _vendorProducts = [];
  Map<String, dynamic> _stats = {'total_sales': 0, 'total_orders': 0, 'low_stock_count': 0};
  List<Map<String, dynamic>> _dailySales = [];
  bool _isLoading = true;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final products = await _productRepository.getProducts();
      final stats = await _orderRepository.getVendorStats();
      final sales = await _orderRepository.getDailySales();
      setState(() {
        _vendorProducts = products;
        _stats = stats;
        _dailySales = sales;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Vendor Hub", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildTabs(),
                Expanded(
                  child: _currentTabIndex == 0 ? _buildOverview() : _buildInventory(),
                ),
              ],
            ),
      floatingActionButton: _currentTabIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditProductScreen())),
              label: const Text("Add Product"),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem(0, "Overview"),
          _buildTabItem(1, "Inventory"),
          _buildTabItem(2, "Orders", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorOrdersScreen())).then((_) => _fetchData());
          }),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, {VoidCallback? onTap}) {
    final isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: onTap ?? () => setState(() => _currentTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard("Total Sales", "₦${_stats['total_sales'].toString()}", Icons.trending_up, Colors.green),
          const SizedBox(height: 16),
          _buildStatCard("Total Orders", _stats['total_orders'].toString(), Icons.bar_chart, Colors.blue),
          const SizedBox(height: 16),
          _buildStatCard("Low Stock Alerts", _stats['low_stock_count'].toString(), Icons.warning, Colors.orange),
          const SizedBox(height: 24),
          Text("Sales Performance", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 250,
            padding: const EdgeInsets.only(right: 16, top: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= _dailySales.length) return const SizedBox();
                        final dateStr = _dailySales[value.toInt()]['date'];
                        final date = DateTime.parse(dateStr);
                        return Text(DateFormat('E').format(date), style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _dailySales.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), (e.value['sales'] as num).toDouble());
                    }).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInventory() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vendorProducts.length,
      itemBuilder: (context, index) {
        final p = _vendorProducts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Image.network(p.imageUrl, width: 40, height: 40, fit: BoxFit.contain),
            title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Stock: ${p.stockQuantity}"),
            trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          ),
        );
      },
    );
  }
}
