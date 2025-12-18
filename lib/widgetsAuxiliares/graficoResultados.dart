import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// **Nombre de la Clase: `GraficoResultados`**
///
/// **Descripción:** Clase que genera el gráfico de barras para mostrar los resultados de aciertos, omisiones y errores.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 13/12/2025
/// * **Último cambio:** Se ha creado la clase y su funcionalidad
///

class GraficoResultados extends StatelessWidget {
  final int aciertos;
  final int omisiones;
  final int errores;
  final bool modoAlumno;

  const GraficoResultados({
    super.key,
    required this.aciertos,
    required this.omisiones,
    required this.errores,
    required this.modoAlumno,
  });

  // Función para determinar el mensaje y el color según el resultado mayor
  Map<String, dynamic> _obtenerFeedback() {
    if (aciertos == omisiones && aciertos == errores) {
      return {
        'texto': 'Buen trabajo, ¡sigue practicando!',
        'color': Colors.blueAccent, // Color neutro
        'icono': Icons.balance_rounded,
      };
    } else if (aciertos >= omisiones && aciertos >= errores) {
      return {
        'texto': '¡Genial! ¡Sigue así, lo estás haciendo muy bien!',
        'color': Colors.greenAccent.shade700,
        'icono': Icons.star_rounded,
      };
    } else if (omisiones >= aciertos && omisiones >= errores) {
      return {
        'texto': '¡Anímate a intentarlo! Equivocarse es parte de aprender.',
        'color': Colors.orangeAccent.shade700,
        'icono': Icons.lightbulb_rounded,
      };
    } else {
      return {
        'texto': '¡No te rindas! Con un poco más de práctica lo conseguirás.',
        'color': Colors.redAccent.shade400,
        'icono': Icons.fitness_center_rounded,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si quieres que la escala sea fija a 100, descomenta esta línea y comenta las de abajo
    // const double maxY = 100.0;

    final double maxVal = [
      aciertos,
      omisiones,
      errores,
    ].reduce((curr, next) => curr > next ? curr : next).toDouble();

    final double maxY = maxVal == 0 ? 5 : maxVal + 1;

    // Obtenemos el feedback
    final feedback = _obtenerFeedback();
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- INICIO DEL MENSAJE MOTIVACIONAL ---
            modoAlumno
                ? Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: (feedback['color'] as Color).withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: (feedback['color'] as Color)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          feedback['icono'],
                          color: feedback['color'],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feedback['texto'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: feedback['color'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
            // --- FIN DEL MENSAJE MOTIVACIONAL ---

            // El gráfico necesita un tamaño definido dentro de una columna
            Expanded(
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
                          const style = TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          );

                          Widget text;
                          switch (value.toInt()) {
                            case 0:
                              text = Text('Bien ($aciertos)', style: style);
                              break;
                            case 1:
                              text = Text('Omitido ($omisiones)', style: style);
                              break;
                            case 2:
                              text = Text('Mal ($errores)', style: style);
                              break;
                            default:
                              text = const Text('');
                          }

                          return SideTitleWidget(
                            meta: meta,
                            fitInside: SideTitleFitInsideData.fromTitleMeta(
                              meta,
                            ),
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
                            fitInside: SideTitleFitInsideData.fromTitleMeta(
                              meta,
                            ),
                            child: _getIconoPorIndice(value.toInt()),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(enabled: false),
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
          ],
        ),
      ),
    );
  }

  // ... (Resto de tus métodos: _getIconoPorIndice y _crearGrupoBarra se quedan igual)
  Widget _getIconoPorIndice(int index) {
    switch (index) {
      case 0:
        return Icon(
          Icons.sentiment_very_satisfied,
          color: Colors.greenAccent.shade700,
          size: 40,
        );
      case 1:
        return Icon(
          Icons.sentiment_neutral,
          color: Colors.grey.shade600,
          size: 40,
        );
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
            show: false, // Pon en true si quieres ver el fondo gris completo
            toY: backgroundY,
            color: Colors.grey.shade100,
          ),
        ),
      ],
    );
  }
}
