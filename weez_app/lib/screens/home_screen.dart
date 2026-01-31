import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/auth/auth_state.dart';
import '../presentation/blocs/product/product_bloc.dart';
import '../presentation/blocs/product/product_event.dart';
import '../presentation/blocs/product/product_state.dart';
import '../domain/entities/product.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'ai_assistant_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _selectedIndex == 0 ? _buildHomeTab() : _buildOtherTab(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        // Header
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String userName = 'User!';
            if (state is AuthAuthenticated) {
              userName = state.user.name; // assuming UserEntity has name
            }
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Добро пожаловать ',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const Text('👋', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),

        // Search bar (simplified logic for now)
         Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Искать товар',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (query) {
                      context.read<ProductBloc>().add(SearchProducts(query));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.tune, color: Colors.white),
                  onPressed: () {
                    // TODO: Show filters
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Main Content (Categories & Grid) dependent on ProductBloc
        Expanded(
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                 return const Center(child: CircularProgressIndicator());
              } else if (state is ProductError) {
                 return Center(child: Text(state.message));
              } else if (state is ProductLoaded) {
                return Column(
                  children: [
                     // Categories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: state.categories.map((category) {
                           IconData icon = Icons.checkroom; // default
                           if (category == 'Все товары') icon = Icons.apps;
                           if (category == 'Телефоны') icon = Icons.phone_iphone;
                           if (category == 'Электроника') icon = Icons.computer;
                           if (category == 'Часы') icon = Icons.watch;
                           
                           return Padding(
                             padding: const EdgeInsets.only(right: 8.0),
                             child: _buildCategoryChip(category, state.selectedCategory, icon),
                           );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Products Grid
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(state.products[index]);
                        },
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, String selectedCategory, IconData icon) {
    final isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () {
        context.read<ProductBloc>().add(LoadProducts(category: label));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                     context.read<ProductBloc>().add(ToggleFavorite(product.id));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 18,
                      color: product.isFavorite
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(0)}₸',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildOtherTab() {
    switch (_selectedIndex) {
      case 1:
        return const CartScreen();
      case 2:
        return const AIAssistantScreen();
      case 3:
        return const FavoritesScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home, 0),
              _buildNavItem(Icons.shopping_bag, 1),
              _buildAINavItem(),
              _buildNavItem(Icons.favorite, 3),
              _buildNavItem(Icons.person, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF494F88) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildAINavItem() {
    final isSelected = _selectedIndex == 2;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = 2;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF494F88), Color(0xFF7B82C8)],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade800,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF494F88).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: const Icon(
          Icons.auto_awesome,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
