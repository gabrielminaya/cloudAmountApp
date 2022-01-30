import 'package:cloudamountapp/domain/blocs/export_history_bloc/export_history_bloc.dart';
import 'package:cloudamountapp/domain/blocs/history_of_amount_bloc/history_of_amount_bloc.dart';
import 'package:cloudamountapp/domain/blocs/theme_mode_bloc/theme_mode_bloc.dart';
import 'package:cloudamountapp/ui/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => Modular.get<ExportHistoryBloc>(),
        ),
        BlocProvider(
          create: (context) => Modular.get<HistoryOfAmountBloc>(),
        ),
        BlocProvider(
          create: (context) => Modular.get<ThemeModeBloc>(),
        ),
      ],
      child: const HomeView(),
    );
  }
}
