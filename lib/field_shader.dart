import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class FieldShader extends StatefulWidget {
  const FieldShader({super.key});

  @override
  State<FieldShader> createState() => _FieldShaderState();
}

class _FieldShaderState extends State<FieldShader> with SingleTickerProviderStateMixin {
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
    final size = const Size(300, 300);
    return Listener(
      onPointerMove: (event) {
        lastMousePositionDx = event.delta.dx * 0.002;
        time += lastMousePositionDx!;
        setState(() {});
      },
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          time += event.scrollDelta.dy * 0.0008;
          setState(() {});
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: ShaderBuilder(
            assetKey: 'shaders/field.glsl',
            (context, shader, child) {
              return Center(
                child: AnimatedSampler(
                  child: child!,
                  (ui.Image image, Size size, Canvas canvas) {
                    size = const Size(300, 300);
                    shader
                      ..setFloat(0, time)
                      ..setFloat(1, size.width)
                      ..setFloat(2, size.height);
                    canvas.drawRect(ui.Rect.fromCenter(center: Offset.zero, width: size.width, height: size.width),
                        Paint()..shader = shader);
                  },
                ),
              );
            },
            child: const SizedBox(
              width: 1,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
