import 'package:flutter/material.dart';
import 'package:parrokit/core/theme/app_radius.dart';
import 'package:flutter/services.dart';

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.focusNode,
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
  final FocusNode? focusNode;
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

    OutlineInputBorder borderStyle(Color c, [double w = 0.8]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c, width: w),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          focusNode: focusNode,
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: tt.bodyMedium
                ?.copyWith(color: cs.onSurface.withValues(alpha: 0.35)),
            filled: true,
            fillColor: cs.surface,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: borderStyle(cs.outlineVariant),
            focusedBorder: borderStyle(cs.primary, 1.0),
            border: borderStyle(cs.outlineVariant),
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
              style: tt.bodySmall
                  ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
        ],
      ],
    );
  }
}
