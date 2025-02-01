import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

class CharacterBackgroundPainter extends CustomPainter {
  final int seed;
  final bool enableRotation; 
  final bool enableFlip; 
  final double minFontSize; 
  final double maxFontSize; 
  final double waveAmplitude; 
  final double waveFrequency; 
  final double? time; 

  CharacterBackgroundPainter({
    required this.seed,
    required this.enableRotation,
    required this.enableFlip,
    required this.minFontSize,
    required this.maxFontSize,
    this.waveAmplitude = 10.0, 
    this.waveFrequency =
        0.1, 
    this.time, 
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(seed);

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    List<String> characters = [
      
      'あ', 'い', 'う', 'え', 'お',
      'か', 'き', 'く', 'け', 'こ',
      'さ', 'し', 'す', 'せ', 'そ',
      'た', 'ち', 'つ', 'て', 'と',
      'な', 'に', 'ぬ', 'ね', 'の',
      'は', 'ひ', 'ふ', 'へ', 'ほ',
      'ま', 'み', 'む', 'め', 'も',
      'や', 'ゆ', 'よ',
      'ら', 'り', 'る', 'れ', 'ろ',
      'わ', 'を', 'ん',

      
      'ア', 'イ', 'ウ', 'エ', 'オ',
      'カ', 'キ', 'ク', 'ケ', 'コ',
      'サ', 'シ', 'ス', 'セ', 'ソ',
      'タ', 'チ', 'ツ', 'テ', 'ト',
      'ナ', 'ニ', 'ヌ', 'ネ', 'ノ',
      'ハ', 'ヒ', 'フ', 'ヘ', 'ホ',
      'マ', 'ミ', 'ム', 'メ', 'モ',
      'ヤ', 'ユ', 'ヨ',
      'ラ', 'リ', 'ル', 'レ', 'ロ',
      'ワ', 'ヲ', 'ン',

      
      '漢', '字', '日', '本', '語',
      '愛', '平', '和', '心', '夢',
      '学', '校', '自', '由', '天',
      '空', '幸', '運', '人', '事',

      
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
      'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
      'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
      'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',

      
      '!', '"', '#', '%', '&', "'", '(', ')', '*', '+', ',', '-', '.', '/', ':',
      ';', '<', '=', '>', '?', '@', '[', '\\', ']', '^', '_', '`',
      '{', '|', '}', '~'
    ];

    double offsetX = 0.0;
    double offsetY = 0.0;

    while (offsetY < size.height) {
      while (offsetX < size.width) {
        String randomChar = characters[random.nextInt(characters.length)];

        if (enableFlip && random.nextBool()) {
          randomChar = String.fromCharCodes(randomChar.runes.toList().reversed);
        }

        double fontSize =
            minFontSize + random.nextDouble() * (maxFontSize - minFontSize);

        textPainter.text = TextSpan(
          text: randomChar,
          style:
              GoogleFonts.rampartOne(fontSize: fontSize, color: Colors.white),
        );
        textPainter.layout();

        
        double floatEffect = 0.0;
        if (time != null) {
          
          floatEffect =
              waveAmplitude * sin(waveFrequency * time! + offsetX + offsetY);
        }

        
        canvas.save();

        
        if (enableRotation) {
          double angle = (random.nextDouble() - 0.5) *
              pi /
              4; 
          canvas.translate(offsetX + textPainter.width / 2,
              offsetY + textPainter.height / 2);
          canvas.rotate(angle);
          canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
        }

        
        textPainter.paint(canvas, Offset(offsetX, offsetY + floatEffect));

        canvas.restore(); 

        double spacing = fontSize * 1.2;
        offsetX += spacing; 
      }
      offsetX = 0.0; 
      offsetY += maxFontSize * 1.2; 
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    
    if (oldDelegate is CharacterBackgroundPainter) {
      return oldDelegate.seed != seed ||
          oldDelegate.enableRotation != enableRotation ||
          oldDelegate.enableFlip != enableFlip ||
          oldDelegate.minFontSize != minFontSize ||
          oldDelegate.maxFontSize != maxFontSize ||
          oldDelegate.waveAmplitude != waveAmplitude ||
          oldDelegate.waveFrequency != waveFrequency ||
          oldDelegate.time != time; 
    }
    return true;
  }
}
