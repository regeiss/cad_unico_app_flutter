import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/demanda_provider.dart';
import 'providers/membro_provider.dart';
import 'providers/responsavel_provider.dart';
import 'screens/demandas/demandas_screen.dart';
import 'screens/home_screen.dart';
// Screens
import 'screens/login_screen.dart';
import 'screens/membros/membros_screen.dart';
import 'screens/responsavel/responsaveis_screen.dart';
import 'screens/responsavel/responsavel_detail_screen.dart';
import 'screens/responsavel/responsavel_screen.dart';
import 'screens/splash_screen.dart';
// Utils
import 'services/api_service.dart';
import 'utils/app_theme.dart';
// import 'utils/constants.dart';

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  apiService.init();
  await apiService.loadSavedTokens();

  
  runApp(CadastroApp());
}

class CadastroApp extends StatelessWidget {
  CadastroApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'responsaveis',
            builder: (context, state) => const ResponsaveisScreen(),
            routes: [
              GoRoute(
                path: 'novo',
                builder: (context, state) => const ResponsavelFormScreen(),
              ),
              GoRoute(
                path: ':cpf',
                builder: (context, state) => ResponsavelDetailScreen(
                  cpf: state.pathParameters['cpf']!,
                ),
              ),
              GoRoute(
                path: ':cpf/editar',
                builder: (context, state) => ResponsavelFormScreen(
                  cpf: state.pathParameters['cpf'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'membros',
            builder: (context, state) => const MembrosScreen(),
          ),
          GoRoute(
            path: 'demandas',
            builder: (context, state) => const DemandasScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';
      final isSplashRoute = state.matchedLocation == '/splash';

      // Se não estiver logado e não estiver na tela de login ou splash
      if (!isLoggedIn && !isLoginRoute && !isSplashRoute) {
        return '/login';
      }

      // Se estiver logado e estiver na tela de login
      if (isLoggedIn && isLoginRoute) {
        return '/';
      }

      return null;
    },
  );

  @override
  Widget build(BuildContext context) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ResponsavelProvider()),
        ChangeNotifierProvider(create: (_) => MembroProvider()),
        ChangeNotifierProvider(create: (_) => DemandaProvider()),
      ],
      child: MaterialApp.router(
        title: 'Cadastro Unificado',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
}