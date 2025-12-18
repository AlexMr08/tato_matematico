import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tato_matematico/auxFunc.dart';

/// **Nombre de la Clase: `BotonConIcono`**
///
/// **Descripción:** Clase que genera un boton con icono y texto personalizable para la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///
class BotonConIcono extends StatelessWidget {
  final dynamic icono;
  final String texto;
  final VoidCallback? onPressed;
  final IconAlignment? iconAlignment;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? radio;

  const BotonConIcono({
    super.key,
    required this.icono,
    required this.texto,
    required this.onPressed,
    this.iconAlignment,
    this.fontSize,
    this.fontWeight,
    this.radio,
  }) : assert(
         icono is IconData || icono is String,
         'El icono debe ser un String o un IconData',
       );

  @override
  Widget build(BuildContext context) {
    Widget widgetIcono;
    if (icono is IconData) {
      widgetIcono = Icon(
        icono,
        size: 18,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      );
    } else if (icono is String) {
      widgetIcono = SvgPicture.asset(
        icono,
        width: 18,
        height: 18,
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.onPrimaryContainer,
          BlendMode.srcIn,
        ),
      );
    } else {
      widgetIcono = SizedBox();
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: widgetIcono,
      iconAlignment: iconAlignment ?? IconAlignment.start,
      label: Text(
        texto,
        style: TextStyle(
          fontSize: fontSize ?? 14,
          fontWeight: fontWeight ?? FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radio ?? 24),
        ),
        elevation: 0,
      ),
    );
  }
}

/// **Nombre de la Clase: `BotonSinIcono`**
///
/// **Descripción:** Clase que genera un boton con texto personalizable para la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///
class BotonSinIcono extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? vertPadding;
  final double? horiPadding;
  final double? radius;
  final Color? colorFondo;

  const BotonSinIcono({
    super.key,
    required this.texto,
    required this.onPressed,
    this.fontSize,
    this.fontWeight,
    this.vertPadding,
    this.horiPadding,
    this.radius,
    this.colorFondo,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            colorFondo ?? Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: colorFondo != null
            ? getTextColorForBackground(colorFondo!)
            : Theme.of(context).colorScheme.onPrimaryContainer,
        padding: EdgeInsets.symmetric(
          vertical: vertPadding ?? 10,
          horizontal: horiPadding ?? 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 24),
        ),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: fontSize ?? 14,
          fontWeight: fontWeight ?? FontWeight.w500,
        ),
      ),
    );
  }
}

/// **Nombre de la Clase: `BotonIcono`**
///
/// **Descripción:** Clase que genera un boton con solo un icono personalizable para la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///
class BotonIcono extends StatelessWidget {
  final dynamic icono;
  final VoidCallback? onPressed;
  final Color? color;
  const BotonIcono({
    super.key,
    required this.icono,
    required this.onPressed,
    this.color,
  }) : assert(
         icono is IconData || icono is String,
         'Los iconos deben ser un String o un IconData, el alternativo puede ser null',
       );

  @override
  Widget build(BuildContext context) {
    Widget widgetIcono;
    if (icono is IconData) {
      widgetIcono = Icon(
        icono,
        color: color ?? Theme.of(context).colorScheme.primary,
      );
    } else if (icono is String) {
      widgetIcono = SvgPicture.asset(
        icono,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          color ?? Theme.of(context).colorScheme.primary,
          BlendMode.srcIn,
        ),
      );
    } else {
      widgetIcono = SizedBox();
    }

    return IconButton(
      padding: EdgeInsets.zero,
      icon: widgetIcono,
      color: Theme.of(context).colorScheme.primary,
      onPressed: onPressed,
    );
  }
}

/// **Nombre de la Clase: `BotonConIconoAlumno`**
///
/// **Descripción:** Clase que genera un boton con solo un icono personalizable para la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 14/12/2025
/// * **Último cambio:** Se ha corregido el color del texto en estado deshabilitado
///
class BotonConIconoAlumno extends StatelessWidget {
  final dynamic icono;
  final String texto;
  final VoidCallback? onPressed;
  final IconAlignment? iconAlignment;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? radio;

  // Nuevos parámetros
  final Color? colorFondo;
  final Color? colorTexto;
  final Color? colorDisabled;

  const BotonConIconoAlumno({
    super.key,
    required this.icono,
    required this.texto,
    required this.onPressed,
    this.iconAlignment,
    this.fontSize,
    this.fontWeight,
    this.radio,
    this.colorFondo,
    this.colorTexto,
    this.colorDisabled,
  }) : assert(
         icono is IconData || icono is String,
         'El icono debe ser un String o un IconData',
       );

  @override
  Widget build(BuildContext context) {
    Widget widgetIcono;
    if (icono is IconData) {
      widgetIcono = Icon(icono, size: 18);
    } else if (icono is String) {
      widgetIcono = Builder(
        builder: (context) {
          final colorActual = IconTheme.of(context).color;
          return SvgPicture.asset(
            icono,
            width: 18,
            height: 18,
            colorFilter: colorActual != null
                ? ColorFilter.mode(colorActual, BlendMode.srcIn)
                : null,
          );
        },
      );
    } else {
      widgetIcono = SizedBox();
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: widgetIcono,

      iconAlignment: iconAlignment ?? IconAlignment.start,
      label: Text(
        texto,
        style: TextStyle(
          fontSize: fontSize ?? 14,
          fontWeight: fontWeight ?? FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            colorFondo ?? Theme.of(context).colorScheme.primaryContainer,

        foregroundColor:
            colorTexto ??
            (colorFondo != null
                ? getTextColorForBackground(colorFondo!)
                : Theme.of(context).colorScheme.onPrimaryContainer),

        disabledForegroundColor: getTextColorForBackground(
          colorDisabled ?? Colors.grey,
        ),
        disabledBackgroundColor: Colors.grey.withAlpha(
          (255 / 100 * 35).floor(),
        ),

        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        elevation: 0,
      ),
    );
  }
}

/// **Nombre de la Clase: `BotonSinIconoAlumno`**
///
/// **Descripción:** Clase que genera un boton con solo un icono personalizable para la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 14/12/2025
/// * **Último cambio:** Corregido el color del texto en estado deshabilitado
///
class BotonSinIconoAlumno extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final IconAlignment? iconAlignment;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? radio;

  // Nuevos parámetros
  final Color? colorFondo;
  final Color? colorDisabled;

  const BotonSinIconoAlumno({
    super.key,
    required this.texto,
    required this.onPressed,
    this.iconAlignment,
    this.fontSize,
    this.fontWeight,
    this.radio,
    this.colorFondo,
    this.colorDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            colorFondo ?? Theme.of(context).colorScheme.primaryContainer,

        foregroundColor:
            colorFondo != null
                ? getTextColorForBackground(colorFondo!)
                : Theme.of(context).colorScheme.onPrimaryContainer,

        disabledForegroundColor: getTextColorForBackground(
          colorDisabled ?? Colors.grey,
        ),
        disabledBackgroundColor: Colors.grey.withAlpha(
          (255 / 100 * 35).floor(),
        ),

        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: onPressed == null
                ? Colors.transparent
                : (colorFondo ??
                      Theme.of(context).colorScheme.primaryContainer),
          ),
          borderRadius: BorderRadius.circular(radio ?? 24),
        ),
        elevation: 0,
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: fontSize ?? 14,
          fontWeight: fontWeight ?? FontWeight.w500,
        ),
      ),
    );
  }
}
