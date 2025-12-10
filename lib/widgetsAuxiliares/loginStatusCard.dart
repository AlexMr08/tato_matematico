import 'package:flutter/material.dart';

/// Enum compartido para el estado del login.
enum EstadoLogin { normal, exito, error }

/// Tarjeta visual para saber el estado del login.
///
/// Cambia el icono, texto y color dependiendo del [estado].
class LoginStatusCard extends StatelessWidget {
  final EstadoLogin estado;
  final String mensajeNormal;
  final String mensajeError;
  final String mensajeExito;

  const LoginStatusCard({
    super.key,
    required this.estado,
    this.mensajeNormal = "Realiza la acción indicada.",
    this.mensajeError = "Inténtalo de nuevo.",
    this.mensajeExito = "¡Muy bien!",
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color colorFondo;
    Color colorBorde;
    Color colorTexto;
    IconData icono;
    String texto;

    switch (estado) {
      case EstadoLogin.error:
        colorFondo = colorScheme.errorContainer;
        colorBorde = colorScheme.error;
        colorTexto = colorScheme.onErrorContainer;
        icono = Icons.sentiment_very_dissatisfied_outlined;
        texto = mensajeError;
        break;

      case EstadoLogin.exito:
        colorFondo = Colors.green.shade100;
        colorBorde = Colors.green;
        colorTexto = Colors.green.shade900;
        icono = Icons.sentiment_very_satisfied_outlined;
        texto = mensajeExito;
        break;

      case EstadoLogin.normal:
      default:
        colorFondo = colorScheme.surfaceContainerHighest.withValues(alpha: .5);
        colorBorde = colorScheme.outlineVariant;
        colorTexto = colorScheme.onSurface;
        icono = Icons.touch_app_outlined;
        texto = mensajeNormal;
        break;
    }

    return Semantics(
      liveRegion: true, // Accesibilidad: Lee los cambios automáticamente
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorBorde, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: colorTexto, size: 32),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                texto,
                style: TextStyle(
                  color: colorTexto,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}