import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/auth/auth_state.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // AuthBloc Check is dispatched in main.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
           if (state is AuthAuthenticated) {
             Navigator.of(context).pushReplacementNamed('/home');
           } else if (state is AuthUnauthenticated) {
             Navigator.of(context).pushReplacementNamed('/auth');
           }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo
              SvgPicture.asset(
                'lib/assets/logo/logo_weez.svg',
                width: 200,
                height: 200,
              ),
              const Spacer(),
              // Version text
              const Padding(
                padding: EdgeInsets.only(bottom: 40.0),
                child: Text(
                  'Версия 1',
                  style: TextStyle(
                    color: Color(0xFF494F88),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
