import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
// Importamos las pantallas de ajustes con los nombres correctos según tu estructura
import 'package:tato_matematico/juegos/juego_1/juego_1_ajustes_screen.dart';
import 'package:tato_matematico/juegos/juego_1/ajustes_sonidos_screen.dart';
import 'package:tato_matematico/ajustes/configColorAlumno.dart';
import 'package:tato_matematico/juegos/juego2/juego2Ajustes.dart';
import 'package:tato_matematico/juegos/juego3/juego3Ajustes.dart';

class AjustesGeneralesScreen extends StatelessWidget {
  const AjustesGeneralesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Escuchamos el holder por si cambian colores en tiempo real
    final alumnoHolder = Provider.of<AlumnoHolder>(context);
    final alumno = alumnoHolder.alumno;

    if (alumno == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final Color appBarColor = alumno.colorBarraNav ?? Theme.of(context).colorScheme.primary;
    final Color appBarTextColor = getTextColorForBackground(appBarColor);

    return Scaffold(
      backgroundColor: alumno.colorFondo,
      appBar: AppBar(
        title: Text('Ajustes del Perfil', style: TextStyle(color: appBarTextColor)),
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: appBarTextColor),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- FILA 1: AJUSTES GENERALES ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSettingsCard(
                      context,
                      'Colores',
                      Icons.palette,
                      alumno,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ConfigColorAlumno()),
                      ),
                    ),
                    const SizedBox(width: 25.0),
                    _buildSettingsCard(
                      context,
                      'Voz y Sonidos',
                      Icons.record_voice_over,
                      alumno,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AjustesSonidosScreen()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25.0),

                // --- FILA 2: AJUSTES DE JUEGOS ---
                Wrap(
                  spacing: 25.0,
                  runSpacing: 25.0,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildSettingsCard(
                      context,
                      'Juego 1\nNúmeros',
                      Icons.filter_1,
                      alumno,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Juego1AjustesScreen()),
                      ),
                    ),
                    _buildSettingsCard(
                      context,
                      'Juego 2\nOrden',
                      Icons.filter_2,
                      alumno,
                      () {
                        final j2 = alumnoHolder.listaJuegos['juego2'];
                        if (j2 != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Juego2Ajustes(juego: j2),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Juego 2 no disponible")),
                          );
                        }
                      },
                    ),
                    _buildSettingsCard(
                      context,
                      'Juego 3\nSecuencia',
                      Icons.filter_3,
                      alumno,
                      () {
                        final j3 = alumnoHolder.listaJuegos['juego3'];
                        if (j3 != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Juego3Ajustes(juego: j3),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Juego 3 no disponible")),
                          );
                        }
                      },
                    ),
                    _buildSettingsCard(context, 'Juego 4', Icons.filter_4, alumno, null, isDisabled: true),
                  ],
                ),
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
      Alumno alumno,
      VoidCallback? onTap,
      {bool isDisabled = false}
      ) {
    // Usamos el color de botones del alumno o el secundario del tema
    final Color baseColor = alumno.colorBotones ?? Theme.of(context).colorScheme.secondary;
    final Color cardColor = isDisabled ? Colors.grey.shade300 : baseColor;
    final Color contentColor = isDisabled ? Colors.grey.shade600 : getTextColorForBackground(cardColor);

    return SizedBox(
      width: 160,
      height: 160,
      child: Card(
        color: cardColor,
        elevation: isDisabled ? 0 : 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias, // Para que el InkWell respete el borde
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: contentColor),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: contentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
