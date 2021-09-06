import 'package:flutter/material.dart';

enum DialogAction { yes, abort }

class Dialogs {
  static Future<DialogAction> yesAbortDialog(
    BuildContext context,
    Widget child,
  ) async {
    final action = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            child: child,
            elevation: 1,
          );
        });
        // AlertDialog(
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   title: Text(title),
        //   content: Text(body),
        //   actions: <Widget>[
        //     FlatButton(
        //       onPressed: () => Navigator.of(context).pop(DialogAction.abort),
        //       child: const Text('No'),
        //     ),
        //     RaisedButton(
        //       onPressed: () => Navigator.of(context).pop(DialogAction.yes),
        //       child: const Text(
        //         'Yes',
        //         style: TextStyle(
        //           color: Colors.white,
        //         ),
        //       ),
        //     ),
        //   ],
        // );
      },
    );
    return (action != null) ? action : DialogAction.abort;
  }
}

class DialogSheet extends StatefulWidget {
  final Widget child;
  DialogSheet(this.child);
  @override
  _DialogSheetState createState() => _DialogSheetState();
}

class _DialogSheetState extends State<DialogSheet> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: widget.child,
      elevation: 1,
    );
  }
}
