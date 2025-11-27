import 'dart:math';
import 'package:flutter/material.dart';

class Juego2Page extends StatefulWidget {
  const Juego2Page({Key? key}) : super(key: key);

  @override
  State<Juego2Page> createState() => _Juego2PageState();
}

class _Juego2PageState extends State<Juego2Page> {
  final int totalLevels = 5;
  int level = 1;
  late int containersCount;
  late int target;
  late List<List<int>> containers; // cada contenedor tiene lista de bolitas con valores
  int? _draggingFromIndex;
  int? _draggingValue;
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _startLevel(level);
  }

  void _startLevel(int lvl) {
    containersCount = 3; // misma dificultad
    target = _rnd.nextInt(101); // objetivo 0–10
    containers = _generateRandomDistribution(containersCount, target);
    _draggingFromIndex = null;
    _draggingValue = null;
  }

  /// Genera bolitas aleatorias de valores 1–3 para que la suma total = target * containersCount
  /// y distribuye aleatoriamente entre los contenedores
  List<List<int>> _generateRandomDistribution(int n, int target) {
    int totalSum = n * target;
    List<int> allBalls = [];
    while (totalSum > 0) {
      int val = min(10, totalSum);
      int ballValue = _rnd.nextInt(val) + 1; // 1..min(3, totalSum)
      allBalls.add(ballValue);
      totalSum -= ballValue;
    }
    allBalls.shuffle(_rnd);

    // Inicializa contenedores vacíos
    List<List<int>> result = List.generate(n, (_) => []);
    // Distribuye bolitas aleatoriamente entre contenedores
    for (int ball in allBalls) {
      int idx = _rnd.nextInt(n);
      result[idx].add(ball);
    }
    return result;
  }

  bool get _allCorrect =>
      containers.every((c) => c.fold(0, (a, b) => a + b) == target);

  void _nextLevel() {
    setState(() {
      level++;
      if (level > totalLevels) level = 1;
      _startLevel(level);
    });
  }

  Widget _ballWidget(int value, {double size = 28}) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Text(
        '$value',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nivel $level - Objetivo: $target'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _startLevel(level)),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: List.generate(containersCount, (i) => _buildContainerCard(i)),
                ),
              ),
            ),
            if (_allCorrect)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _nextLevel,
                  child: Text(level < totalLevels ? 'Siguiente Nivel' : 'Reiniciar Juego'),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildContainerCard(int index) {
    final containerTotal = containers[index].fold(0, (a, b) => a + b);
    final isCorrect = containerTotal == target;

    return DragTarget<Map<String, int>>(
      onWillAccept: (data) => data != null && data['value']! > 0,
      onAccept: (data) {
        setState(() {
          containers[index].add(data['value']!);
          _draggingFromIndex = null;
          _draggingValue = null;
        });
      },
      builder: (context, candidateData, rejected) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 140,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCorrect ? Colors.green.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isCorrect ? Colors.green : Colors.blue.shade700, width: 2.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Recipiente ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('$containerTotal', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(containers[index].length, (b) {
                  int value = containers[index][b];
                  return Draggable<Map<String,int>>(
                    data: {'from': index, 'value': value},
                    feedback: Material(
                        color: Colors.transparent,
                        child: _ballWidget(value, size: 36)),
                    childWhenDragging: Opacity(opacity: 0.25, child: _ballWidget(value)),
                    onDragStarted: () {
                      setState(() {
                        containers[index].removeAt(b);
                        _draggingFromIndex = index;
                        _draggingValue = value;
                      });
                    },
                    onDraggableCanceled: (_, __) {
                      setState(() {
                        if (_draggingFromIndex != null && _draggingValue != null) {
                          containers[_draggingFromIndex!].add(_draggingValue!);
                          _draggingFromIndex = null;
                          _draggingValue = null;
                        }
                      });
                    },
                    child: _ballWidget(value),
                  );
                }),
              )
            ],
          ),
        );
      },
    );
  }
}
