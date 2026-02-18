import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/user_address.dart';
import '../../../data/repositories/supabase_address_repository.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  final _addressRepository = SupabaseAddressRepository();
  final _client = Supabase.instance.client;
  List<UserAddress> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final addresses = await _addressRepository.getAddresses(userId);
      if (mounted) {
        setState(() {
          _addresses = addresses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddAddressDialog([UserAddress? existing]) {
    final labelCtrl = TextEditingController(text: existing?.label);
    final nameCtrl = TextEditingController(text: existing?.fullName);
    final phoneCtrl = TextEditingController(text: existing?.phoneNumber);
    final streetCtrl = TextEditingController(text: existing?.street);
    final cityCtrl = TextEditingController(text: existing?.city);
    final stateCtrl = TextEditingController(text: existing?.state);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? "Add New Address" : "Edit Address"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: "Label (e.g. Home, Office)")),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Full Name")),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone Number")),
              TextField(controller: streetCtrl, decoration: const InputDecoration(labelText: "Street")),
              TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: "City")),
              TextField(controller: stateCtrl, decoration: const InputDecoration(labelText: "State")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final userId = _client.auth.currentUser?.id;
              if (userId == null) return;

              final address = UserAddress(
                id: existing?.id ?? '',
                userId: userId,
                label: labelCtrl.text,
                fullName: nameCtrl.text,
                phoneNumber: phoneCtrl.text,
                street: streetCtrl.text,
                city: cityCtrl.text,
                state: stateCtrl.text,
                isDefault: existing?.isDefault ?? (_addresses.isEmpty),
                createdAt: DateTime.now(),
              );

              if (existing == null) {
                await _addressRepository.addAddress(address);
              } else {
                await _addressRepository.updateAddress(address);
              }
              Navigator.pop(context);
              _fetchAddresses();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Address Management", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? Center(child: Text("No addresses found", style: GoogleFonts.inter()))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final addr = _addresses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text("${addr.label} ${addr.isDefault ? '(Default)' : ''}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${addr.fullName}\n${addr.street}, ${addr.city}, ${addr.state}"),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit), onPressed: () => _showAddAddressDialog(addr)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _addressRepository.deleteAddress(addr.id);
                                _fetchAddresses();
                              },
                            ),
                          ],
                        ),
                        onLongPress: () async {
                          final userId = _client.auth.currentUser?.id;
                          if (userId != null) {
                            await _addressRepository.setDefaultAddress(userId, addr.id);
                            _fetchAddresses();
                          }
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAddressDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
