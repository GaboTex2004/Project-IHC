import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'injection/injection.dart' as di;
import 'theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/lost_pets/presentation/bloc/lost_pet_bloc.dart';
import 'features/lost_pets/domain/usecases/list_reports_usecase.dart';
import 'features/lost_pets/domain/usecases/create_report_usecase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  di.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const PetTrackApp());
}

class PetTrackApp extends StatelessWidget {
  const PetTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            loginUseCase: di.sl<LoginUseCase>(),
            registerUseCase: di.sl<RegisterUseCase>(),
          ),
        ),
        BlocProvider(
          create: (_) => LostPetBloc(
            listReportsUseCase: di.sl<ListReportsUseCase>(),
            createReportUseCase: di.sl<CreateReportUseCase>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: dotenv.env['SYSTEM_NAME'] ?? 'Pet Track',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginPage(),
      ),
    );
  }
}
