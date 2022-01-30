import 'package:cloudamountapp/domain/blocs/theme_mode_bloc/theme_mode_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'data/repositories/history_repository.dart';
import 'domain/blocs/export_history_bloc/export_history_bloc.dart';
import 'domain/blocs/history_of_amount_bloc/history_of_amount_bloc.dart';
import 'ui/pages/home_page.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds {
    return [
      // repositories
      Bind.lazySingleton((i) => HistoryRepository()),
      // blocs
      Bind.lazySingleton((i) => ThemeModeBloc()),
      Bind.factory((i) => ExportHistoryBloc()),
      Bind.factory((i) => HistoryOfAmountBloc(i()))
    ];
  }

  @override
  List<ModularRoute> get routes {
    return [
      ChildRoute("/", child: (context, arg) => const HomePage()),
    ];
  }
}
