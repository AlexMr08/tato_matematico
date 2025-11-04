import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldComun.dart';
import 'package:tato_matematico/alumnoHolder.dart';
import 'package:tato_matematico/auxFunc.dart';

class ColorPickerExample extends StatefulWidget {
  @override
  _ColorPickerExampleState createState() => _ColorPickerExampleState();

  const ColorPickerExample({super.key});
}

class _ColorPickerExampleState extends State<ColorPickerExample> {
  late AlumnoHolder alumnoHolder;
  @override
  void initState() {
    super.initState();
  }

  void _showColorPicker(String ref, String cadena, Color color) {
    Color pickerColor = color;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cadena),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  setState(() => pickerColor = color);
                },
                pickerAreaHeightPercent: 0.8,
              ),
            );
          },
        ),
        actions: [
          ElevatedButton(
            child: const Text('Select'),
            onPressed: () {
              var dbref = FirebaseDatabase.instance.ref();
              dbref
                  .child("tato")
                  .child("alumnos")
                  .child(alumnoHolder.alumno!.id)
                  .update({ref: pickerColor.toHex(leadingHashSign: false)});
              setState(() {
                switch (ref) {
                  case "colorFondo":
                    alumnoHolder.setColorFondo(pickerColor);
                    break;
                  case "colorBarraNav":
                    alumnoHolder.setBarraNav(pickerColor);
                    break;
                  case "colorBotones":
                    alumnoHolder.setColorBotones(pickerColor);
                    break;
                  default:
                    break;
                }
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    alumnoHolder = context.read<AlumnoHolder>();

    return ScaffoldComun(
      titulo: 'Ajustes comunes de color',
      cuerpo: Padding(padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _showColorPicker(
                "colorFondo",
                "Elige el color de fondo",
                alumnoHolder.alumno!.colorFondo != null
                    ? alumnoHolder.alumno!.colorFondo!
                    : Colors.white,
              ),
              child: const Text('Open Background Color Picker'),
            ),
            SizedBox(height: 8,),
            ElevatedButton(
              onPressed: () => _showColorPicker(
                "colorBarraNav",
                "Elige el color de la barra de navegacion",
                alumnoHolder.alumno!.colorBarraNav != null
                    ? alumnoHolder.alumno!.colorBarraNav!
                    : Colors.white,
              ),
              child: const Text('Open Main Color Picker'),
            ),
            SizedBox(height: 8,),
            ElevatedButton(
              onPressed: () => _showColorPicker(
                "colorBotones",
                "Elige el color de los botones",
                alumnoHolder.alumno!.colorBotones != null
                    ? alumnoHolder.alumno!.colorBotones!
                    : Colors.white,
              ),
              child: const Text('Open Button Color Picker'),
            ),
          ],
        ),
      ),)
    );
  }
}
