import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lms_rnd/blocs/auth/auth_bloc.dart';
import 'package:flutter_lms_rnd/blocs/course/course_bloc.dart';
import 'package:flutter_lms_rnd/blocs/course/course_event.dart';
import 'package:flutter_lms_rnd/blocs/theme/theme.dart';
import 'package:flutter_lms_rnd/blocs/theme/theme_notifier.dart';
import 'package:flutter_lms_rnd/blocs/user/user_bloc.dart';
import 'package:flutter_lms_rnd/repositories/auth_repository.dart';
import 'package:flutter_lms_rnd/repositories/user_repository.dart';
import 'package:flutter_lms_rnd/screens/auth/auth_screen.dart';
import 'package:flutter_lms_rnd/screens/common/dashboard_screen.dart';
import 'package:flutter_lms_rnd/screens/splash/splash_screen.dart';
import 'package:flutter_lms_rnd/services/api_service.dart';
import 'package:flutter_lms_rnd/services/token_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  final apiService = ApiService(); // ✅ Shared instance
  final authRepo = AuthRepository(apiService);
  final userRepo = UserRepository(apiService, tokenService: TokenService());

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(authRepository: authRepo, userRepository: userRepo),
    ),
  );
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  final AuthRepository authRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.userRepository,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepository)),
        BlocProvider<UserBloc>(create: (_) => UserBloc(userRepository)),
        BlocProvider<CourseBloc>(
          create: (context) {
            final bloc = CourseBloc();
            bloc.add(LoadCourses()); // Dispatch LoadCourses here
            return bloc;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Novac LMS',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeNotifier.themeMode,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/authscreen': (context) => const AuthScreen(),
          '/homescreen': (context) => DashboardScreen(),
        },
      ),
    );
  }
}
