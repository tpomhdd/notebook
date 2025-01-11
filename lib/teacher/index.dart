import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolnot/Screen/AddClass.dart';
import 'package:schoolnot/Screen/NotebookCustomizationScreen.dart';
import 'package:schoolnot/teacher/AddContent.dart';
import 'package:schoolnot/teacher/add_sections.dart';
import 'package:schoolnot/teacher/classroom.dart';
class index extends StatefulWidget {
  const index({Key? key}) : super(key: key);

  @override
  State<index> createState() => _indexState();
}

class _indexState extends State<index> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:             Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
Get.to(AddContentScreen());
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'رفع المحتوى',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 16),
            // رابط تسجيل الدخول
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
Get.to(AddClass());
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'اضافة صف',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 16),
            // رابط تسجيل الدخول
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
Get.to(add_sections());
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'اضافة الشعبة',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 16),
            // رابط تسجيل الدخول
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
Get.to(NotebookCustomizationScreen());
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'اضافة دفتر ',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 16),
            // رابط تسجيل الدخول
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
Get.to(ClassListScreen());
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'قائمة الصفوف ',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 16),
            // رابط تسجيل الدخول

          ],
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),

    );
  }
}
