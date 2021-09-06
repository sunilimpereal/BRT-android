import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';

class BRTfieldhead extends StatelessWidget {
  final String title;
  BRTfieldhead(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(color: BRTbrown),
    );
  }
}

class BrtTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isReadOnly;
  final TextInputType keyboardType;
  final int maxLength;
  final bool isObsecure;
  final TextCapitalization capitalization;
  final List<TextInputFormatter> inputFormatter;
  final Function(String) validator;
  BrtTextField(
      {this.hintText,
      @required this.controller,
      this.isReadOnly = false,
      this.maxLength,
      this.keyboardType,
      this.validator,
      this.capitalization,
      this.inputFormatter,
      this.isObsecure = false});

  @override
  _BrtTextFieldState createState() => _BrtTextFieldState();
}

class _BrtTextFieldState extends State<BrtTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.always,
      inputFormatters: widget.inputFormatter,
      controller: widget.controller,
      readOnly: widget.isReadOnly,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      obscureText: widget.isObsecure,
      maxLength: widget.maxLength,
      maxLengthEnforced: true,
      textCapitalization: widget.capitalization,
      validator: (String text) {
        if (widget.validator == null) {
          return null;
        } else {
          return widget.validator(text);
        }
      },
      cursorColor: BRTbrown,
      decoration: InputDecoration(
          labelStyle: TextStyle(fontSize: 12, color: BRTbrown),
          focusColor: BRTbrown,
          fillColor: BRTlightBrown,
          hintText: widget.hintText ?? "",
          filled: true,
          border: InputBorder.none),
    );
  }
}

Widget widgetSeperator() {
  return SizedBox(
    height: 10,
  );
}