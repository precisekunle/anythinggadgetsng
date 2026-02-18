import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../../../data/models/product.dart';
import '../../../data/models/deal.dart';
import '../../../data/repositories/supabase_product_repository.dart';
import '../../../data/repositories/supabase_deal_repository.dart';
import '../widgets/featured_shops.dart';
import '../widgets/countdown_timer.dart';
import 'product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _productRepository = SupabaseProductRepository();
  final _dealRepository = SupabaseDealRepository();
  
  List<Product> _products = [];
  List<Product> _recentlyViewed = [];
  Deal? _activeDeal;
  bool _isLoading = true;
  bool _isLoadingRecent = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    try {
      final dealData = await _dealRepository.getActiveDeal();
      
      if (mounted) {
        if (dealData != null) {
          setState(() {
            _activeDeal = dealData['deal'] as Deal;
            _products = dealData['products'] as List<Product>;
          });
        } else {
          final products = await _productRepository.getProducts();
          setState(() {
            _products = products;
          });
        }
      }
      
      await _fetchRecentlyViewed();
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recentIds = prefs.getStringList('recently_viewed') ?? [];
    
    if (recentIds.isNotEmpty) {
      if (mounted) setState(() => _isLoadingRecent = true);
      
      List<Product> fetched = [];
      for (String id in recentIds.take(5)) {
        try {
          final p = await _productRepository.getProductById(id);
          if (p != null) fetched.add(p);
        } catch (_) {}
      }
      
      if (mounted) {
        setState(() {
          _recentlyViewed = fetched;
          _isLoadingRecent = false;
        });
      }
    }
  }

  void _onSearch(String query) {
    if (query.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(query: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header & Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.flash_on, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              "AnythingGadgets",
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.notifications_outlined, size: 28),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      onSubmitted: _onSearch,
                      decoration: InputDecoration(
                        hintText: "Search for laptops, phones...",
                        hintStyle: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hero Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1550009158-9ebf69173e03?ixlib=rb-1.2.1&auto=format&fit=crop&w=1351&q=80'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Step into the\nGadget\nRevolution",
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          "Shop Now",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _CategoryItem(icon: Icons.laptop_mac, label: "Laptops"),
                    _CategoryItem(icon: Icons.phone_android, label: "Phones"),
                    _CategoryItem(icon: Icons.watch, label: "Wearables"),
                    _CategoryItem(icon: Icons.headphones, label: "Audio"),
                  ],
                ),
              ),
            ),

            // Recently Viewed
            if (_recentlyViewed.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.history, size: 20, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            "Recently Viewed",
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _recentlyViewed.length,
                        itemBuilder: (context, index) {
                          final p = _recentlyViewed[index];
                          final currencyFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);
                          return GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p)),
                              );
                              _fetchRecentlyViewed();
                            },
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 100,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      border: Border.all(color: Colors.grey[200]!),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Image.network(p.imageUrl, fit: BoxFit.contain),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    p.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    currencyFormat.format(p.discountPrice ?? p.price),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Deal of the Day Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      _activeDeal?.title ?? "Deal of the Day",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_activeDeal != null)
                      CountdownTimer(endTime: _activeDeal!.endTime)
                    else
                      CountdownTimer(endTime: DateTime.now().add(const Duration(hours: 12))),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "View All",
                        style: GoogleFonts.inter(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product Grid
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_products.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text("No products found")),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ProductCard(
                        product: _products[index],
                        onAddToCart: () {
                          // TODO: Implement cart add
                        },
                      );
                    },
                    childCount: _products.length,
                  ),
                ),
              ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CategoryItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class SearchResultsScreen extends StatefulWidget {
  final String query;
  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _repository = SupabaseProductRepository();
  List<Product> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  Future<void> _performSearch() async {
    try {
      final results = await _repository.searchProducts(widget.query);
      if (mounted) {
        setState(() {
          _results = results;
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Search: ${widget.query}", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty 
              ? Center(child: Text("No results found for '${widget.query}'"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: _results[index], onAddToCart: () {});
                    },
                  ),
                ),
    );
  }
}
