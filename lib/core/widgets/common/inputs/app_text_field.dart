import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trackpense/core/config/app_config.dart';

class AppTextFormField extends StatefulWidget {
  const AppTextFormField({
    super.key,
    required this.controller,
    this.showTextLengthCounter = false,
    this.outlineBorder = false,
    this.labelText,
    this.autovalidateMode,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.minLines,
    this.maxLines = 1,
    this.hintText,
    this.maxLength,
  });

  final TextEditingController controller;
  final bool showTextLengthCounter;
  final bool outlineBorder;
  final String? labelText;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int maxLines;
  final String? hintText;
  final int? maxLength;

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  @override
  Widget build(BuildContext context) {
    final textLength = widget.controller.text.length;
    final effectiveMaxLength = widget.maxLength ?? AppConfig.maxDescriptionLength;

    return TextFormField(
      controller: widget.controller,
      onChanged: widget.showTextLengthCounter ? (value) => setState(() {}) : null,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        border: widget.outlineBorder ? const OutlineInputBorder() : null,
        helper: widget.showTextLengthCounter
            ? Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$textLength/$effectiveMaxLength',
                  style: TextStyle(
                    color: textLength > effectiveMaxLength ? Colors.red : Colors.grey,
                    fontSize: 10,
                  ),
                ),
              )
            : null,
      ),
      autovalidateMode: widget.autovalidateMode,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      maxLength: widget.showTextLengthCounter ? effectiveMaxLength : null,
    );
  }
}
