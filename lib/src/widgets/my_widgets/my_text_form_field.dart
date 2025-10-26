import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextFormField extends StatefulWidget {
  const MyTextFormField({
    super.key,
    required this.controller,
    this.showTextLengthCounter = false,
    this.outlineBOrder = false,
    this.labelText,
    this.autovalidateMode,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.minLines,
    this.maxLines = 1,
    this.hintText,
  });

  final TextEditingController controller;
  final bool showTextLengthCounter;
  final bool outlineBOrder;
  final String? labelText;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int maxLines;
  final String? hintText;

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  @override
  Widget build(BuildContext context) {
    final textLength = widget.controller.text.length;

    return TextFormField(
      controller: widget.controller,
      onChanged: widget.showTextLengthCounter ? (value) => setState(() {}) : null,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        border: widget.outlineBOrder ? const OutlineInputBorder() : null,
        helper: widget.showTextLengthCounter
            ? Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$textLength/200',
                  style: TextStyle(
                    color: textLength > 200 ? Colors.red : Colors.grey,
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
    );
  }
}
