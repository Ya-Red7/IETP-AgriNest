import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../widgets/auth_wrapper.dart';
import '../core/utils/constants.dart';

final appRouter = GoRouter(
  initialLocation: AppConstants.authRoute,
  routes: [
    GoRoute(
      path: AppConstants.authRoute,
      builder: (context, state) => const AuthWrapper(),
    ),
    GoRoute(
      path: AppConstants.splashRoute,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppConstants.loginRoute,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppConstants.signupRoute,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppConstants.homeRoute,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppConstants.analyticsRoute,
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: AppConstants.settingsRoute,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppConstants.editProfileRoute,
      builder: (context, state) => const EditProfileScreen(),
    ),
  ],
);
