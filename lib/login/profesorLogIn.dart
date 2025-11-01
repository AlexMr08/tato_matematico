import 'package:flutter/material.dart';
import 'package:tato_matematico/ScaffoldComun.dart';

class ProfesorLogIn extends StatefulWidget {
  const ProfesorLogIn({super.key});
  @override
  State<ProfesorLogIn> createState() => _ProfesorLogInState();
}

class _ProfesorLogInState extends State<ProfesorLogIn> {
  int selectedTab = 0;

  Widget paco(){
    return Center(
      child: Text("Soy el login"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldComun(titulo: "titulo", cuerpo: paco());
  }
}
