import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/auxFunc.dart'; // Import raíz
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/juegos/juego_1/juego1State.dart';
import 'package:tato_matematico/juegos/juego_1/juego1_settings.dart';
import 'package:tato_matematico/juegos/tarjetaJuego.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldAlumno.dart';

import 'juego1.dart'; // Import widgets

class Juego1AjustesScreen extends StatefulWidget {
  const Juego1AjustesScreen({Key? key}) : super(key: key);

  @override
  State<Juego1AjustesScreen> createState() => _Juego1AjustesScreenState();
}

class _Juego1AjustesScreenState extends State<Juego1AjustesScreen> {
  late Alumno alumno;
  late Juego1 juego;

  // Estado local de ajustes
  late int _numOpciones;
  late int _rangoMax; // Presets para UX: 10, 20, 50, 100
  late int _rangoMin;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final tempAlumno = context.read<AlumnoHolder>().alumno!;
    final tempJuego1 =
        context.read<AlumnoHolder>().listaJuegos["juego1"] as Juego1;
    _numOpciones = tempJuego1.cantidad;
    _rangoMax = tempJuego1.max;
    _rangoMin = tempJuego1.min;
  }

  Future<void> _guardar() async {
    setState(() => _isLoading = true);

    final newSettings = Juego1Settings(
      numeroOpciones: _numOpciones,
      numeroMayor: _rangoMax,
      numeroMenor: _rangoMin,
    );

    // Actualizar Firebase
    final dbRef = FirebaseDatabase.instance.ref();

    try {
      juego.guardarAjustes(
        idAlumno: alumno.id,
        rango: _rangoMax,
        cantidad: _numOpciones,
        tema: "numeros",
        dbRef: FirebaseDatabase.instance.ref(),
      );

      await dbRef
          .child('tato/alumnos/${alumno.id}/juego1Settings')
          .update(newSettings.toMap());

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error guardando: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    alumno = context.watch<AlumnoHolder>().alumno!;
    juego = context.watch<AlumnoHolder>().listaJuegos["juego1"] as Juego1;
    PosicionBarra posicionBarra = getPosicionBarra(alumno.posicionBarra);

    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;

    return ScaffoldAlumno(
      alumno: alumno,
      textoCabecera: "Ajustes - Encuentra el número",
      posicion: posicionBarra,
      hasAjustes: false,
      hasEstadisticas: false,
      onVolver: _guardar, // Guardar automáticamente al salir
      onAjustes: () {},
      onEstadisticas: () {},
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SECCIÓN 1: RANGO DE NÚMEROS ---
            _titulo("Rango de números"),
            const SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  _itemRango(10, "0 - 10", Icons.filter_1, isMobile),
                  const SizedBox(width: 10),
                  _itemRango(20, "0 - 20", Icons.filter_2, isMobile),
                  const SizedBox(width: 10),
                  _itemRango(100, "0 - 100", Icons.filter_5, isMobile),
                  const SizedBox(width: 10),
                  _itemRango(1000, "0 - 1000", Icons.filter_9_plus, isMobile),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- SECCIÓN 2: CANTIDAD DE OPCIONES ---
            _titulo("Cantidad de opciones"),
            const SizedBox(height: 10),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botón Menos (Estilo Stepper)
                  _botonStepper(
                    Icons.remove,
                    "MENOS",
                    () {
                      if (_numOpciones > 2) {
                        setState(() => _numOpciones--);
                      }
                    },
                    isMobile,
                    isEnabled: _numOpciones > 2,
                  ),

                  const SizedBox(width: 20),

                  // Visualizador (Usa TarjetaJuego visualmente)
                  TarjetaJuego(
                    label: _numOpciones.toString(),
                    isButton: false,
                    isEnabled: true,
                    onTap: () {},
                    colorFondo: Colors.white,
                    imagenes: false,
                    tipoImagen: "",
                    numero: _numOpciones,
                    tamano: isMobile ? 80 : 120,
                    radio: 20,
                  ),

                  const SizedBox(width: 20),

                  // Botón Más
                  _botonStepper(
                    Icons.add,
                    "MÁS",
                    () {
                      if (_numOpciones < 12) setState(() => _numOpciones++);
                    },
                    isMobile,
                    isEnabled: _numOpciones < 12,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _titulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
    );
  }

  Widget _itemRango(int maxVal, String label, IconData icon, bool isMobile) {
    bool selected = _rangoMax == maxVal;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _rangoMax = maxVal),
        child: Container(
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? Colors.green : Colors.transparent,
              width: 3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: isMobile ? 24 : 40, color: Colors.black54),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botonStepper(
    IconData icon,
    String label,
    VoidCallback onTap,
    bool isMobile, {
    bool isEnabled = true,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.3,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 32,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: isMobile ? 30 : 50),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
