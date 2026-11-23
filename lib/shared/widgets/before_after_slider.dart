import 'package:flutter/material.dart';
import 'package:denis_phote_world/core/theme/app_colors.dart';

class BeforeAfterSlider extends StatefulWidget {
  final Widget beforeWidget;
  final Widget afterWidget;
  final double initialPosition; // 0.0 to 1.0 (default 0.5)

  const BeforeAfterSlider({
    super.key,
    required this.beforeWidget,
    required this.afterWidget,
    this.initialPosition = 0.5,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  late double _splitPosition;

  @override
  void initState() {
    super.initState();
    _splitPosition = widget.initialPosition.clamp(0.05, 0.95);
  }

  void _updatePosition(double localDx, double totalWidth) {
    if (totalWidth <= 0) return;
    setState(() {
      _splitPosition = (localDx / totalWidth).clamp(0.02, 0.98);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final totalHeight = constraints.maxHeight;
        final splitX = totalWidth * _splitPosition;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Right Side: After / Edited Image (Full width background)
            widget.afterWidget,

            // Left Side: Before / Original Image (Clipped to splitX)
            ClipRect(
              clipper: _HorizontalSplitClipper(splitX),
              child: widget.beforeWidget,
            ),

            // Vertical Split Divider Line
            Positioned(
              left: splitX - 1.5,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3.0,
                color: Colors.white,
                child: Center(
                  child: Container(
                    width: 1.0,
                    color: AppColors.turquoiseSecondary,
                  ),
                ),
              ),
            ),

            // Draggable Handle
            Positioned(
              left: splitX - 22,
              top: totalHeight / 2 - 22,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  _updatePosition(details.globalPosition.dx, totalWidth);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: AppColors.turquoiseSecondary, width: 2.5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.compare_arrows_rounded,
                      color: AppColors.turquoiseDark,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),

            // Left Pill: "Original"
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white30),
                ),
                child: const Text(
                  'Original 📷',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Right Pill: "Bearbeitet ✨"
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.pinkPrimary.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white54),
                ),
                child: const Text(
                  'Bearbeitet ✨',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Entire Area Drag Gesture Listener
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                final box = context.findRenderObject() as RenderBox?;
                if (box != null) {
                  final localPos = box.globalToLocal(details.globalPosition);
                  _updatePosition(localPos.dx, totalWidth);
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _HorizontalSplitClipper extends CustomClipper<Rect> {
  final double splitX;

  _HorizontalSplitClipper(this.splitX);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, splitX, size.height);
  }

  @override
  bool shouldReclip(covariant _HorizontalSplitClipper oldClipper) {
    return oldClipper.splitX != splitX;
  }
}
