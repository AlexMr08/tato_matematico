import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff35693e),
      surfaceTint: Color(0xff35693e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffb7f1ba),
      onPrimaryContainer: Color(0xff1c5128),
      secondary: Color(0xff516351),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffd4e8d1),
      onSecondaryContainer: Color(0xff3a4b3a),
      tertiary: Color(0xff39656d),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffbdeaf3),
      onTertiaryContainer: Color(0xff1f4d54),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff7fbf2),
      onSurface: Color(0xff181d18),
      onSurfaceVariant: Color(0xff424941),
      outline: Color(0xff727970),
      outlineVariant: Color(0xffc1c9be),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d322c),
      inversePrimary: Color(0xff9cd49f),
      primaryFixed: Color(0xffb7f1ba),
      onPrimaryFixed: Color(0xff002109),
      primaryFixedDim: Color(0xff9cd49f),
      onPrimaryFixedVariant: Color(0xff1c5128),
      secondaryFixed: Color(0xffd4e8d1),
      onSecondaryFixed: Color(0xff0f1f11),
      secondaryFixedDim: Color(0xffb8ccb6),
      onSecondaryFixedVariant: Color(0xff3a4b3a),
      tertiaryFixed: Color(0xffbdeaf3),
      onTertiaryFixed: Color(0xff001f24),
      tertiaryFixedDim: Color(0xffa1ced7),
      onTertiaryFixedVariant: Color(0xff1f4d54),
      surfaceDim: Color(0xffd7dbd3),
      surfaceBright: Color(0xfff7fbf2),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff1f5ec),
      surfaceContainer: Color(0xffebefe7),
      surfaceContainerHigh: Color(0xffe5e9e1),
      surfaceContainerHighest: Color(0xffe0e4db),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff073f19),
      surfaceTint: Color(0xff35693e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff44784c),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff293a2a),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5f725f),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff083c43),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff48747c),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff7fbf2),
      onSurface: Color(0xff0e120e),
      onSurfaceVariant: Color(0xff313830),
      outline: Color(0xff4d544c),
      outlineVariant: Color(0xff686f66),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d322c),
      inversePrimary: Color(0xff9cd49f),
      primaryFixed: Color(0xff44784c),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff2c5f35),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff5f725f),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff475948),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff48747c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff2f5b63),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc3c8c0),
      surfaceBright: Color(0xfff7fbf2),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff1f5ec),
      surfaceContainer: Color(0xffe5e9e1),
      surfaceContainerHigh: Color(0xffdaded6),
      surfaceContainerHighest: Color(0xffcfd3cb),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003412),
      surfaceTint: Color(0xff35693e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff1f532b),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff1f3021),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff3c4d3c),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003138),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff224f57),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff7fbf2),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff272e27),
      outlineVariant: Color(0xff444b43),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d322c),
      inversePrimary: Color(0xff9cd49f),
      primaryFixed: Color(0xff1f532b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff023c16),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff3c4d3c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff263727),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff224f57),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff033840),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb6bab2),
      surfaceBright: Color(0xfff7fbf2),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeef2ea),
      surfaceContainer: Color(0xffe0e4db),
      surfaceContainerHigh: Color(0xffd1d6ce),
      surfaceContainerHighest: Color(0xffc3c8c0),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff9cd49f),
      surfaceTint: Color(0xff9cd49f),
      onPrimary: Color(0xff003914),
      primaryContainer: Color(0xff1c5128),
      onPrimaryContainer: Color(0xffb7f1ba),
      secondary: Color(0xffb8ccb6),
      onSecondary: Color(0xff243425),
      secondaryContainer: Color(0xff3a4b3a),
      onSecondaryContainer: Color(0xffd4e8d1),
      tertiary: Color(0xffa1ced7),
      onTertiary: Color(0xff00363d),
      tertiaryContainer: Color(0xff1f4d54),
      onTertiaryContainer: Color(0xffbdeaf3),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff101510),
      onSurface: Color(0xffe0e4db),
      onSurfaceVariant: Color(0xffc1c9be),
      outline: Color(0xff8b9389),
      outlineVariant: Color(0xff424941),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e4db),
      inversePrimary: Color(0xff35693e),
      primaryFixed: Color(0xffb7f1ba),
      onPrimaryFixed: Color(0xff002109),
      primaryFixedDim: Color(0xff9cd49f),
      onPrimaryFixedVariant: Color(0xff1c5128),
      secondaryFixed: Color(0xffd4e8d1),
      onSecondaryFixed: Color(0xff0f1f11),
      secondaryFixedDim: Color(0xffb8ccb6),
      onSecondaryFixedVariant: Color(0xff3a4b3a),
      tertiaryFixed: Color(0xffbdeaf3),
      onTertiaryFixed: Color(0xff001f24),
      tertiaryFixedDim: Color(0xffa1ced7),
      onTertiaryFixedVariant: Color(0xff1f4d54),
      surfaceDim: Color(0xff101510),
      surfaceBright: Color(0xff363a35),
      surfaceContainerLowest: Color(0xff0b0f0b),
      surfaceContainerLow: Color(0xff181d18),
      surfaceContainer: Color(0xff1c211c),
      surfaceContainerHigh: Color(0xff262b26),
      surfaceContainerHighest: Color(0xff313630),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb1eab4),
      surfaceTint: Color(0xff9cd49f),
      onPrimary: Color(0xff002d0e),
      primaryContainer: Color(0xff679d6d),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffcee2cb),
      onSecondary: Color(0xff19291a),
      secondaryContainer: Color(0xff839681),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffb7e4ed),
      onTertiary: Color(0xff002a30),
      tertiaryContainer: Color(0xff6c98a0),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff101510),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd7ded3),
      outline: Color(0xffadb4aa),
      outlineVariant: Color(0xff8b9289),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e4db),
      inversePrimary: Color(0xff1e5229),
      primaryFixed: Color(0xffb7f1ba),
      onPrimaryFixed: Color(0xff001504),
      primaryFixedDim: Color(0xff9cd49f),
      onPrimaryFixedVariant: Color(0xff073f19),
      secondaryFixed: Color(0xffd4e8d1),
      onSecondaryFixed: Color(0xff051407),
      secondaryFixedDim: Color(0xffb8ccb6),
      onSecondaryFixedVariant: Color(0xff293a2a),
      tertiaryFixed: Color(0xffbdeaf3),
      onTertiaryFixed: Color(0xff001417),
      tertiaryFixedDim: Color(0xffa1ced7),
      onTertiaryFixedVariant: Color(0xff083c43),
      surfaceDim: Color(0xff101510),
      surfaceBright: Color(0xff414640),
      surfaceContainerLowest: Color(0xff050805),
      surfaceContainerLow: Color(0xff1a1f1a),
      surfaceContainer: Color(0xff242924),
      surfaceContainerHigh: Color(0xff2f342e),
      surfaceContainerHighest: Color(0xff3a3f39),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffc4fec7),
      surfaceTint: Color(0xff9cd49f),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff98d09c),
      onPrimaryContainer: Color(0xff000f03),
      secondary: Color(0xffe1f6de),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffb4c8b2),
      onSecondaryContainer: Color(0xff020e04),
      tertiary: Color(0xffcff7ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff9dcad3),
      onTertiaryContainer: Color(0xff000e10),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff101510),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffebf2e7),
      outlineVariant: Color(0xffbdc5ba),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e4db),
      inversePrimary: Color(0xff1e5229),
      primaryFixed: Color(0xffb7f1ba),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff9cd49f),
      onPrimaryFixedVariant: Color(0xff001504),
      secondaryFixed: Color(0xffd4e8d1),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffb8ccb6),
      onSecondaryFixedVariant: Color(0xff051407),
      tertiaryFixed: Color(0xffbdeaf3),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffa1ced7),
      onTertiaryFixedVariant: Color(0xff001417),
      surfaceDim: Color(0xff101510),
      surfaceBright: Color(0xff4d514b),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1c211c),
      surfaceContainer: Color(0xff2d322c),
      surfaceContainerHigh: Color(0xff383d37),
      surfaceContainerHighest: Color(0xff434842),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
