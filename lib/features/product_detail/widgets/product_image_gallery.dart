import 'package:flutter/material.dart';
import '../../../core/widgets/cached_network_image_widget.dart';
import '../../../core/constants/app_colors.dart';

class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({super.key, required this.imageUrls});
  final List<String> imageUrls;

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  int _current = 0;
  final PageController _ctrl = PageController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        color: AppColors.primaryLight,
        child: const Icon(Icons.image_outlined,
            size: 80, color: AppColors.textHint),
      );
    }
    return Stack(
      children: [
        PageView.builder(
          controller: _ctrl,
          itemCount: widget.imageUrls.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (_, i) => CachedNetworkImageWidget(
            url: widget.imageUrls[i],
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageUrls.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _current == i ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _current == i ? AppColors.primary : Colors.white60,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}