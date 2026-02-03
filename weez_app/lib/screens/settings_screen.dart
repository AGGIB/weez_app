import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../presentation/blocs/theme/theme_cubit.dart';
import 'edit_personal_data_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Настройки',
          style: GoogleFonts.inter(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
      ),
      body: ListView(
        children: [
          _buildSection('Аккаунт', isDark),
          _buildTile(
            context,
            'Управление аккаунтом',
            Icons.person_outline,
            isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditPersonalDataScreen(),
                ),
              );
            },
          ),
          _buildTile(context, 'Конфиденциальность', Icons.lock_outline, isDark),
          _buildTile(
            context,
            'Изменить пароль',
            Icons.security_outlined,
            isDark,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Инструкции отправлены на email')),
              );
            },
          ),
          _buildTile(
            context,
            'Удалить аккаунт',
            Icons.delete_forever_outlined,
            isDark,
            onTap: () {
              _showDeleteAccountDialog(context, isDark);
            },
          ),

          _buildSection('Приложение', isDark),
          _buildTile(
            context,
            'Уведомления',
            Icons.notifications_outlined,
            isDark,
          ),
          _buildTile(
            context,
            'Язык',
            Icons.language,
            isDark,
            onTap: () {
              _showLanguageDialog(context, isDark);
            },
          ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mood) {
              return _buildTile(
                context,
                'Тема (${mood == ThemeMode.light ? 'Светлая' : 'Темная'})',
                mood == ThemeMode.light
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                isDark,
                onTap: () => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Выберите язык',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Русский',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text(
                'English',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text(
                'Қазақша',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Удалить аккаунт?',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          'Это действие необратимо. Все ваши данные будут удалены.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Запрос на удаление отправлен')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white38 : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    String title,
    IconData icon,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? Colors.white38 : Colors.grey,
      ),
      onTap: onTap ?? () {},
    );
  }
}
