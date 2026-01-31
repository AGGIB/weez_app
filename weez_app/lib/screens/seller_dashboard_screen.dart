import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller/my_products_tab.dart';
import 'seller/seller_home_screen.dart';
import 'seller/seller_settings_tab.dart';
import 'seller/seller_orders_tab.dart';
import 'add_product/add_product_wizard_screen.dart';
import '../presentation/blocs/seller/seller_bloc.dart';
import '../presentation/blocs/seller/seller_state_event.dart'; // Fixed import
import '../../injection_container.dart' as di;

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<SellerBloc>()..add(LoadSellerInfo()),
      child: const _SellerDashboardScreenContent(),
    );
  }
}

class _SellerDashboardScreenContent extends StatefulWidget {
  const _SellerDashboardScreenContent();

  @override
  State<_SellerDashboardScreenContent> createState() =>
      _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<_SellerDashboardScreenContent> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SellerHomeScreen(),
    const MyProductsTab(),
    const AddProductWizardScreen(),
    const SellerOrdersTab(),
    const SellerSettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Панель продавца',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF494F88),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Главная',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Товары'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Добавить',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Заказы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}
