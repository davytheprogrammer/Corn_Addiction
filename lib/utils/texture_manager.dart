import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextureManager {
  static const MethodChannel _channel = MethodChannel('texture_manager');

  /// Clear texture cache to free up GPU memory
  static Future<void> clearTextureCache() async {
    try {
      // Clear Flutter's image cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // Force garbage collection
      await _forceGarbageCollection();

      debugPrint('Texture cache cleared successfully');
    } catch (e) {
      debugPrint('Failed to clear texture cache: $e');
    }
  }

  /// Force garbage collection to free memory
  static Future<void> _forceGarbageCollection() async {
    try {
      await _channel.invokeMethod('forceGC');
    } catch (e) {
      // Fallback: trigger GC through creating and disposing objects
      for (int i = 0; i < 10; i++) {
        List.generate(1000, (index) => Object()).clear();
      }
    }
  }

  /// Optimize image cache settings
  static void optimizeImageCache() {
    final imageCache = PaintingBinding.instance.imageCache;

    // Reduce cache size to prevent texture memory issues
    imageCache.maximumSize = 50; // Reduced from default 1000
    imageCache.maximumSizeBytes = 50 << 20; // 50MB instead of 100MB

    debugPrint(
        'Image cache optimized: ${imageCache.maximumSize} images, ${imageCache.maximumSizeBytes ~/ (1024 * 1024)}MB');
  }

  /// Check current memory usage
  static void logMemoryUsage() {
    final imageCache = PaintingBinding.instance.imageCache;
    debugPrint(
        'Image cache: ${imageCache.currentSize}/${imageCache.maximumSize} images, '
        '${(imageCache.currentSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB/'
        '${(imageCache.maximumSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB');
  }
}

/// Widget that automatically manages texture memory
class TextureOptimizedWidget extends StatefulWidget {
  final Widget child;
  final bool clearCacheOnDispose;

  const TextureOptimizedWidget({
    super.key,
    required this.child,
    this.clearCacheOnDispose = false,
  });

  @override
  State<TextureOptimizedWidget> createState() => _TextureOptimizedWidgetState();
}

class _TextureOptimizedWidgetState extends State<TextureOptimizedWidget> {
  @override
  void initState() {
    super.initState();
    TextureManager.optimizeImageCache();
  }

  @override
  void dispose() {
    if (widget.clearCacheOnDispose) {
      TextureManager.clearTextureCache();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
