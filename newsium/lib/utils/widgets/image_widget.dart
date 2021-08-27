import 'package:flutter/material.dart';
import 'package:newsium/utils/app_image.dart';

class ImageWidget extends StatelessWidget {
  final String? url;
  final BorderRadius? borderRadius;

  const ImageWidget({Key? key, this.url, this.borderRadius})
      : assert(url != null);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: FadeInImage.assetNetwork(
        fit: BoxFit.cover,
        image: url!,
        placeholder: AppImage.placeholder,
      ),
    );
  }
}
