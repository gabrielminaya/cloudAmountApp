import 'package:flex_color_scheme/flex_color_scheme.dart';

final lightTheme = FlexThemeData.light(
  scheme: FlexScheme.shark,
  surfaceMode: FlexSurfaceMode.level,
  blendLevel: 18,
  appBarStyle: FlexAppBarStyle.primary,
  appBarOpacity: 1,
  appBarElevation: 1,
  transparentStatusBar: true,
  tabBarStyle: FlexTabBarStyle.forAppBar,
  tooltipsMatchBackground: true,
  swapColors: false,
  lightIsWhite: true,
  useSubThemes: true,
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  // To use playground font, add GoogleFonts package and uncomment:
  // fontFamily: GoogleFonts.notoSans().fontFamily,
  subThemesData: const FlexSubThemesData(
    useTextTheme: true,
    defaultRadius: 5,
    fabUseShape: true,
    interactionEffects: true,
    bottomNavigationBarElevation: 0,
    bottomNavigationBarOpacity: 1,
    navigationBarOpacity: 1,
    navigationBarMutedUnselectedText: true,
    navigationBarMutedUnselectedIcon: true,
    inputDecoratorIsFilled: true,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    inputDecoratorUnfocusedHasBorder: true,
    blendOnColors: true,
    blendTextTheme: true,
    popupMenuOpacity: 0.95,
  ),
);

final darkTheme = FlexThemeData.dark(
  scheme: FlexScheme.shark,
  surfaceMode: FlexSurfaceMode.level,
  blendLevel: 18,
  appBarStyle: FlexAppBarStyle.background,
  appBarOpacity: 1,
  appBarElevation: 1,
  transparentStatusBar: true,
  tabBarStyle: FlexTabBarStyle.forAppBar,
  tooltipsMatchBackground: true,
  swapColors: false,
  darkIsTrueBlack: false,
  useSubThemes: true,
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  // To use playground font, add GoogleFonts package and uncomment:
  // fontFamily: GoogleFonts.notoSans().fontFamily,
  subThemesData: const FlexSubThemesData(
    useTextTheme: true,
    defaultRadius: 5,
    fabUseShape: true,
    interactionEffects: true,
    bottomNavigationBarElevation: 0,
    bottomNavigationBarOpacity: 1,
    navigationBarOpacity: 1,
    navigationBarMutedUnselectedText: true,
    navigationBarMutedUnselectedIcon: true,
    inputDecoratorIsFilled: true,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    inputDecoratorUnfocusedHasBorder: true,
    blendOnColors: true,
    blendTextTheme: true,
    popupMenuOpacity: 0.95,
  ),
);
