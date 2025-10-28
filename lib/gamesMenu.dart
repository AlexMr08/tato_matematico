import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/alumno.dart';

import 'auxFunc.dart';
import 'juego.dart';
import 'colorPicker.dart';

class GamesMenu extends StatefulWidget {

  GamesMenu({super.key});
  @override
  State<GamesMenu> createState() => _GamesMenuState();
}

class _GamesMenuState extends State<GamesMenu> {
  late Alumno alumno;
  final List<Juego> listaJuegos = [
    Juego(id: 'juego1', actividad: Placeholder(), nombre: 'Juego 1', color: Color.fromARGB(255, 255, 105, 97)),
    Juego(id: 'juego2', actividad: Placeholder(), nombre: 'Juego 2', color: Color.fromARGB(255, 119, 221, 119)),
    Juego(id: 'juego3', actividad: Placeholder(), nombre: 'Juego 3', color: Color.fromARGB(255, 132, 182, 244)),
    Juego(id: 'juego4', actividad: Placeholder(), nombre: 'Juego 4', color: Color.fromARGB(255, 253, 202, 225)),
    Juego(id: 'estadisticas', actividad: Placeholder(), nombre: 'estadisticas', color: Color.fromARGB(255, 253, 253, 150)),
  ];

  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    alumno = context.watch<Alumno>();
    print("Alumno en GamesMenu: $alumno");
    return Scaffold(
      backgroundColor: alumno.colorFondo,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? InkWell(
                child: const Icon(Icons.arrow_back),
                onTap: () => {Navigator.pop(context)},
              )
            : const Icon(Icons.menu),
        title: Column(
          children: [
            Text('Seleccion de juego', style: TextStyle(fontSize: 20), ),
            Text(alumno.nombre, style: TextStyle(fontSize: 14)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: listaJuegos[0].widgetJuego(context, () {
                        navegar(listaJuegos[0].actividad, context);
                      }),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: listaJuegos[1].widgetJuego(context, () {
                        navegar(listaJuegos[1].actividad, context);
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: listaJuegos[2].widgetJuego(context, () {
                        navegar(listaJuegos[2].actividad, context);
                      }),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: listaJuegos[3].widgetJuego(context, () {
                        navegar(listaJuegos[3].actividad, context);
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: listaJuegos[4].widgetJuego(context, () {
                        navegar(ColorPickerExample(), context);
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


