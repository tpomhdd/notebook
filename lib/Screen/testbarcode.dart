import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

class BarcodePage extends StatelessWidget {
  final String url;
  final String address;

  BarcodePage({required this.url, required this.address});

  @override
  Widget build(BuildContext context) {
    // رابط مخصص يعتمد على معرّف الطالب


    return                      Padding(
      padding: EdgeInsets.all(7.0),
      child: Column(
        children: [
          Text(
            address,

            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),

          BarcodeWidget(
            backgroundColor: Colors.transparent,
            barcode: Barcode.qrCode(),
            data: url, // البيانات لتوليد الباركود
            width: 150,
            height:  150,
            color: Colors.blueAccent,
          ),
        ],
      ),
    );

  }
}
