import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';

Future<void> createSimpleIcon() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = const Size(1024, 1024);
  
  // 배경 - 파스텔 핑크
  final backgroundPaint = Paint()
    ..color = const Color(0xFFF48FB1)
    ..style = PaintingStyle.fill;
  
  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
  
  // 중앙에 하트 모양
  final heartPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;
  
  // 간단한 하트 그리기
  final path = Path();
  path.moveTo(512, 300);
  path.cubicTo(512, 300, 400, 200, 300, 300);
  path.cubicTo(300, 400, 512, 500, 512, 500);
  path.cubicTo(512, 500, 724, 400, 724, 300);
  path.cubicTo(724, 200, 512, 300, 512, 300);
  path.close();
  
  canvas.drawPath(path, heartPaint);
  
  // "P" 텍스트
  final textPainter = TextPainter(
    text: TextSpan(
      text: 'P',
      style: TextStyle(
        color: const Color(0xFFF48FB1),
        fontSize: 300,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(canvas, Offset(
    (size.width - textPainter.width) / 2,
    (size.height - textPainter.height) / 2,
  ));
  
  final picture = recorder.endRecording();
  final image = await picture.toImage(1024, 1024);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();
  
  // 아이콘 파일 저장
  final file = File('assets/icon/icon.png');
  await file.writeAsBytes(bytes);
  
  print('아이콘이 생성되었습니다: assets/icon/icon.png');
} 