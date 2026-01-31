import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_event.dart';
import '../../presentation/blocs/seller/seller_bloc.dart';
import '../../presentation/blocs/seller/seller_state_event.dart';
import 'create_store_screen.dart';
import 'edit_store_screen.dart';

class SellerSettingsTab extends StatelessWidget {
  const SellerSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SellerBloc, SellerState>(
      builder: (context, state) {
        if (state is SellerLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SellerStoreEmpty) {
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
        }

        if (state is SellerError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ошибка: ${state.message}'),
                ElevatedButton(
                  onPressed: () {
                    context.read<SellerBloc>().add(LoadSellerInfo());
                  },
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        if (state is SellerLoaded) {
          final store = state.store;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('Информация о магазине'),
              _buildInfoTile('Название', store.name),
              _buildInfoTile('Описание', store.description),
              _buildInfoTile(
                'Юридическая информация',
                store.legalInfo ?? 'Не указано',
              ),
              _buildInfoTile('Рейтинг', '${store.rating} ⭐'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final sellerBloc = context.read<SellerBloc>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: sellerBloc,
                        child: EditStoreScreen(
                          currentName: store.name,
                          currentDescription: store.description,
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text('Редактировать магазин'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF494F88),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/auth',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Выйти из аккаунта'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          );
        }

        return const Center(child: Text('Нет данных о магазине'));
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF494F88),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
