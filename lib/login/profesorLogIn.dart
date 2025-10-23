import 'package:flutter/material.dart';

class ProfesorLogIn extends StatefulWidget {
  const ProfesorLogIn({super.key});
  @override
  State<ProfesorLogIn> createState() => _ProfesorLogInState();
}

class _ProfesorLogInState extends State<ProfesorLogIn> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context) ? InkWell(child: const Icon(Icons.arrow_back), onTap: () => {Navigator.pop(context)}) : const Icon(Icons.menu),
        title: const Text('Inicio de sesion del profesor', style: TextStyle(fontSize: 20)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(child: Column(
        children: [
          Center(child: Text('Log In del profesor', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          // Aquí puedes agregar más widgets para el menú de juegos
        ],
      )),
    );
  }
}
