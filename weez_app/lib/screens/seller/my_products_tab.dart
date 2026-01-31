import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../presentation/widgets/product_card.dart';
import '../../presentation/blocs/seller/seller_bloc.dart';
import 'seller_product_detail_screen.dart';
import '../../presentation/blocs/product/product_bloc.dart';
import '../../presentation/blocs/product/product_event.dart';
import '../../presentation/blocs/product/product_state.dart';
import '../../domain/entities/product.dart';
import '../../injection_container.dart' as di;

import '../add_product/add_product_wizard_screen.dart';
import '../seller/create_store_screen.dart'; // New import

class MyProductsTab extends StatefulWidget {
  const MyProductsTab({super.key});

  @override
  State<MyProductsTab> createState() => _MyProductsTabState();
}

class _MyProductsTabState extends State<MyProductsTab> {
  // We use a local ProductBloc to not interfere with global product lists if any
  late ProductBloc _productBloc;

  @override
  void initState() {
    super.initState();
    _productBloc = di.sl<ProductBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sellerState = context.read<SellerBloc>().state;
      if (sellerState is SellerLoaded) {
        _productBloc.add(LoadProducts(storeId: sellerState.store.id));
      }
    });
  }

  @override
  void dispose() {
    _productBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SellerBloc, SellerState>(
      listener: (context, state) {
        if (state is SellerLoaded) {
          _productBloc.add(LoadProducts(storeId: state.store.id));
        }
      },
      child: BlocBuilder<SellerBloc, SellerState>(
        builder: (context, sellerState) {
          if (sellerState is SellerLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (sellerState is SellerError) {
            // If store not found, maybe retry or show error
            return Center(
              child: Text('Ошибка загрузки магазина: ${sellerState.message}'),
            );
          } else if (sellerState is SellerStoreEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Магазин не найден. Создайте свой магазин!'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Pass existing bloc to new route
                      final sellerBloc = context.read<SellerBloc>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: sellerBloc,
                            child: const CreateStoreScreen(),
                          ),
                        ),
                      );
                    },
                    child: const Text('Создать магазин'),
                  ),
                ],
              ),
            );
          } else if (sellerState is SellerLoaded) {
            // Store loaded, check products
            return BlocBuilder<ProductBloc, ProductState>(
              bloc: _productBloc,
              builder: (context, productState) {
                if (productState is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (productState is ProductLoaded) {
                  if (productState.products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "У вас пока нет товаров",
                            style: GoogleFonts.inter(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AddProductWizardScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Добавить первый товар"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF494F88),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      _productBloc.add(
                        LoadProducts(storeId: sellerState.store.id),
                      );
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: productState.products.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(productState.products[index]);
                      },
                    ),
                  );
                } else if (productState is ProductError) {
                  return Center(child: Text("Ошибка: ${productState.message}"));
                }
                return const Center(child: CircularProgressIndicator());
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    return ProductCard(
      product: product,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellerProductDetailScreen(product: product),
          ),
        );
      },
    );
  }
}
