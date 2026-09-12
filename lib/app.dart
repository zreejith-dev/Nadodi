import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/auth_provider.dart';
import 'features/places/places_provider.dart';
import 'features/hidden/hidden_provider.dart';
import 'shared/models/place.dart';
import 'shared/services/data_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/place_detail_screen.dart';
import 'screens/hidden_places_screen.dart';
import 'screens/saved_places_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/map_screen.dart';
import 'screens/auth_screen.dart';
import 'theme/app_theme.dart';

class AppRoutes {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String placeDetail = '/place-detail';
  static const String hidden = '/hidden';
  static const String saved = '/saved';
  static const String profile = '/profile';
  static const String map = '/map';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen());
      case auth:
        return _fadeRoute(const AuthScreen());
      case home:
        return _fadeRoute(const HomeScreen());
      case placeDetail:
        final place = settings.arguments as TouristPlace?;
        if (place == null) {
          return _fadeRoute(const Scaffold(body: Center(child: Text('Invalid place'))));
        }
        return _fadeRoute(PlaceDetailScreen(place: place));
      case hidden:
        return _fadeRoute(const HiddenPlacesScreen());
      case saved:
        return _fadeRoute(const SavedPlacesScreen());
      case profile:
        return _fadeRoute(const ProfileScreen());
      case map:
        return _fadeRoute(const MapScreen());
      default:
        return _fadeRoute(
          Scaffold(body: Center(child: Text('No route: ${settings.name}'))),
        );
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}

class NadodiApp extends StatelessWidget {
  const NadodiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => SupabaseService()),
        Provider(create: (_) => DataService()),
        ChangeNotifierProxyProvider<SupabaseService, AuthProvider>(
          create: (_) => AuthProvider(),
          update: (_, supabase, auth) => auth..initialize(),
        ),
        ChangeNotifierProxyProvider<DataService, PlacesProvider>(
          create: (_) => PlacesProvider(),
          update: (_, data, places) => places..loadData(),
        ),
        ChangeNotifierProxyProvider<DataService, HiddenSpotsProvider>(
          create: (_) => HiddenSpotsProvider(),
          update: (_, data, hidden) => hidden..loadData(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Nadodi - Kerala Tourism',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: ThemeMode.system,
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: AppRoutes.splash,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
