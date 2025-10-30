import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/auxFunc.dart';

import 'alumno.dart';

class ColorPickerExample extends StatefulWidget {
  @override
  _ColorPickerExampleState createState() => _ColorPickerExampleState();

  const ColorPickerExample({super.key});
}

class _ColorPickerExampleState extends State<ColorPickerExample> {
  late Alumno alumno;
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
                showLabel: true,
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
              dbref.child("tato").child("alumnos").child(alumno.id).update({
                ref: pickerColor.toHex(leadingHashSign: false),
              });
              setState(() {
                switch (ref) {
                  case "colorFondo":
                    alumno.colorFondo = pickerColor;
                    break;
                  case "colorPrincipal":
                    alumno.colorPrincipal = pickerColor;
                    break;
                  default:
                    break;
                }
                ;
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
    alumno = context.read<Alumno>();
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes comunes de color')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () =>
                  _showColorPicker("colorFondo", "Elige el color de fondo", alumno.colorFondo != null ? alumno.colorFondo! : Colors.white),
              child: const Text('Open Background Color Picker'),
            ),
            ElevatedButton(
              onPressed: () =>
                  _showColorPicker("colorPrincipal", "Elige el color principal", alumno.colorPrincipal != null ? alumno.colorPrincipal! : Colors.white),
              child: const Text('Open Main Color Picker'),
            ),
          ],
        ),
      ),
    );
  }
}
