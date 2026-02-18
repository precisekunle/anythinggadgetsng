import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/supabase_product_repository.dart';

class VendorProductManagementScreen extends StatefulWidget {
  const VendorProductManagementScreen({super.key});

  @override
  State<VendorProductManagementScreen> createState() => _VendorProductManagementScreenState();
}

class _VendorProductManagementScreenState extends State<VendorProductManagementScreen> {
  final _productRepository = SupabaseProductRepository();
  final _client = Supabase.instance.client;
  List<Product> _vendorProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    // In a real app, we'd filter by vendor_id. 
    // For now, let's just fetch all or some mock.
    // Ideally we need SupabaseProductRepository.getProductsByVendor(vendorId)
    try {
      final products = await _productRepository.getProducts(); // Mock: assume all products for now or fix repository
      setState(() {
        _vendorProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Manage Products", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _vendorProducts.length,
              itemBuilder: (context, index) {
                final p = _vendorProducts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Image.network(p.imageUrl, width: 50, height: 50, fit: BoxFit.contain),
                    title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Price: ₦${p.price}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {}),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text("Add Product"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
