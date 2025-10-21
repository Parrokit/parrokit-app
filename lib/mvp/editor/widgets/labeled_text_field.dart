import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.helper,
    this.prefixIcon,
    this.suffixText,
    this.clearable = false,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? helper;
  final IconData? prefixIcon;
  final String? suffixText;
  final bool clearable;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    OutlineInputBorder _border(Color c, [double w = 0.8]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: w),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
            tt.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.35)),
            filled: true,
            fillColor: cs.surface,
            isDense: true,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: _border(cs.outlineVariant),
            focusedBorder: _border(cs.primary, 1.0),
            border: _border(cs.outlineVariant),
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 18),
            suffixIcon:
            clearable && controller != null && (controller!.text.isNotEmpty)
                ? IconButton(
              tooltip: '지우기',
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () {
                controller!.clear();
                (context as Element).markNeedsBuild();
              },
            )
                : null,
            suffixText: suffixText,
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(helper!,
              style:
              tt.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.6))),
        ],
      ],
    );
  }
}
