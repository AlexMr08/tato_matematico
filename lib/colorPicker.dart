import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

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

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: alumno.colorFondo,
            onColorChanged: (color) {
              var dbref = FirebaseDatabase.instance.ref();
              dbref.child("tato").child("alumnos").child(alumno.id).update({
                'colorFondo': color.value.toRadixString(16),
              });
              setState(() => alumno.setColorFondo(color));
            },
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text('Select'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    alumno = context.read<Alumno>();
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Color Picker')),
      body: Center(
        child: ElevatedButton(
          onPressed: _showColorPicker,
          child: const Text('Open Color Picker'),
        ),
      ),
    );
  }
}