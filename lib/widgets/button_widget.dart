import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final Function() onTap;
  final String btnText;
  const ButtonWidget(this.onTap, this.btnText, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.blue,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: kToolbarHeight,
            child: Center(
              child: Text(
                btnText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
