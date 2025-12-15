import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/juegos/juego_1/ajustes_numeros_screen.dart';
import 'package:tato_matematico/juegos/juego_1/ajustes_sonidos_screen.dart';
import 'package:tato_matematico/ajustes/configColorAlumno.dart';
import 'package:tato_matematico/juegos/juego2/juego2Ajustes.dart'; // Importante para ajustes juego 2

class AjustesGeneralesScreen extends StatelessWidget {
  const AjustesGeneralesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alumnoHolder = Provider.of<AlumnoHolder>(context, listen: false);
    final alumno = alumnoHolder.alumno!;
    final Color appBarColor = alumno.colorBarraNav ?? Theme.of(context).colorScheme.primary;
    final Color appBarTextColor = getTextColorForBackground(appBarColor);

    return Scaffold(
      backgroundColor: alumno.colorFondo,
      appBar: AppBar(
        title: Text('Ajustes Generales', style: TextStyle(color: appBarTextColor)),
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: appBarTextColor),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Wrap(
              spacing: 30.0, // Más espacio horizontal
              runSpacing: 30.0, // Más espacio vertical
              alignment: WrapAlignment.center,
              children: [
                _buildSettingsCard(
                  context,
                  'Color',
                  Icons.color_lens,
                      () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ConfigColorAlumno()),
                  ),
                ),
                _buildSettingsCard(
                  context,
                  'Sonidos',
                  Icons.music_note,
                      () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AjustesSonidosScreen()),
                  ),
                ),
                _buildSettingsCard(
                  context,
                  'Juego 1',
                  Icons.looks_one,
                      () {
                    final alumno = Provider.of<AlumnoHolder>(context, listen: false).alumno!;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AjustesNumerosScreen(
                          initialSettings: alumno.juego1Settings,
                          initialMostrarPuntuacion: alumno.mostrarPuntuacionJuego1,
                        ),
                      ),
                    );
                  },
                ),
                _buildSettingsCard(
                  context,
                  'Juego 2',
                  Icons.looks_two,
                      () {
                    // Obtenemos el juego del holder para pasarlo a los ajustes
                    if (alumnoHolder.juego2 != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AjustesJuegoLandscape(
                            juego: alumnoHolder.juego2!,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Error: Juego 2 no inicializado")),
                      );
                    }
                  },
                  isDisabled: false, // Habilitado
                ),
                _buildSettingsCard(context, 'Juego 3', Icons.looks_3, null, isDisabled: true),
                _buildSettingsCard(context, 'Juego 4', Icons.looks_4, null, isDisabled: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback? onTap,
      {bool isDisabled = false}
      ) {
    final alumno = Provider.of<AlumnoHolder>(context, listen: false).alumno!;
    final Color cardColor = (isDisabled ? Colors.grey.shade400 : (alumno.colorBotones ?? Theme.of(context).colorScheme.secondary));
    final Color contentColor = getTextColorForBackground(cardColor);

    // Tamaño aumentado para que los elementos se vean más grandes
    return SizedBox(
      width: 170,
      height: 140,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        child: Card(
          color: cardColor,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 55, // Icono más grande
                color: contentColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20, // Texto más grande
                  fontWeight: FontWeight.bold,
                  color: contentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}