import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/locale/locale_cubit.dart';
import 'package:identity_frontend/core/routes/app_router.dart';
import 'package:identity_frontend/core/themes/app_theme.dart';
import 'package:identity_frontend/domain/usecases/auth/sign_in_usecase.dart';
import 'package:identity_frontend/domain/usecases/auth/sign_up_usecase.dart';
import 'package:identity_frontend/l10n/app_localizations.dart';
import 'package:identity_frontend/presentation/features/auth/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  await configureDependencies();

  final localeCubit = LocaleCubit();
  await localeCubit.load();

  runApp(TrustIdApp(localeCubit: localeCubit));
}

class TrustIdApp extends StatelessWidget {
  final LocaleCubit localeCubit;
  const TrustIdApp({super.key, required this.localeCubit});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>.value(value: localeCubit),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            signInUseCase: sl<SignInUseCase>(),
            signUpUseCase: sl<SignUpUseCase>(),
          ),
        ),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) => MaterialApp.router(
          title: 'TrustID',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: appRouter,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
        ),
      ),
    );
  }
}
