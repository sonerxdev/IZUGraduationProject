import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unicamp/shared/constants.dart';
import 'package:unicamp/shared/context_extension.dart';

linearProgressWidget() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 12.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(secondColor),
    ),
  );
}

circularProgressWidget() {
  return CircularProgressIndicator(
    backgroundColor: mainColor,
    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    strokeWidth: 2.0,
  );
}

//Buton
class ButtonWidget extends StatelessWidget {
  final String text;
  final Color borderColor;
  final Color textColor;
  final Color buttonColor;
  final double textSize;
  final VoidCallback onPressed;
  final double width;

  const ButtonWidget(
      {Key key,
      this.text,
      this.borderColor,
      this.onPressed,
      this.textColor,
      this.buttonColor,
      this.textSize,
      this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: RaisedButton(
          color: buttonColor,
          child: Text(
            "$text",
            style: TextStyle(
              color: textColor,
              fontSize: textSize,
            ),
          ),
          onPressed: onPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
            side: BorderSide(
              color: borderColor,
            ),
          ),
          padding: context.paddingLow),
    );
  }
}

class CupertinoPickerWidget extends StatelessWidget {
  final String text;
  final List<Widget> children;
  final Function(int data) onSelectedItemChanged;
  final Function onTap;
  const CupertinoPickerWidget(
      {Key key,
      this.text,
      this.onSelectedItemChanged,
      this.children,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonWidget(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext builder) {
            return Container(
              child: GestureDetector(
                onTap: onTap,
                child: CupertinoPicker(
                    backgroundColor: secondColor,
                    children: children,
                    itemExtent: 50,
                    looping: false,
                    scrollController: FixedExtentScrollController(
                      initialItem: 0,
                    ),
                    onSelectedItemChanged: onSelectedItemChanged),
              ),
              height: MediaQuery.of(context).copyWith().size.height / 3,
            );
          },
        );
      },
      width: context.dynamicWidth(0.7),
      text: text,
      buttonColor: secondColor,
      borderColor: secondColor,
      textColor: Colors.white,
    );
  }
}
