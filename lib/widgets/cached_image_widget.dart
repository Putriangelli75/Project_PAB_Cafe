import 'package:flutter/material.dart';

/// Efficient image loader with auto-precache on first build
class OptimizedAssetImage extends StatefulWidget {
  final String assetPath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final bool enableCache;

  const OptimizedAssetImage({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.backgroundColor,
    this.enableCache = true,
  });

  @override
  State<OptimizedAssetImage> createState() => _OptimizedAssetImageState();
}

class _OptimizedAssetImageState extends State<OptimizedAssetImage> {
  late ImageProvider _imageProvider;
  bool _imagePrecached = false;

  @override
  void initState() {
    super.initState();
    _imageProvider = AssetImage(widget.assetPath);

    // Precache in background without blocking UI
    if (widget.enableCache && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_imagePrecached) {
          precacheImage(_imageProvider, context).then((_) {
            if (mounted) {
              setState(() => _imagePrecached = true);
            }
          }).catchError((_) {
            // Silently fail - UI still renders with errorBuilder
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.backgroundColor,
      child: Image(
        image: _imageProvider,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: Icon(
              Icons.broken_image,
              size: (widget.height ?? 100) * 0.4,
              color: Colors.grey[600],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
  }
}