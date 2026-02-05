import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'; // Para b, i, u
import '../models/slide_model.dart';
import '../providers/slide_provider.dart';
import '../widgets/authenticated_image.dart';

class SlideWebViewScreen extends StatefulWidget {
  final int turmaId;
  final String turmaNome;

  const SlideWebViewScreen({Key? key, required this.turmaId, required this.turmaNome}) : super(key: key);

  @override
  _SlideWebViewScreenState createState() => _SlideWebViewScreenState();
}

class _SlideWebViewScreenState extends State<SlideWebViewScreen> {
  int _currentIndex = 0;
  final PageController _controller = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SlideProvider>(context, listen: false).startAutoUpdate(widget.turmaId);
    });
  }

  @override
  void dispose() {
    // Importante parar o Timer ao sair
    Provider.of<SlideProvider>(context, listen: false).stopAutoUpdate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.turmaNome)),
      backgroundColor: Colors.white, // Fundo escuro destaca o slide
      body: Consumer<SlideProvider>(
        builder: (context, provider, _) {
          final slides = provider.instrumento?.slides ?? [];
          if (slides.isEmpty && provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (slides.isEmpty) return const Center(child: Text("Nenhum slide disponível", style: TextStyle(color: Colors.black)));

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (context, index) {
                    // InteractiveViewer adiciona o ZOOM
                    return InteractiveViewer(
                      panEnabled: true, 
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: SlideRenderer(slide: slides[index]),
                    );
                  },
                ),
              ),
              _buildNav(slides.length),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNav(int total) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: _currentIndex > 0 ? () => _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease) : null,
            ),
            Text('${_currentIndex + 1} / $total', style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: _currentIndex < total - 1 ? () => _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class SlideRenderer extends StatelessWidget {
  final Slide slide;
  const SlideRenderer({Key? key, required this.slide}) : super(key: key);

  Color _parseColor(String? hex) {
    if (hex == null) return Colors.black;
    return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> elements = [...slide.images, ...slide.textBoxes];
    elements.sort((a, b) => (a.zIndex ?? 0).compareTo(b.zIndex ?? 0));

    return Center(
      child: AspectRatio(
        aspectRatio: 960 / 540,
        child: Container(
          color: Colors.white,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 960,
              height: 540,
              child: Stack(
                children: elements.map((el) {
                  if (el is ImageBox) {
                    return Positioned(
                      left: el.x, top: el.y,
                      width: el.width, height: el.height,
                      child: AuthenticatedImage(
                        imageUrl: el.src.startsWith('/') ? 'https://obeci.the-fool.site${el.src}' : el.src,
                        width: el.width,
                        height: el.height,
                      ),
                    );
                  } else if (el is TextBox) {
                    return Positioned(
                      left: el.x, top: el.y,
                      width: el.width, height: el.height,
                      child: HtmlWidget(
                        el.content,
                        textStyle: TextStyle(
                          fontSize: (el.fontSize ?? 16).toDouble(),
                          fontFamily: el.fontFamily,
                          color: _parseColor(el.color),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}