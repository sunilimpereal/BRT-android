import 'package:flutter/material.dart';

class TripTextField extends StatefulWidget {
  final String hint;

  final TextEditingController controller;
  final FocusNode focusNode;
  Function(String) onSubmitted;
  bool readOnly;
  TripTextField({
    Key key,
    this.controller,
    this.onSubmitted,
    this.focusNode,
    this.hint,
    this.readOnly,
  }) : super(key: key);

  @override
  _TripTextFieldState createState() => _TripTextFieldState();
}

class _TripTextFieldState extends State<TripTextField> with TickerProviderStateMixin {
  bool isbarcode = false;
  @override
  void initState() {
    widget.controller.addListener(() {
      if (widget.controller.text.isNotEmpty) {
        setState(() {
          isbarcode = true;
        });
      } else if (widget.controller.text.isEmpty) {
        setState(() {
          isbarcode = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
        child: Stack(
          children: [
            Positioned(
                top: 10,
                bottom: 10,
                right: 10,
                child: AnimatedSwitcher(
                    switchInCurve: Curves.easeInOutBack,
                    transitionBuilder: (child, animation) => ScaleTransition(
                          child: child,
                          scale: animation,
                        ),
                    duration: const Duration(milliseconds: 400),
                    child: !isbarcode ? barcode() : suffixBox())),
            TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                onChanged: (value) {},
                readOnly: true,
                onSubmitted: widget.onSubmitted,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 20, top: 10, right: 60, bottom: 10),
                  labelText: widget.hint,
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color.fromARGB(255, 90, 90, 90),
                  ),
                  fillColor: Colors.yellow,
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green, width: 2.0),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget suffixBox() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.09,
      height: MediaQuery.of(context).size.height * 0.1,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0), color: Colors.green.withOpacity(0.2)),
      child: const Icon(Icons.done, color: Colors.green),
    );
  }

  Widget barcode() {
    return Image.asset('assets/images/qrcode.png');
  }
}
