import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UIHelper {
  // Changed to PascalCase for class name
  // Custom button with improved flexibility
  static Widget customButton({
    required VoidCallback onPressed,
    required String text,
    IconData? icon,
    Color backgroundColor = Colors.blue,
    Color textColor = Colors.white,
    double borderRadius = 26.0,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    bool isLoading = false, // 👈 add loading state
  }) {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: textColor, size: 18),
                      SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontFamily: "Poppins",
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Enhanced text field with more customization options
  static Widget customTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 25.0,
      vertical: 15.0,
    ),
    double borderRadius = 18.0,
    Color focusedBorderColor = Colors.blue,
    int? maxLines = 1,
    int? minLines,
    bool enabled = true,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: padding,
      child: TextFormField(
        validator: validator,
        style: TextStyle(color: Colors.black),
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        minLines: minLines,
        enabled: enabled,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: prefixIcon,

          labelStyle: TextStyle(color: Colors.blue),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: focusedBorderColor),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }

  static customalertbox(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message, style: GoogleFonts.poppins(fontSize: 15),textAlign: TextAlign.center,  ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
