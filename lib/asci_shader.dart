import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shader/field_shader.dart';
import 'package:flutter_shader/pyramid_shader.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class AsciShader extends StatefulWidget {
  const AsciShader({super.key});

  @override
  State<AsciShader> createState() => _AsciShaderState();
}

class _AsciShaderState extends State<AsciShader> with SingleTickerProviderStateMixin {
  double time = 0;
  double? lastMousePositionDx;
  late final Ticker _ticker;
  bool isPointerDown = false;
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

  Widget currentShader = const SphereShader();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onLongPressStart: (e) {
        isPointerDown = !isPointerDown;
        setState(() {});
      },
      onLongPressEnd: (e) {
        isPointerDown = !isPointerDown;
        setState(() {});
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: ShaderBuilder(
            assetKey: 'shaders/asci.glsl',
            child: SizedBox(width: size.width, height: size.height),
            (context, shader, child) {
              return AnimatedSampler(enabled: !isPointerDown, (ui.Image image, Size size, Canvas canvas) {
                shader
                  ..setFloat(0, time)
                  ..setFloat(1, size.width)
                  ..setFloat(2, size.height)
                  ..setFloat(3, 0)
                  ..setFloat(4, 0)
                  ..setFloat(5, 0)
                  ..setFloat(6, 0)
                  ..setImageSampler(0, image);
                canvas.drawPaint(Paint()..shader = shader);
              },
                  child: PageView(
                    scrollBehavior: AppScrollBehavior(),
                    children: const [
                      SphereShader(),
                      FieldShader(),
                    ],
                  ));
            },
          ),
        ),
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
