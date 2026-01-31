import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/product/product_bloc.dart';
import 'presentation/blocs/product/product_event.dart';
import 'presentation/blocs/cart/cart_bloc.dart';
import 'presentation/blocs/cart/cart_event.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/seller_dashboard_screen.dart';
import 'features/admin/presentation/admin_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => di.sl<ProductBloc>()..add(const LoadProducts()),
        ),
        BlocProvider(create: (_) => di.sl<CartBloc>()..add(LoadCart())),
      ],
      child: MaterialApp(
        title: 'WEEZ Marketplace',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF494F88),
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF494F88),
            primary: const Color(0xFF494F88),
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        routes: {
          '/auth': (context) => const AuthScreen(),
          '/home': (context) => const HomeScreen(),
          '/seller_dashboard': (context) => const SellerDashboardScreen(),
          '/admin': (context) => const AdminScaffold(),
        },
      ),
    );
  }
}
