import 'package:flutter/material.dart';

class InfoBox extends StatelessWidget {
  final String text;

  const InfoBox({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromRGBO(235, 247, 255, 1.0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color.fromRGBO(100, 181, 246, 1.0)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[700],
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blueGrey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
