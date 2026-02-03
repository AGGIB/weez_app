import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/auth/auth_event.dart';
import '../presentation/blocs/auth/auth_state.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'buyer';

  // Seller specific controllers
  final _storeNameController = TextEditingController();
  final _binController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole,
          storeName: _selectedRole == 'seller'
              ? _storeNameController.text
              : null,
          bin: _selectedRole == 'seller' ? _binController.text : null,
          address: _selectedRole == 'seller' ? _addressController.text : null,
          phone: _selectedRole == 'seller' ? _phoneController.text : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1A1C20), const Color(0xFF121212)]
                : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              if (state.user.role == 'seller') {
                Navigator.of(context).pushReplacementNamed('/seller_dashboard');
              } else {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            } else if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Header
                    Text(
                      'Создать аккаунт',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Присоединяйтесь к WEEZ Marketplace',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.3 : 0.05,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Role Switcher
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedRole = 'buyer'),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _selectedRole == 'buyer'
                                            ? const Color(0xFF494F88)
                                            : (isDark
                                                  ? Colors.black26
                                                  : Colors.grey.shade100),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Покупатель',
                                        style: GoogleFonts.inter(
                                          color: _selectedRole == 'buyer'
                                              ? Colors.white
                                              : (isDark
                                                    ? Colors.white38
                                                    : Colors.grey),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _selectedRole = 'seller',
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _selectedRole == 'seller'
                                            ? const Color(0xFF494F88)
                                            : (isDark
                                                  ? Colors.black26
                                                  : Colors.grey.shade100),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Продавец',
                                        style: GoogleFonts.inter(
                                          color: _selectedRole == 'seller'
                                              ? Colors.white
                                              : (isDark
                                                    ? Colors.white38
                                                    : Colors.grey),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Common Fields
                            _buildTextField(
                              _nameController,
                              "Имя пользователя",
                              isDark,
                              icon: Icons.person,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              _emailController,
                              "Email",
                              isDark,
                              icon: Icons.email,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              _passwordController,
                              "Пароль",
                              isDark,
                              icon: Icons.lock,
                              isPassword: true,
                            ),

                            // Seller Fields
                            if (_selectedRole == 'seller') ...[
                              const SizedBox(height: 24),
                              Text(
                                "Информация о магазине",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildTextField(
                                _storeNameController,
                                "Название магазина",
                                isDark,
                                icon: Icons.store,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                _binController,
                                "БИН / ИИН",
                                isDark,
                                icon: Icons.numbers,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                _addressController,
                                "Юридический адрес",
                                isDark,
                                icon: Icons.location_on,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                _phoneController,
                                "Телефон",
                                isDark,
                                icon: Icons.phone,
                              ),
                            ],

                            const SizedBox(height: 32),

                            // Submit
                            ElevatedButton(
                              onPressed: _onRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF494F88),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Зарегистрироваться',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Login Link
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Go back to login
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Уже есть аккаунт? ",
                                  style: GoogleFonts.inter(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey.shade600,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Войти",
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF494F88),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool isDark, {
    IconData? icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
        prefixIcon: icon != null
            ? Icon(icon, color: isDark ? Colors.white38 : Colors.grey)
            : null,
        filled: true,
        fillColor: isDark ? Colors.black26 : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF494F88)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Поле обязательно для заполнения';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _storeNameController.dispose();
    _binController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
