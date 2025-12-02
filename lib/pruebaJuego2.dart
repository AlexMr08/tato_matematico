import 'package:flutter/material.dart';
import 'dart:math';

class ActividadOrdenarNumeros extends StatefulWidget {
  // Parámetros que le pasa tu App principal
  final int cantidad;
  final bool esAscendente;
  final VoidCallback? onGameFinished; // Para avisar a tu app que terminó
  final Color colorPrimario; // Para que combine con tu diseño

  const ActividadOrdenarNumeros({
    super.key,
    required this.cantidad,
    required this.esAscendente,
    this.onGameFinished,
    this.colorPrimario = Colors.blue, // Color por defecto
  });

  @override
  State<ActividadOrdenarNumeros> createState() => _ActividadOrdenarNumerosState();
}

class _ActividadOrdenarNumerosState extends State<ActividadOrdenarNumeros> {
  late List<int> numerosDesordenados;
  late List<int> numerosOrdenadosObjetivo;
  List<int> numerosColocados = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _iniciarNivel();
  }

  void _iniciarNivel() {
    // Generación de números (1-50)
    Set<int> setNumeros = {};
    while (setNumeros.length < widget.cantidad) {
      setNumeros.add(_rng.nextInt(50) + 1);
    }

    numerosOrdenadosObjetivo = setNumeros.toList();

    // Ordenar según configuración recibida
    if (widget.esAscendente) {
      numerosOrdenadosObjetivo.sort();
    } else {
      numerosOrdenadosObjetivo.sort((a, b) => b.compareTo(a));
    }

    // Preparar lista jugable
    numerosDesordenados = List.from(numerosOrdenadosObjetivo)..shuffle();
    numerosColocados = [];

    // Aseguramos que se actualice la vista
    if (mounted) setState(() {});
  }

  void _intentarColocar(int numero) {
    int siguienteIndice = numerosColocados.length;
    int numeroCorrecto = numerosOrdenadosObjetivo[siguienteIndice];

    if (numero == numeroCorrecto) {
      setState(() {
        numerosDesordenados.remove(numero);
        numerosColocados.add(numero);
      });

      if (numerosDesordenados.isEmpty) {
        _gestionarVictoria();
      }
    } else {
      // Feedback accesible: SnackBar usando el contexto local
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.esAscendente
                ? 'Busca el MENOR número disponible.'
                : 'Busca el MAYOR número disponible.',
            style: const TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.orange.shade800,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _gestionarVictoria() {
    // Mostramos diálogo local, pero al cerrar ejecutamos el callback de tu app
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¡Excelente trabajo!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 80),
            const SizedBox(height: 10),
            Text(
              "Has ordenado los ${widget.cantidad} números correctamente.",
              textAlign: TextAlign.center,
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra diálogo
              _iniciarNivel(); // Reinicia el mismo nivel
            },
            child: const Text('Repetir'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: widget.colorPrimario),
            onPressed: () {
              Navigator.pop(context); // Cierra diálogo
              // Aquí avisamos a TU app que la actividad terminó
              if (widget.onGameFinished != null) {
                widget.onGameFinished!();
              } else {
                // Comportamiento por defecto si no pasas callback: volver atrás
                Navigator.of(context).pop();
              }
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos Scaffold para tener estructura, pero el AppBar es opcional
    // si tu app ya tiene una cabecera global.
    return Scaffold(
      backgroundColor: Colors.white, // O transparente si tu app tiene fondo
      appBar: AppBar(
        title: Text(widget.esAscendente ? 'Menor ➜ Mayor' : 'Mayor ➜ Menor'),
        backgroundColor: widget.colorPrimario,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: "Salir de la actividad",
        ),
      ),
      body: Column(
        children: [
          // Zona de progreso
          Container(
            padding: const EdgeInsets.all(16),
            color: widget.colorPrimario.withOpacity(0.1),
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: numerosColocados.map((n) => _FichaNumero(
                  numero: n,
                  activo: false,
                  colorBase: widget.colorPrimario
              )).toList(),
            ),
          ),

          const Divider(height: 1),

          // Zona de juego
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: numerosDesordenados.map((n) {
                    return GestureDetector(
                      onTap: () => _intentarColocar(n),
                      child: Semantics(
                        label: "$n",
                        hint: "Tocar para seleccionar",
                        child: _FichaNumero(
                            numero: n,
                            activo: true,
                            colorBase: widget.colorPrimario
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sub-componente privado para el diseño de la ficha
class _FichaNumero extends StatelessWidget {
  final int numero;
  final bool activo;
  final Color colorBase;

  const _FichaNumero({
    required this.numero,
    required this.activo,
    required this.colorBase,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      width: activo ? 80 : 60,
      height: activo ? 80 : 60,
      decoration: BoxDecoration(
        color: activo ? Colors.white : colorBase.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: activo ? colorBase : Colors.transparent,
            width: 3
        ),
        boxShadow: activo ? [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4)
          )
        ] : [],
      ),
      alignment: Alignment.center,
      child: Text(
        '$numero',
        style: TextStyle(
          fontSize: activo ? 32 : 24,
          fontWeight: FontWeight.bold,
          color: activo ? Colors.black87 : colorBase.withOpacity(0.8),
        ),
      ),
    );
  }
}
