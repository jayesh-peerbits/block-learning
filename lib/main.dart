  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:hive_flutter/adapters.dart';
  import 'package:real_time_expense/screens/dashboard_screen.dart';
  import 'package:real_time_expense/screens/login_screen.dart';
  import 'package:real_time_expense/services/notification_services.dart';

  import 'blocks/auth/aurh_state.dart';
  import 'blocks/auth/auth_block.dart';
  import 'blocks/transaction/transition_block.dart';
  import 'firebase_options.dart';
import 'models/transaction.dart';
import 'models/user.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(  options: DefaultFirebaseOptions.currentPlatform,
    );
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter()); // Register User adapter
    Hive.registerAdapter(TransactionAdapter()); // Register Transaction adapter
    await NotificationService.init();
    runApp(MyApp());
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc()),
          BlocProvider(create: (_) => TransactionBloc()),
        ],
        child: MaterialApp(
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: ThemeMode.system,
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return state.isAuthenticated ? DashboardScreen() : LoginScreen();
            },
          ),
        ),
      );
    }
  }