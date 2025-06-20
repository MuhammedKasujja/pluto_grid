import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// final hasAccentColor = state.hasAccentColor;
// final accentColor = state.accentColor;
// // const accentColor = Color(0xFFFF9F43);
// const fontFamily = kIsWeb ? 'Roboto' : null;
// const pageTransitionsTheme = PageTransitionsTheme(builders: {
//   TargetPlatform.android: ZoomPageTransitionsBuilder(),
// });

// final textButtonTheme = TextButton.styleFrom(
//   minimumSize: const Size(88, 36),
//   padding: const EdgeInsets.symmetric(horizontal: 16),
//   shape: const RoundedRectangleBorder(
//     borderRadius: BorderRadius.all(Radius.circular(kBorderRadius)),
//   ),
// );

// final outlinedButtonTheme = OutlinedButton.styleFrom(
//   foregroundColor:
//       state.prefState.enableDarkMode ? Colors.white : Colors.black87,
// );

/// The [AppTheme] defines light and dark themes for the app.
///
/// Theme setup for FlexColorScheme package v8.
/// Use same major flex_color_scheme package version. If you use a
/// lower minor version, some properties may not be supported.
/// In that case, remove them after copying this theme to your
/// app or upgrade package to version 8.1.0.
///
/// Use in [MaterialApp] like this:
///
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///     :
/// );
abstract final class AppTheme {
  // The defined light theme.
  static ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.aquaBlue,
    // scheme: FlexScheme.flutterDash,
    // colors: const FlexSchemeColor(
    //   primary: Color(0xFF34A0CA),
    //   primaryContainer: Color(0xFFD0E4FF),
    //   secondary: Color(0xFFAC3306),
    //   secondaryContainer: Color(0xFFFFDBCF),
    //   tertiary: Color(0xFF006875),
    //   tertiaryContainer: Color(0xFF95F0FF),
    //   appBarColor: Color(0xFFFFDBCF),
    //   error: Color(0xFFBA1A1A),
    //   errorContainer: Color(0xFFFFDAD6),
    // ),
    surfaceMode: FlexSurfaceMode.highScaffoldLevelSurface,
    blendLevel: 22,
    appBarStyle: FlexAppBarStyle.scaffoldBackground,
    bottomAppBarElevation: 1.0,
    lightIsWhite: true,
    scaffoldBackground: const Color(0xFFF1F3F4),
    // surface: const Color(0xFFEBEBEB),
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      textButtonRadius: 4.0,
      filledButtonRadius: 4.0,
      elevatedButtonRadius: 4.0,
      elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
      elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
      outlinedButtonRadius: 4.0,
      segmentedButtonSchemeColor: SchemeColor.primary,
      checkboxSchemeColor: SchemeColor.primary,
      inputDecoratorSchemeColor: SchemeColor.primary,
      inputDecoratorIsDense: true,
      inputDecoratorBackgroundAlpha: 21,
      inputDecoratorBorderType: FlexInputBorderType.underline,
      inputDecoratorRadius: 8.0,
      inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
      outlinedButtonOutlineSchemeColor: SchemeColor.primary,
      fabSchemeColor: SchemeColor.tertiary,
      chipBlendColors: true,
      popupMenuRadius: 6.0,
      popupMenuElevation: 4.0,
      alignedDropdown: true,
      dialogElevation: 3.0,
      dialogRadius: 20.0,
      snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
      drawerIndicatorSchemeColor: SchemeColor.primary,
      bottomSheetRadius: 20.0,
      bottomSheetElevation: 2.0,
      bottomSheetModalElevation: 3.0,
      bottomNavigationBarMutedUnselectedLabel: false,
      bottomNavigationBarMutedUnselectedIcon: false,
      bottomNavigationBarBackgroundSchemeColor: SchemeColor.surfaceContainer,
      menuRadius: 6.0,
      menuElevation: 4.0,
      menuBarRadius: 0.0,
      menuBarElevation: 1.0,
      searchBarElevation: 3.0,
      searchViewElevation: 3.0,
      searchUseGlobalShape: true,
      navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
      navigationBarSelectedIconSchemeColor: SchemeColor.surface,
      navigationBarIndicatorSchemeColor: SchemeColor.primary,
      navigationBarBackgroundSchemeColor: SchemeColor.surface,
      navigationBarElevation: 1.0,
      navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
      navigationRailSelectedIconSchemeColor: SchemeColor.surface,
      navigationRailUseIndicator: true,
      navigationRailIndicatorSchemeColor: SchemeColor.primary,
      navigationRailIndicatorOpacity: 1.00,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    fontFamily: GoogleFonts.notoSans().fontFamily,
    swapLegacyOnMaterial3: true,
  );
  // The defined dark theme.
  static ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.aquaBlue,
    //  colors: const FlexSchemeColor(
    //   primary: Color(0xFF9FC9FF),
    //   primaryContainer: Color(0xFF00325B),
    //   primaryLightRef: Color(0xFF34A0CA), // The color of light mode primary
    //   secondary: Color(0xFFFFB59D),
    //   secondaryContainer: Color(0xFF872100),
    //   secondaryLightRef: Color(0xFFAC3306), // The color of light mode secondary
    //   tertiary: Color(0xFF86D2E1),
    //   tertiaryContainer: Color(0xFF004E59),
    //   tertiaryLightRef: Color(0xFF006875), // The color of light mode tertiary
    //   appBarColor: Color(0xFFFFDBCF),
    //   error: Color(0xFFFFB4AB),
    //   errorContainer: Color(0xFF93000A),
    // ),
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 18,
    appBarStyle: FlexAppBarStyle.scaffoldBackground,
    bottomAppBarElevation: 2.0,
    darkIsTrueBlack: true,
    scaffoldBackground: const Color(0xFF1F1F1F),
    // surface: const Color(0xFF292826),
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      textButtonRadius: 4.0,
      filledButtonRadius: 4.0,
      elevatedButtonRadius: 4.0,
      elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
      elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
      outlinedButtonRadius: 4.0,
      segmentedButtonSchemeColor: SchemeColor.primary,
      checkboxSchemeColor: SchemeColor.primary,
      inputDecoratorSchemeColor: SchemeColor.primary,
      inputDecoratorIsDense: true,
      inputDecoratorBackgroundAlpha: 43,
      inputDecoratorBorderType: FlexInputBorderType.underline,
      inputDecoratorRadius: 8.0,
      inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
      outlinedButtonOutlineSchemeColor: SchemeColor.primary,
      fabSchemeColor: SchemeColor.tertiary,
      chipBlendColors: true,
      popupMenuRadius: 6.0,
      popupMenuElevation: 4.0,
      alignedDropdown: true,
      dialogElevation: 3.0,
      dialogRadius: 20.0,
      snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
      drawerIndicatorSchemeColor: SchemeColor.primary,
      bottomSheetRadius: 20.0,
      bottomSheetElevation: 2.0,
      bottomSheetModalElevation: 3.0,
      bottomNavigationBarMutedUnselectedLabel: false,
      bottomNavigationBarMutedUnselectedIcon: false,
      bottomNavigationBarBackgroundSchemeColor: SchemeColor.surfaceContainer,
      menuRadius: 6.0,
      menuElevation: 4.0,
      menuBarRadius: 0.0,
      menuBarElevation: 1.0,
      searchBarElevation: 3.0,
      searchViewElevation: 3.0,
      searchUseGlobalShape: true,
      navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
      navigationBarSelectedIconSchemeColor: SchemeColor.surface,
      navigationBarIndicatorSchemeColor: SchemeColor.primary,
      navigationBarBackgroundSchemeColor: SchemeColor.surface,
      navigationBarElevation: 1.0,
      navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
      navigationRailSelectedIconSchemeColor: SchemeColor.surface,
      navigationRailUseIndicator: true,
      navigationRailIndicatorSchemeColor: SchemeColor.primary,
      navigationRailIndicatorOpacity: 1.00,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    fontFamily: GoogleFonts.notoSans().fontFamily,
    swapLegacyOnMaterial3: true,
  );
}