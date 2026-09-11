import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Memory-efficient image widget with automatic downsampling and caching
/// Complies with Google Play 2027 memory optimization requirements
class OptimizedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? cacheWidth;
  final int? cacheHeight;

  const OptimizedImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    final Widget imageWidget;

    if (imageUrl == null || imageUrl!.isEmpty) {
      imageWidget = errorWidget ?? _defaultErrorWidget();
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        // Memory optimization: downsample to exact display size
        memCacheWidth: cacheWidth ?? (width?.round() ?? 400),
        memCacheHeight: cacheHeight ?? (height?.round() ?? 300),
        maxWidthDiskCache: 800,
        maxHeightDiskCache: 600,
        // Fade in for smooth loading
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 100),
        placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
        errorWidget: (context, url, error) => errorWidget ?? _defaultErrorWidget(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _defaultPlaceholder() => Container(
    width: width,
    height: height,
    color: Colors.grey[200],
    child: const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );

  Widget _defaultErrorWidget() => Container(
    width: width,
    height: height,
    color: Colors.grey[100],
    child: Icon(
      Icons.image_not_supported_outlined,
      color: Colors.grey[400],
      size: (width ?? 100) * 0.3,
    ),
  );
}

/// Hero image for place details with optimized loading
class HeroPlaceImage extends StatelessWidget {
  final String? imageUrl;
  final String heroTag;
  final double height;
  final BorderRadius? borderRadius;

  const HeroPlaceImage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.height = 280,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: OptimizedImage(
        imageUrl: imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        borderRadius: borderRadius,
        cacheWidth: 800,
        cacheHeight: 600,
      ),
    );
  }
}