import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/scorm/scorm_bloc.dart';
import 'repositories/auth_repository.dart';
import 'repositories/scorm_repository.dart';
import 'services/api_service.dart';
import 'screens/app_splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(AuthRepository(ApiService())),
        ),
        BlocProvider<ScormBloc>(
          create: (context) => ScormBloc(ScormRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LMS Product',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AppSplashScreen(),
      ),
    );
  }
}
