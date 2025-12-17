import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ajustes/ajustes_generales_screen.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/juegos/juego_1/juego_1_ajustes_screen.dart';
import 'package:tato_matematico/juegos/juego_1/juego_1_screen.dart';

class Juego1AjustesScreen extends StatelessWidget {
  final Juego1Settings initialSettings;
  final bool initialMostrarPuntuacion;

  const Juego1AjustesScreen({
    Key? key,
    required this.initialSettings,
    required this.initialMostrarPuntuacion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alumno = Provider.of<AlumnoHolder>(context, listen: false).alumno!;
    final Color appBarColor = alumno.colorBarraNav ?? Theme.of(context).colorScheme.primary;
    final Color appBarTextColor = getTextColorForBackground(appBarColor);

    return Scaffold(
      backgroundColor: alumno.colorFondo,
      appBar: AppBar(
        title: Text('Ajustes Juego 1', style: TextStyle(color: appBarTextColor)),
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: appBarTextColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 1.0,
          children: [
            _buildSettingsCard(
              context,
              'Ajustes números',
              Icons.format_list_numbered,
              () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AjustesNumerosScreen(
                      initialSettings: initialSettings,
                      initialMostrarPuntuacion: initialMostrarPuntuacion,
                    ),
                  ),
                );

                if (result is Map && context.mounted) {
                  Navigator.of(context).pop(result);
                }
              },
            ),
            _buildSettingsCard(
              context,
              'Ajustes Generales',
              Icons.settings,
              () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AjustesGeneralesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    final alumno = Provider.of<AlumnoHolder>(context, listen: false).alumno!;
    final Color cardColor = alumno.colorBotones ?? Theme.of(context).colorScheme.secondary;
    final Color contentColor = getTextColorForBackground(cardColor);

    return InkWell(
      onTap: onTap,
      child: Card(
        color: cardColor,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 90,
              color: contentColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: contentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
