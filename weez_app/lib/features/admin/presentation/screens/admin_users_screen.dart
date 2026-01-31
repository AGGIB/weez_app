import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/admin_bloc.dart';
import '../../../../injection_container.dart' as di;

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AdminBloc>()..add(const LoadAdminUsers()),
      child: const _UsersContent(),
    );
  }
}

class _UsersContent extends StatelessWidget {
  const _UsersContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Пользователи',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3B48),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
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
              child: BlocBuilder<AdminBloc, AdminState>(
                builder: (context, state) {
                  if (state is AdminUsersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AdminUsersError) {
                    return Center(child: Text('Ошибка: ${state.message}'));
                  } else if (state is AdminUsersLoaded) {
                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SizedBox(
                              width: double.infinity,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('ID')),
                                  DataColumn(label: Text('Имя')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Роль')),
                                  DataColumn(label: Text('Статус')),
                                ],
                                rows: state.users.map<DataRow>((user) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(user['id'].toString())),
                                      DataCell(Text(user['name'] ?? 'No Name')),
                                      DataCell(Text(user['email'] ?? '')),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getRoleColor(user['role']),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            user['role']?.toUpperCase() ??
                                                'UNKNOWN',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(user['status'] ?? 'active'),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        // Pagination Controls
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Страница ${state.page}'),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: state.page > 1
                                    ? () {
                                        context.read<AdminBloc>().add(
                                          LoadAdminUsers(page: state.page - 1),
                                        );
                                      }
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: (state.page * 10) < state.total
                                    ? () {
                                        context.read<AdminBloc>().add(
                                          LoadAdminUsers(page: state.page + 1),
                                        );
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'seller':
        return Colors.blue;
      case 'buyer':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
