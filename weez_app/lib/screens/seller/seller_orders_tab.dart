import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/blocs/order/order_bloc.dart';
import '../../domain/entities/order.dart';
import '../../injection_container.dart';
import 'seller_order_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerOrdersTab extends StatefulWidget {
  const SellerOrdersTab({super.key});

  @override
  State<SellerOrdersTab> createState() => _SellerOrdersTabState();
}

class _SellerOrdersTabState extends State<SellerOrdersTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OrderBloc _orderBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _orderBloc = sl<OrderBloc>()..add(LoadSellerOrders());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _orderBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _orderBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Заказы', style: GoogleFonts.inter()),
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF494F88),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF494F88),
            tabs: const [
              Tab(text: 'Новые'),
              Tab(text: 'В работе'),
              Tab(text: 'Все'),
            ],
          ),
        ),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OrderError) {
              return Center(child: Text('Ошибка: ${state.message}'));
            }
            if (state is OrderLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildOrderList(state.orders, ['pending', 'new']),
                  _buildOrderList(state.orders, ['processing', 'shipped']),
                  _buildOrderList(state.orders, null),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderEntity> allOrders, List<String>? statuses) {
    final orders = statuses == null
        ? allOrders
        : allOrders.where((o) => statuses.contains(o.status)).toList();

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text('Заказов нет', style: GoogleFonts.inter(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _orderBloc.add(LoadSellerOrders());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(context, order);
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderEntity order) {
    Color statusColor = Colors.grey;
    if (order.status == 'pending') statusColor = Colors.orange;
    if (order.status == 'processing') statusColor = Colors.blue;
    if (order.status == 'shipped') statusColor = Colors.indigo;
    if (order.status == 'delivered') statusColor = Colors.green;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SellerOrderDetailsScreen(orderId: order.id),
            ),
          ).then((_) => _orderBloc.add(LoadSellerOrders())); // Reload on return
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Заказ #${order.id}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Сумма: ${order.totalAmount.toStringAsFixed(0)} KZT',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Дата: ${order.createdAt.toString().split('.')[0]}',
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
