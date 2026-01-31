import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../blocs/admin_bloc.dart';
import '../../../../injection_container.dart' as di;

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AdminBloc>()..add(LoadAdminStats()),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Дашборд',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3B48),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    context.read<AdminBloc>().add(LoadAdminStats()),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminStatsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AdminStatsError) {
                  return Center(child: Text('Ошибка: ${state.message}'));
                } else if (state is AdminStatsLoaded) {
                  final stats = state.stats;
                  final currencyFormat = NumberFormat.currency(
                    locale: 'kk_KZ',
                    symbol: '₸',
                    decimalDigits: 0,
                  );

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      int crossAxisCount = width > 1000
                          ? 4
                          : (width > 600 ? 2 : 1);
                      double childAspectRatio = width > 1000 ? 1.5 : 1.2;

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: childAspectRatio,
                        children: [
                          _StatCard(
                            title: 'Пользователи',
                            value: stats.totalUsers.toString(),
                            icon: Icons.people,
                            color: Colors.blue,
                          ),
                          _StatCard(
                            title: 'Магазины',
                            value: stats.totalStores.toString(),
                            icon: Icons.store,
                            color: Colors.orange,
                          ),
                          _StatCard(
                            title: 'Заказы',
                            value: stats.totalOrders.toString(),
                            icon: Icons.shopping_bag,
                            color: Colors.purple,
                          ),
                          _StatCard(
                            title: 'Выручка',
                            value: currencyFormat.format(stats.platformRevenue),
                            icon: Icons.monetization_on,
                            color: Colors.green,
                          ),
                        ],
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
