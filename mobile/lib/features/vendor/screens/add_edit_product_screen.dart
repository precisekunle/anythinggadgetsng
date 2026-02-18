import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/supabase_product_repository.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _imgUrlCtrl;
  late TextEditingController _categoryCtrl;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.product?.title);
    _descCtrl = TextEditingController(text: "");
    _priceCtrl = TextEditingController(text: widget.product?.price.toString());
    _imgUrlCtrl = TextEditingController(text: widget.product?.imageUrl);
    _categoryCtrl = TextEditingController(text: widget.product?.category);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    // Logic to save product via Supabase
    // This would involve SupabaseProductRepository.addProduct / updateProduct
    // For now, we'll just simulate and pop.
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product == null ? "Add Product" : "Edit Product", style: GoogleFonts.inter(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: "Product Title"), validator: (v) => v!.isEmpty ? "Required" : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _priceCtrl, decoration: const InputDecoration(labelText: "Price (₦)"), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? "Required" : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _categoryCtrl, decoration: const InputDecoration(labelText: "Category"), validator: (v) => v!.isEmpty ? "Required" : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _imgUrlCtrl, decoration: const InputDecoration(labelText: "Image URL"), validator: (v) => v!.isEmpty ? "Required" : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: "Description"), maxLines: 5),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text("Save Product", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
