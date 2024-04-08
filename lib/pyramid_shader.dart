import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class SphereShader extends StatefulWidget {
  const SphereShader({super.key});

  @override
  State<SphereShader> createState() => _SphereShaderState();
}

class _SphereShaderState extends State<SphereShader> with SingleTickerProviderStateMixin {
  double time = 0;
  double? lastMousePositionDx;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      time += 0.015;
      setState(() {});
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Listener(
      onPointerMove: (event) {
        lastMousePositionDx = event.delta.dx * 0.002;
        time += lastMousePositionDx!;
        setState(() {});
      },
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          print(event.scrollDelta.dy);
          time += event.scrollDelta.dy * 0.0008;
          setState(() {});
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: ShaderBuilder(
            assetKey: 'shaders/sphere.glsl',
            child: const SizedBox(width: 300, height: 300),
            (context, shader, child) {
              return Center(
                child: AnimatedSampler(
                  child: child!,
                  (ui.Image image, Size size, Canvas canvas) {
                    shader
                      ..setFloat(0, time)
                      ..setFloat(1, size.width)
                      ..setFloat(2, size.height);
                    canvas.drawPaint(Paint()..shader = shader);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
