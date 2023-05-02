import 'package:flutter/material.dart';
import 'dart:ui' as ui;

final screenWidth = (ui.window.physicalSize.width / ui.window.devicePixelRatio);
final screenHeight =
    (ui.window.physicalSize.height / ui.window.devicePixelRatio);
final safePaddingTop = WidgetsBinding.instance.window.padding.top;
final safePaddingBottom = WidgetsBinding.instance.window.padding.top;

Color themeColor = Color.fromARGB(255, 0, 92, 167);
