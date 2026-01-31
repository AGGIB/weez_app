import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../presentation/blocs/seller_dashboard/seller_dashboard_bloc.dart';
import '../../presentation/blocs/seller_dashboard/seller_dashboard_state.dart';
import '../../presentation/blocs/seller/seller_bloc.dart';
import '../../injection_container.dart' as di;
import 'package:intl/intl.dart';

class SellerHomeScreen extends StatelessWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<SellerDashboardBloc>()..add(LoadDashboardStats()),
      child: const _SellerHomeScreenContent(),
    );
  }
}

class _SellerHomeScreenContent extends StatelessWidget {
  const _SellerHomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SellerBloc, SellerState>(
      builder: (context, sellerState) {
        String storeName = 'Продавец';
        if (sellerState is SellerLoaded) {
          storeName = sellerState.store.name;
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<SellerDashboardBloc>().add(LoadDashboardStats());
            context.read<SellerBloc>().add(LoadSellerInfo());
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Добрый день, $storeName! 👋',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3B48),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Вот сводка по вашему магазину',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              BlocBuilder<SellerDashboardBloc, SellerDashboardState>(
                builder: (context, state) {
                  if (state is DashboardStatsLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state is DashboardStatsError) {
                    return Center(child: Text('Ошибка: ${state.message}'));
                  }

                  if (state is DashboardStatsLoaded) {
                    final stats = state.stats;
                    final currencyFormat = NumberFormat.currency(
                      locale: 'kk_KZ',
                      symbol: '₸',
                      decimalDigits: 0,
                    );

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatsCard(
                                title: 'Выручка',
                                value: currencyFormat.format(
                                  stats.totalRevenue,
                                ),
                                icon: Icons.monetization_on_outlined,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatsCard(
                                title: 'Заказы',
                                value: stats.ordersCount.toString(),
                                icon: Icons.shopping_bag_outlined,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _StatsCard(
                                title: 'Товары',
                                value: stats.productsCount.toString(),
                                icon: Icons.inventory_2_outlined,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatsCard(
                                title: 'Рейтинг',
                                value: stats.averageRating.toStringAsFixed(1),
                                icon: Icons.star_outline,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
