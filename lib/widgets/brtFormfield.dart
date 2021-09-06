import 'package:BRT/widgets/utilityWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BrtFormField extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final String hintText;
  final Function(String) validator;
  final bool isReadOnly;
  final bool isObsecure;
  final TextInputType textInputType;
  final List<TextInputFormatter> inputFormatter;
  final TextCapitalization capitalization;
  final int maxLength;

  BrtFormField(
      {@required this.title,
      @required this.controller,
      this.hintText,
      this.isReadOnly = false,
      this.textInputType,
      this.capitalization,
      this.maxLength,
      this.validator,
      this.inputFormatter,
      this.isObsecure = false});

  @override
  _BrtFormFieldState createState() => _BrtFormFieldState();
}

class _BrtFormFieldState extends State<BrtFormField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BRTfieldhead(widget.title),
            SizedBox(
              height: 10,
            ),
            BrtTextField(
              capitalization: widget.capitalization ?? TextCapitalization.none,
              inputFormatter: widget.inputFormatter,
              keyboardType: widget.textInputType,
              validator: widget.validator,
              controller: widget.controller,
              hintText: widget.hintText,
              isReadOnly: widget.isReadOnly,
              isObsecure: widget.isObsecure,
              maxLength: widget.maxLength,
            )
          ],
        ),
      ),
    );
  }
}
