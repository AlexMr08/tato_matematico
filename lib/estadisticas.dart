import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldAlumno.dart';
import 'package:tato_matematico/datos/estadistica.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';

import 'auxFunc.dart';
import 'datos/alumno.dart';

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  late EstadisticaJuego estadistica;
  int semanaSeleccionada = 0;
  int juegoSeleccionado = 1;

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

    return ScaffoldAlumno(
      alumno: alum,
      posicion: getPosicionBarra(alum.posicionBarra),
      textoCabecera: "Estadísticas",
      hasAjustes: false,
      hasEstadisticas: false,
      onVolver: () {
        Navigator.of(context).pop();
      },
      onAjustes: () {},
      onEstadisticas: () {},
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            spacing: 8,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  BotonConIcono(
                    icono: Icons.arrow_back,
                    texto: "Anterior",
                    onPressed:
                        (estadistica.estadisticasSemanales.isNotEmpty &&
                            semanaSeleccionada <
                                estadistica.estadisticasSemanales.length - 1)
                        ? () => semanaAnterior()
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          estadistica.estadisticasSemanales.isNotEmpty
                              ? "SEMANA ${_obtenerRangoSemana(estadistica.estadisticasSemanales[semanaSeleccionada].fecha)}"
                              : "SIN DATOS",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        Text(
                          stats != null
                              ? _nombreMes(stats.fecha.month)
                              : "Sin datos", // Muestra el mes real
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BotonConIcono(
                    iconAlignment: IconAlignment.end,
                    icono: Icons.arrow_forward,
                    texto: "Siguiente",
                    onPressed: (semanaSeleccionada > 0)
                        ? () => semanaSiguiente()
                        : null,
                  ),
                ],
              ),
              Expanded(
                child: estadistica.estadisticasSemanales.isNotEmpty
                    ? GraficoResultados(
                        aciertos: aciertos,
                        omisiones: omisiones,
                        errores: errores,
                        alum: alum,
                      )
                    : Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Expanded(
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
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  BotonConIcono(
                    icono: Icons.arrow_back,
                    texto: "Anterior",
                    onPressed: (juegoSeleccionado > 1)
                        ? () => juegoAnterior()
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Juego $juegoSeleccionado",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BotonConIcono(
                    iconAlignment: IconAlignment.end,
                    icono: Icons.arrow_forward,
                    texto: "Siguiente",
                    onPressed: (juegoSeleccionado < 4)
                        ? () => juegoSiguiente()
                        : null,
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

class GraficoResultados extends StatelessWidget {
  final int aciertos;
  final int omisiones;
  final int errores;
  final Alumno alum;

  const GraficoResultados({
    super.key,
    required this.aciertos,
    required this.omisiones,
    required this.errores,
    required this.alum,
  });

  @override
  Widget build(BuildContext context) {
    final double maxVal = [
      aciertos,
      omisiones,
      errores,
    ].reduce((curr, next) => curr > next ? curr : next).toDouble();

    final double maxY = maxVal == 0 ? 5 : maxVal + 1;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final style = TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    );

                    Widget text;
                    switch (value.toInt()) {
                      case 0:
                        text = Text('Bien', style: style);
                        break;
                      case 1:
                        text = Text('Omitido', style: style);
                        break;
                      case 2:
                        text = Text('Mal', style: style);
                        break;
                      default:
                        text = const Text('');
                    }

                    return SideTitleWidget(
                      meta: meta,
                      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                      child: text,
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return SideTitleWidget(
                      meta: meta,
                      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                      child: _getIconoPorIndice(value.toInt()),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              _crearGrupoBarra(
                0,
                aciertos.toDouble(),
                Colors.greenAccent.shade700,
                maxY,
              ),
              _crearGrupoBarra(
                1,
                omisiones.toDouble(),
                Colors.grey.shade400,
                maxY,
              ),
              _crearGrupoBarra(
                2,
                errores.toDouble(),
                Colors.redAccent.shade400,
                maxY,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getIconoPorIndice(int index) {
    switch (index) {
      case 0:
        return Icon(
          Icons.sentiment_very_satisfied,
          color: Colors.greenAccent.shade700,
          size: 40,
        );
      case 1:
        return Icon(Icons.help_outline, color: Colors.grey.shade600, size: 40);
      case 2:
        return Icon(
          Icons.sentiment_very_dissatisfied,
          color: Colors.redAccent.shade400,
          size: 40,
        );
      default:
        return const SizedBox();
    }
  }

  BarChartGroupData _crearGrupoBarra(
    int x,
    double y,
    Color color,
    double backgroundY,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 40,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: false,
            toY: backgroundY,
            color: Colors.grey.shade100,
          ),
        ),
      ],
    );
  }
}
