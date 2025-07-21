import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';

Future<void> createProfessionalIcon() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = const Size(1024, 1024);
  
  // 배경 - 파스텔 핑크 그라데이션
  final backgroundPaint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFF48FB1), // 파스텔 핑크
        const Color(0xFFF8BBD9), // 연한 핑크
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
  
  // 둥근 모서리 배경
  final backgroundRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, size.width, size.height),
    const Radius.circular(200),
  );
  canvas.drawRRect(backgroundRect, Paint()..shader = backgroundPaint);
  
  // 중앙 원형 배경
  final circlePaint = Paint()
    ..color = Colors.white.withOpacity(0.95)
    ..style = PaintingStyle.fill;
  
  canvas.drawCircle(Offset(size.width / 2, size.height / 2), 250, circlePaint);
  
  // 하트 모양
  final heartPaint = Paint()
    ..color = const Color(0xFFF48FB1)
    ..style = PaintingStyle.fill;
  
  final heartPath = Path();
  heartPath.moveTo(size.width / 2, size.height / 2 - 160);
  heartPath.cubicTo(
    size.width / 2, size.height / 2 - 160,
    size.width / 2 - 100, size.height / 2 - 260,
    size.width / 2 - 200, size.height / 2 - 160,
  );
  heartPath.cubicTo(
    size.width / 2 - 200, size.height / 2 - 60,
    size.width / 2, size.height / 2 + 40,
    size.width / 2, size.height / 2 + 40,
  );
  heartPath.cubicTo(
    size.width / 2, size.height / 2 + 40,
    size.width / 2 + 200, size.height / 2 - 60,
    size.width / 2 + 200, size.height / 2 - 160,
  );
  heartPath.cubicTo(
    size.width / 2 + 200, size.height / 2 - 260,
    size.width / 2 + 100, size.height / 2 - 160,
    size.width / 2, size.height / 2 - 160,
  );
  heartPath.close();
  
  canvas.drawPath(heartPath, heartPaint);
  
  // "P" 텍스트
  final textPainter = TextPainter(
    text: TextSpan(
      text: 'P',
      style: TextStyle(
        color: const Color(0xFFF48FB1),
        fontSize: 200,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(canvas, Offset(
    (size.width - textPainter.width) / 2,
    (size.height - textPainter.height) / 2 + 80,
  ));
  
  // 장식 요소들
  final decorationPaint = Paint()
    ..color = Colors.white.withOpacity(0.3)
    ..style = PaintingStyle.fill;
  
  canvas.drawCircle(Offset(200, 200), 20, decorationPaint);
  canvas.drawCircle(Offset(824, 200), 15, decorationPaint);
  canvas.drawCircle(Offset(200, 824), 18, decorationPaint);
  canvas.drawCircle(Offset(824, 824), 12, decorationPaint);
  
  final picture = recorder.endRecording();
  final image = await picture.toImage(1024, 1024);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();
  
  // 아이콘 파일 저장
  final file = File('assets/icon/icon.png');
  await file.writeAsBytes(bytes);
  
  print('전문적인 Petmily 아이콘이 생성되었습니다: assets/icon/icon.png');
} 