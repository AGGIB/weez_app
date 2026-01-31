import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../injection_container.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../presentation/blocs/order/order_details_bloc.dart';

class SellerOrderDetailsScreen extends StatelessWidget {
  final int orderId;

  const SellerOrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<OrderDetailsBloc>()..add(LoadOrderDetails(orderId.toString())),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Заказ #$orderId', style: GoogleFonts.inter()),
          elevation: 0,
        ),
        body: BlocConsumer<OrderDetailsBloc, OrderDetailsState>(
          listener: (context, state) {
            if (state is OrderDetailsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is OrderStatusUpdateSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Статус обновлен')));
            }
          },
          builder: (context, state) {
            if (state is OrderDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OrderDetailsLoaded) {
              return _buildContent(context, state.order);
            }
            // Maintain loaded state during update if possible, or reload?
            // Bloc logic: On UpdateOrderStatus, we emit OrderStatusUpdating then Success then reload.
            // If we emit Loading during reload, UI will flicker.
            // But currently LoadOrderDetails emits Loading.

            return const Center(child: Text('Загрузка...'));
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, OrderEntity order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(context, order),
          const SizedBox(height: 16),
          _buildBuyerInfo(order),
          const SizedBox(height: 16),
          _buildOrderItems(order),
          const SizedBox(height: 16),
          _buildTotal(order),
          const SizedBox(height: 32),
          _buildActions(context, order),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, OrderEntity order) {
    Color color = Colors.grey;
    if (order.status == 'pending') color = Colors.orange;
    if (order.status == 'processing') color = Colors.blue;
    if (order.status == 'shipped') color = Colors.indigo;
    if (order.status == 'delivered') color = Colors.green;
    if (order.status == 'cancelled') color = Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Статус заказа',
            style: GoogleFonts.inter(color: Colors.grey[700], fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            order.status.toUpperCase(),
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.createdAt.toString().split('.')[0],
            style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerInfo(OrderEntity order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Покупатель',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.person, order.buyerName ?? 'Не указано'),
            const SizedBox(height: 8),
            _infoRow(Icons.phone, order.buyerPhone ?? 'Не указано'),
            const SizedBox(height: 8),
            _infoRow(Icons.location_on, order.buyerAddress ?? 'Не указано'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: GoogleFonts.inter(color: Colors.grey[800])),
        ),
      ],
    );
  }

  Widget _buildOrderItems(OrderEntity order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Товары',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...?(order.items?.map((item) => _buildItemTile(item))),
      ],
    );
  }

  Widget _buildItemTile(OrderItemEntity item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
              image: item.productImage.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(item.productImage),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${item.price.toStringAsFixed(0)} KZT x ${item.quantity}',
                  style: GoogleFonts.inter(color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${(item.price * item.quantity).toStringAsFixed(0)} KZT',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal(OrderEntity order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Итого:',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '${order.totalAmount.toStringAsFixed(0)} KZT',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF494F88),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, OrderEntity order) {
    if (order.status == 'new' || order.status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateStatus(context, 'cancelled'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Отклонить'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus(context, 'processing'),
              child: const Text('В работу'),
            ),
          ),
        ],
      );
    } else if (order.status == 'processing') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateStatus(context, 'shipped'),
          child: const Text('Отправить заказ'),
        ),
      );
    } else if (order.status == 'shipped') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateStatus(context, 'delivered'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Заказ доставлен'),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _updateStatus(BuildContext context, String status) {
    context.read<OrderDetailsBloc>().add(
      UpdateOrderStatus(orderId.toString(), status),
    );
  }
}
