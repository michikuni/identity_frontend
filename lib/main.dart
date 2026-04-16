import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/routes/app_router.dart';
import 'package:identity_frontend/core/themes/app_theme.dart';
import 'package:identity_frontend/domain/usecases/auth/sign_in_usecase.dart';
import 'package:identity_frontend/domain/usecases/auth/sign_up_usecase.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/presentation/features/auth/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Wire up all dependencies
  await configureDependencies();

  runApp(const TrustIdApp());
}

class TrustIdApp extends StatelessWidget {
  const TrustIdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            signInUseCase: sl<SignInUseCase>(),
            signUpUseCase: sl<SignUpUseCase>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'TrustID',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'), // default to Vietnamese; user can switch
      ),
    );
  }
}
