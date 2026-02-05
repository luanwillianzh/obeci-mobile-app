import 'dart:convert';

class TextBox {
  final int id;
  final double x;
  final double y;
  final double width;
  final double height;
  final String content;
  final int zIndex;
  final String? fontFamily;
  final int? fontSize;
  final String? fontWeight;
  final String? color;

  TextBox({
    required this.id, required this.x, required this.y, 
    required this.width, required this.height, required this.content,
    required this.zIndex, this.fontFamily, this.fontSize, 
    this.fontWeight, this.color,
  });

  factory TextBox.fromJson(Map<String, dynamic> json) {
    return TextBox(
      id: json['id'] ?? 0,
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      width: (json['width'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      content: json['content'] ?? '',
      zIndex: (json['zIndex'] ?? 0).toInt(),
      fontFamily: json['fontFamily'],
      fontSize: json['fontSize'] is int ? json['fontSize'] : (json['fontSize'] as num?)?.toInt(),
      fontWeight: json['fontWeight'],
      color: json['color'],
    );
  }
}

class ImageBox {
  final int id;
  final double x;
  final double y;
  final double width;
  final double height;
  final String src;
  final int zIndex;

  ImageBox({
    required this.id, required this.x, required this.y, 
    required this.width, required this.height, required this.src, required this.zIndex,
  });

  factory ImageBox.fromJson(Map<String, dynamic> json) {
    return ImageBox(
      id: json['id'] ?? 0,
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      width: (json['width'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      src: json['src'] ?? '',
      zIndex: (json['zIndex'] ?? 0).toInt(),
    );
  }
}

class Slide {
  final int id;
  final List<TextBox> textBoxes;
  final List<ImageBox> images;
  final String? instrument;

  Slide({required this.id, required this.textBoxes, required this.images, this.instrument});

  factory Slide.fromJson(Map<String, dynamic> json) {
    return Slide(
      id: json['id'] ?? 0,
      instrument: json['instrument'],
      textBoxes: (json['textBoxes'] as List? ?? []).map((t) => TextBox.fromJson(t)).toList(),
      images: (json['images'] as List? ?? []).map((i) => ImageBox.fromJson(i)).toList(),
    );
  }
}

class Instrumento {
  final int id;
  final int turmaId;
  final List<Slide> slides;
  final int version;

  Instrumento({required this.id, required this.turmaId, required this.slides, required this.version});

  factory Instrumento.fromJson(Map<String, dynamic> json) {
    List<Slide> parsedSlides = [];
    if (json['slidesJson'] != null) {
      try {
        final List<dynamic> decoded = jsonDecode(json['slidesJson']);
        parsedSlides = decoded.map((s) => Slide.fromJson(s)).toList();
      } catch (e) {
        print("Erro decode: $e");
      }
    }
    return Instrumento(
      id: json['id'] ?? 0,
      turmaId: json['turmaId'] ?? 0,
      version: json['version'] ?? 0,
      slides: parsedSlides,
    );
  }
}