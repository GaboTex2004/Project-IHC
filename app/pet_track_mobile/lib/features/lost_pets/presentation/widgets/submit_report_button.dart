import 'package:flutter/material.dart';

class SubmitReportButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;

  const SubmitReportButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Publicar Reporte',
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6C63FF);
    const secondaryColor = Color(0xFF4D44D5);

    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: onPressed == null || isLoading
            ? null
            : const LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        boxShadow: onPressed == null || isLoading
            ? []
            : [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.grey.shade300,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.campaign_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
