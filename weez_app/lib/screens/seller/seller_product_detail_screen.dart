import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_stats.dart';
import '../../domain/entities/review.dart';
import '../../presentation/blocs/product_stats/product_stats_bloc.dart';
import '../../injection_container.dart';

class SellerProductDetailScreen extends StatelessWidget {
  final ProductEntity product;

  const SellerProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<ProductStatsBloc>()..add(LoadProductStats(product.id)),
      child: Scaffold(
        appBar: AppBar(title: Text(product.name)),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey,
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${product.price} KZT',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Stats Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Статистика',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              BlocBuilder<ProductStatsBloc, ProductStatsState>(
                builder: (context, state) {
                  if (state is ProductStatsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ProductStatsError) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Ошибка загрузки статистики: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (state is ProductStatsLoaded) {
                    return _buildStatsGrid(state.stats);
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 24),
              const Divider(),

              // Reviews Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Отзывы',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              BlocBuilder<ProductStatsBloc, ProductStatsState>(
                builder: (context, state) {
                  if (state is ProductStatsLoaded) {
                    if (state.reviews.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("Отзывов пока нет"),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.reviews.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return _buildReviewItem(state.reviews[index]);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ProductStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      childAspectRatio: 2.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(Icons.shopping_bag, 'Продажи', '${stats.sales} шт'),
        _buildStatCard(Icons.star, 'Рейтинг', stats.rating.toStringAsFixed(1)),
        _buildStatCard(Icons.visibility, 'Просмотры', stats.views.toString()),
        _buildStatCard(Icons.comment, 'Отзывы', stats.reviews.toString()),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(review.userName.isNotEmpty ? review.userName[0] : '?'),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(review.userName),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              Text(review.rating.toString()),
            ],
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(review.comment),
          const SizedBox(height: 4),
          Text(
            review.createdAt.toString().split(' ')[0],
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
