import 'package:flutter/material.dart';
import '../../constants.dart';

// ignore: must_be_immutable
class CustomCard extends StatelessWidget {
  Container _titleWidget;
  Widget _child;
  String _titleText;

  CustomCard({@required Widget child, String title = "               "}) {
    _child = child;
    _titleText = title;
    _titleWidget = Container(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
          color: Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(20)),
      child: Text(
        _titleText,
        textScaleFactor: 1.3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: 14),
            child: _child,
            decoration: BoxDecoration(
                gradient: gradient, borderRadius: BorderRadius.circular(13)),
          ),
          _titleWidget
        ],
      );
}
