import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../../presentation/blocs/auth/auth_event.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_users_screen.dart';

class AdminScaffold extends StatefulWidget {
  const AdminScaffold({super.key});

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardScreen(),
    const AdminUsersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Check if wide screen (Desktop/Tablet) or mobile
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Row(
        children: [
          if (isWide)
            _buildSidebar(context)
          else
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                if (index == 2) {
                  _logout(context);
                } else {
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Дашборд'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outlined),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Пользователи'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.logout, color: Colors.red),
                  label: Text('Выход', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      // Add drawer for mobile if not wide? NavigationRail is fine for now on left.
      // But NavigationRail is already shown conditionally using 'else'.
      // Wait, isWide true -> Sidebar (full width), else -> NavigationRail (slim). Perfect.
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            'Weez Admin',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF494F88),
            ),
          ),
          const SizedBox(height: 48),
          _buildMenuItem(0, Icons.dashboard_outlined, 'Дашборд'),
          _buildMenuItem(1, Icons.people_outlined, 'Пользователи'),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Выйти',
              style: GoogleFonts.inter(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _logout(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF494F88) : Colors.grey,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: isSelected ? const Color(0xFF494F88) : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF494F88).withValues(alpha: 0.05),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  void _logout(BuildContext context) {
    context.read<AuthBloc>().add(AuthLogoutRequested());
    Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
  }
}
