import 'package:cloudamountapp/core/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'domain/blocs/theme_mode_bloc/theme_mode_bloc.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeModeBloc, ThemeModeState>(
      bloc: Modular.get<ThemeModeBloc>(),
      builder: (context, state) {
        ThemeData themeData;

        if (state is ThemeModeDark) {
          themeData = darkTheme;
        } else if (state is ThemeModeLight) {
          themeData = lightTheme;
        } else {
          themeData = lightTheme;
        }

        return MaterialApp(
          title: 'Amount History',
          locale: context.locale,
          localizationsDelegates: [
            ...context.localizationDelegates,
            FormBuilderLocalizations.delegate,
          ],
          supportedLocales: context.supportedLocales,
          theme: themeData,
        ).modular();
      },
    );
  }
}
