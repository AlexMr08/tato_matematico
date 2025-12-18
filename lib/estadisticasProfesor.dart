import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/datos/estadistica.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';
import 'package:tato_matematico/widgetsAuxiliares/graficoResultados.dart';
import 'widgetsAuxiliares/ScaffoldComunV2.dart';
import 'datos/alumno.dart';

/// **Nombre de la Clase: `EstadisticasProfesor`**
///
/// **Descripción:** Clase que genera la vista de las estadisticas en la aplicacion para los profesores.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 14/12/2025
/// * **Último cambio:** Se ha mejorado la interfaz de usuario
///

class EstadisticasProfesor extends StatefulWidget {
  const EstadisticasProfesor({super.key});

  @override
  State<EstadisticasProfesor> createState() => _EstadisticasProfesorState();
}

class _EstadisticasProfesorState extends State<EstadisticasProfesor> {
  late EstadisticaJuego estadistica;
  int semanaSeleccionada = 0;
  int juegoSeleccionado = 1;

  late AlumnoHolder _alumnoHolder;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _alumnoHolder = context.read<AlumnoHolder>();
  }

  @override
  void dispose() {
    print("Limpiando AlumnoHolder al salir de EstadisticasProfesor");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _alumnoHolder.clear();
    });

    super.dispose();
  }

  void semanaAnterior() {
    if (semanaSeleccionada < estadistica.estadisticasSemanales.length - 1) {
      setState(() {
        semanaSeleccionada++;
      });
    }
  }

  void semanaSiguiente() {
    if (semanaSeleccionada > 0) {
      setState(() {
        semanaSeleccionada--;
      });
    }
  }

  void juegoAnterior() {
    if (juegoSeleccionado > 1) {
      setState(() {
        juegoSeleccionado--;
      });
    }
  }

  void juegoSiguiente() {
    if (juegoSeleccionado < 4) {
      setState(() {
        juegoSeleccionado++;
      });
    }
  }

  String _obtenerRangoSemana(DateTime fechaLunes) {
    // La fecha guardada es el Lunes. Calculamos el Domingo sumando 6 días.
    DateTime fechaDomingo = fechaLunes.add(const Duration(days: 6));

    // Formato simple: "8 - 14"
    String f(int n) => n.toString().padLeft(2, '0');
    return "${f(fechaLunes.day)} - ${f(fechaDomingo.day)}";
  }

  String _nombreMes(int mes) {
    const meses = [
      "",
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre",
    ];
    if (mes >= 1 && mes <= 12) return meses[mes];
    return "";
  }

  @override
  Widget build(BuildContext context) {
    Alumno alum = context.watch<AlumnoHolder>().alumno!;
    var estadisticasGenerales = context.watch<AlumnoHolder>().estadisticas;
    estadistica =
        estadisticasGenerales['juego$juegoSeleccionado'] ??
        EstadisticaJuego(
          juegoId: 'juego$juegoSeleccionado',
          estadisticasSemanales: [],
        );

    var stats = estadistica.estadisticasSemanales.isNotEmpty
        ? estadistica.estadisticasSemanales[semanaSeleccionada]
        : null;

    int aciertos = stats?.aciertos ?? 0;
    int omisiones = stats?.omisiones ?? 0;
    int errores = stats?.errores ?? 0;

    return ScaffoldComunV2(
      titulo: "Estadísticas del Alumno",
      subtitulo: alum.nombre,
      cuerpo: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            spacing: 8,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  Expanded(
                    child: BotonConIcono(
                      icono: Icons.arrow_back,
                      texto: "Semana anterior",
                      onPressed:
                          (estadistica.estadisticasSemanales.isNotEmpty &&
                              semanaSeleccionada <
                                  estadistica.estadisticasSemanales.length - 1)
                          ? () => semanaAnterior()
                          : null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          estadistica.estadisticasSemanales.isNotEmpty
                              ? "Semana ${_obtenerRangoSemana(estadistica.estadisticasSemanales[semanaSeleccionada].fecha)}"
                              : "Sin datos",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onTertiaryContainer,
                          ),
                        ),
                        Text(
                          stats != null
                              ? _nombreMes(stats.fecha.month)
                              : "Sin datos", // Muestra el mes real
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BotonConIcono(
                      iconAlignment: IconAlignment.end,
                      icono: Icons.arrow_forward,
                      texto: "Semana siguiente",
                      onPressed: (semanaSeleccionada > 0)
                          ? () => semanaSiguiente()
                          : null,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: estadistica.estadisticasSemanales.isNotEmpty
                    ? GraficoResultados(
                        aciertos: aciertos,
                        omisiones: omisiones,
                        errores: errores,
                        modoAlumno: false,
                      )
                    : Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sentiment_very_dissatisfied,
                                  size: 120,
                                  color: Colors.grey.shade600,
                                ),
                                Text(
                                  "No hay datos disponibles para este juego.",
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  Expanded(
                    child: BotonConIcono(
                      icono: Icons.arrow_back,
                      texto: "Juego anterior",
                      onPressed: (juegoSeleccionado > 1)
                          ? () => juegoAnterior()
                          : null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Juego $juegoSeleccionado",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BotonConIcono(
                      iconAlignment: IconAlignment.end,
                      icono: Icons.arrow_forward,
                      texto: "Juego siguiente",
                      onPressed: (juegoSeleccionado < 4)
                          ? () => juegoSiguiente()
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
