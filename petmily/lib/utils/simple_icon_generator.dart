import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleIconGenerator {
  static Future<void> generateSimpleIcon() async {
    // 간단한 아이콘을 SVG로 생성하고 PNG로 변환
    final svgContent = '''
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#F48FB1;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#FFB74D;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <!-- 배경 -->
  <rect width="1024" height="1024" fill="url(#grad1)"/>
  
  <!-- 귀여운 얼굴 (반원) -->
  <circle cx="512" cy="612" r="300" fill="rgba(255,255,255,0.9)"/>
  
  <!-- 눈 -->
  <circle cx="432" cy="562" r="25" fill="#4A4A4A"/>
  <circle cx="592" cy="562" r="25" fill="#4A4A4A"/>
  
  <!-- 코 -->
  <circle cx="512" cy="612" r="15" fill="#FF6B9D"/>
  
  <!-- 귀 -->
  <circle cx="392" cy="462" r="60" fill="#E1BEE7"/>
  <circle cx="632" cy="462" r="60" fill="#E1BEE7"/>
  
  <!-- 발바닥 -->
  <circle cx="512" cy="874" r="40" fill="rgba(255,255,255,0.8)"/>
  <circle cx="432" cy="844" r="30" fill="rgba(255,255,255,0.8)"/>
  <circle cx="592" cy="844" r="30" fill="rgba(255,255,255,0.8)"/>
</svg>
''';

    // SVG를 PNG로 변환하는 대신 간단한 색상 블록으로 아이콘 생성
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1024, 1024);
    
    // 배경 그라데이션
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFF48FB1), // 연한 핑크
          const Color(0xFFFFB74D), // 연한 오렌지
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // 중앙에 하트 모양 (Petmily의 "P"를 상징)
    final heartPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    // 간단한 하트 모양 그리기
    final path = Path();
    path.moveTo(512, 400);
    path.cubicTo(512, 400, 400, 300, 300, 400);
    path.cubicTo(300, 500, 512, 600, 512, 600);
    path.cubicTo(512, 600, 724, 500, 724, 400);
    path.cubicTo(724, 300, 512, 400, 512, 400);
    path.close();
    
    canvas.drawPath(path, heartPaint);
    
    // "P" 텍스트 추가
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
} 