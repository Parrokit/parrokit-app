import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabeledTextField extends StatefulWidget {
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
    this.horizontal = false,
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
  final bool horizontal;

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller?.text.isNotEmpty ?? false;
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(LabeledTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      _hasText = widget.controller?.text.isNotEmpty ?? false;
      widget.controller?.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget textField = TextField(
      focusNode: widget.focusNode,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: tt.bodyMedium
            ?.copyWith(color: cs.onSurface.withValues(alpha: 0.35)),
        filled: false,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: InputBorder.none,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        border: InputBorder.none,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, size: 18),
        suffixIcon: widget.clearable && widget.controller != null && _hasText
            ? IconButton(
                tooltip: '지우기',
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  widget.controller!.clear();
                },
              )
            : null,
        suffixText: widget.suffixText,
      ),
    );

    if (widget.horizontal) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            child: Text(widget.label,
                style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.6))),
          ),
          const SizedBox(width: 8),
          Expanded(child: textField),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        textField,
        if (widget.helper != null) ...[
          const SizedBox(height: 6),
          Text(widget.helper!,
              style: tt.bodySmall
                  ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
        ],
      ],
    );
  }
}
