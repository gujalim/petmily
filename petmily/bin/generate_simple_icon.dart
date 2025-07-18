import 'package:flutter/material.dart';
import '../lib/utils/simple_icon_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimpleIconGenerator.generateSimpleIcon();
} 