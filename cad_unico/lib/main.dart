import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your providers
import 'contants/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/demanda_provider.dart';
import 'providers/membro_provider.dart';
import 'providers/responsavel_provider.dart';
import 'screens/demandas/demandas_screen.dart';
import 'screens/home_screen.dart';
// Import your screens
import 'screens/login_screen.dart';
import 'screens/membros/membros_screen.dart';

import 'utils/app_theme.dart';
// Import utils

import 'utils/responsive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  await SharedPreferences.getInstance();
  
  runApp(const CadastroUnificadoApp());
}

class CadastroUnificadoApp extends StatelessWidget {
  const CadastroUnificadoApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DemandaProvider()),
        ChangeNotifierProvider(create: (_) => MembroProvider()),
        ChangeNotifierProvider(create: (_) => ResponsavelProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) => MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: _router,
            builder: (context, child) => ResponsiveWrapper(
                child: child ?? const SizedBox(),
              ),
          ),
      ),
    );
}

// Router configuration
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Login Route
    GoRoute(
      path: '/',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    
    // Home Route
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        // Responsáveis Routes
        GoRoute(
          path: '/responsaveis',
          name: 'responsaveis',
          builder: (context, state) => const ResponsaveisScreen(),
        ),
        
        // Membros Routes
        GoRoute(
          path: '/membros',
          name: 'membros',
          builder: (context, state) => const MembrosScreen(),
        ),
        
        // Demandas Routes
        GoRoute(
          path: '/demandas',
          name: 'demandas',
          builder: (context, state) => const DemandasScreen(),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isAuthenticated;
    
    // If not logged in and trying to access protected routes
    if (!isLoggedIn && state.fullPath != '/') {
      return '/';
    }
    
    // If logged in and on login page, redirect to home
    if (isLoggedIn && state.fullPath == '/') {
      return '/home';
    }
    
    return null;
  },
);

// Responsive wrapper widget
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  
  const ResponsiveWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) {
        // Initialize responsive utils
        Responsive.init(context);
        
        return child;
      },
    );
}

// Error widget for router
class ErrorScreen extends StatelessWidget {
  final String error;
  
  const ErrorScreen({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Erro'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Algo deu errado',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Voltar ao Início'),
            ),
          ],
        ),
      ),
    );
}

// Loading screen
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.admin_panel_settings,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ),
            const SizedBox(height: 32),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Carregando...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
}

// App lifecycle handler
class AppLifecycleHandler extends StatefulWidget {
  final Widget child;
  
  const AppLifecycleHandler({
    super.key,
    required this.child,
  });

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler> 
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        // App is in background
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        break;
      case AppLifecycleState.inactive:
        // App is inactive
        break;
    }
  }

  void _onAppResumed() {
    // Refresh data when app comes back to foreground
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      // Refresh user data if needed
      authProvider.refreshUser();
    }
  }

  void _onAppPaused() {
    // Save any pending data when app goes to background
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.saveUserData();
  }

  void _onAppDetached() {
    // Clean up when app is being terminated
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.cleanup();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';

// // Providers
// import 'providers/auth_provider.dart';
// import 'providers/demanda_provider.dart';
// import 'providers/membro_provider.dart';
// import 'providers/responsavel_provider.dart';
// import 'screens/demandas/demandas_screen.dart';
// import 'screens/home_screen.dart';
// // Screens
// import 'screens/login_screen.dart';
// import 'screens/membros/membros_screen.dart';
// import 'screens/responsavel/responsaveis_screen.dart';
// import 'screens/responsavel/responsavel_detail_screen.dart';
// import 'screens/responsavel/responsavel_screen.dart';
// import 'screens/splash_screen.dart';
// // Utils
// import 'services/api_service.dart';
// import 'utils/app_theme.dart';
// // import 'utils/constants.dart';

// Future<void> main() async {
  
//   WidgetsFlutterBinding.ensureInitialized();
//   final apiService = ApiService();
//   apiService.init();
//   await apiService.loadSavedTokens();

//   runApp(CadastroApp(apiService: apiService));
// }

// class CadastroApp extends StatelessWidget {
//   CadastroApp({super.key, required this.apiService});
//   final ApiService apiService;


//   final GoRouter _router = GoRouter(
//     initialLocation: '/splash',
//     routes: [
//       GoRoute(
//         path: '/splash',
//         builder: (context, state) => const SplashScreen(),
//       ),
//       GoRoute(
//         path: '/login',
//         builder: (context, state) => const LoginScreen(),
//       ),
//       GoRoute(
//         path: '/',
//         builder: (context, state) => const HomeScreen(),
//         routes: [
//           GoRoute(
//             path: 'responsaveis',
//             builder: (context, state) => const ResponsaveisScreen(),
//             routes: [
//               GoRoute(
//                 path: 'novo',
//                 builder: (context, state) => const ResponsavelFormScreen(),
//               ),
//               GoRoute(
//                 path: ':cpf',
//                 builder: (context, state) => ResponsavelDetailScreen(
//                   cpf: state.pathParameters['cpf']!,
//                 ),
//               ),
//               GoRoute(
//                 path: ':cpf/editar',
//                 builder: (context, state) => ResponsavelFormScreen(
//                   cpf: state.pathParameters['cpf'],
//                 ),
//               ),
//             ],
//           ),
//           GoRoute(
//             path: 'membros',
//             builder: (context, state) => const MembrosScreen(),
//           ),
//           GoRoute(
//             path: 'demandas',
//             builder: (context, state) => const DemandasScreen(),
//           ),
//         ],
//       ),
//     ],
//     redirect: (context, state) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final isLoggedIn = authProvider.isAuthenticated;
//       final isLoginRoute = state.matchedLocation == '/login';
//       final isSplashRoute = state.matchedLocation == '/splash';

//       // Se não estiver logado e não estiver na tela de login ou splash
//       if (!isLoggedIn && !isLoginRoute && !isSplashRoute) {
//         return '/login';
//       }

//       // Se estiver logado e estiver na tela de login
//       if (isLoggedIn && isLoginRoute) {
//         return '/';
//       }

//       return null;
//     },
//   );

//   @override
//   Widget build(BuildContext context) => MultiProvider(
//       providers: [
//         // Injetar ApiService nos providers
//         Provider<ApiService>.value(value: apiService),
//         ChangeNotifierProxyProvider<ApiService, AuthProvider>(
//           create: (context) => AuthProvider(apiService),
//           update: (context, apiService, previous) => 
//             previous ?? AuthProvider(apiService),
//         ),
//         ChangeNotifierProxyProvider<ApiService, ResponsavelProvider>(
//           create: (context) => ResponsavelProvider(),
//           update: (context, apiService, previous) => 
//             previous ?? ResponsavelProvider(),
//         ),
//         ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
//         ChangeNotifierProvider(create: (_) => ResponsavelProvider()),
//         ChangeNotifierProvider(create: (_) => MembroProvider()),
//         ChangeNotifierProvider(create: (_) => DemandaProvider()),
//       ],
//       child: MaterialApp.router(
//         title: 'Cadastro Unificado',
//         theme: AppTheme.lightTheme,
//         darkTheme: AppTheme.darkTheme,
//         themeMode: ThemeMode.system,
//         routerConfig: _router,
//         debugShowCheckedModeBanner: false,
//       ),
//     );
// }