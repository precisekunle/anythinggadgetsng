import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/shop.dart';
import '../../../../data/repositories/shop_repository.dart';
import '../screens/shop_details_screen.dart';

class FeaturedShops extends StatefulWidget {
  const FeaturedShops({super.key});

  @override
  State<FeaturedShops> createState() => _FeaturedShopsState();
}

class _FeaturedShopsState extends State<FeaturedShops> {
  final ShopRepository _shopRepository = ShopRepository();
  List<Shop> _shops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    try {
      final shops = await _shopRepository.getShops();
      if (mounted) {
        setState(() {
          _shops = shops;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if (_shops.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Official Stores",
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "See all",
                style: GoogleFonts.inter(color: Colors.blue, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140, // Height for logo + name
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _shops.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final shop = _shops[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ShopScreen(shopId: shop.id),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                        image: shop.logoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(shop.logoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 90,
                      child: Text(
                        shop.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
