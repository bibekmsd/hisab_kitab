import 'package:flutter/material.dart';
import 'package:svg_flutter/svg_flutter.dart';

class SvgIcon extends StatelessWidget {
  final String assetName;
  final Color? color;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const SvgIcon({
    super.key,
    required this.assetName,
    this.color,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      getSvg,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
    );
  }

  String get getSvg => 'assets/svg/$assetName.svg';
}
