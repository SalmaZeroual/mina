import 'package:flutter/material.dart';

class MinaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double height;

  const MinaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
        : Text(label);

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(onPressed: isLoading ? null : onPressed, child: child),
      );
    }
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(onPressed: isLoading ? null : onPressed, child: child),
    );
  }
}
