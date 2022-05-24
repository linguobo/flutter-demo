import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AlertUtil {
  static toast(msg) {
    return Fluttertoast.showToast(
      msg: msg,
      timeInSecForIosWeb: 2,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.7),
    );
  }

  static toastLoading([context]) {
    return "加载中";
  }

  static msg(BuildContext context, String msg) {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)) );
    toast(msg);
  }

  static alert(BuildContext context, Widget widget) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: widget,
          actions: const [
            // okButton,
          ],
        );
      },
    );
  }
}
