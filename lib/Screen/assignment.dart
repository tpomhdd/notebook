import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schoolnot/services/myclient.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Controller/GradesController.dart';
import '../Controller/ImageUploadController.dart';

class Assignment extends StatefulWidget {
  @override
  _AssignmentState createState() =>
      _AssignmentState();
}

class _AssignmentState
    extends State<Assignment> {
  final ImageUploadController _controller = ImageUploadController();
  final GradesController _gradesController = GradesController(); // كنترولر الصفوف
  final GradesController2 _gradesController2 = GradesController2(); // كنترولر الصفوف
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();


  bool _isUploading = false;
  List<dynamic> grades = []; // قائمة الصفوف
  String? selectedGrade; // الصف المختار


  List<dynamic> grades2 = []; // قائمة الصفوف
  String? selectedGrade2; // الصف المختار

  // جلب البيانات من API عبر الكنترولر
  Future<void> loadGrades() async {
    final fetchedGrades = await _gradesController.fetchGrades();
    setState(() {
      grades = fetchedGrades; // تخزين البيانات
    });
  }

  // جلب البيانات من API عبر الكنترولر
  Future<void> loadGrades2() async {
    final fetchedGrades2 = await _gradesController2.fetchGrades();
    setState(() {
      grades2 = fetchedGrades2; // تخزين البيانات
    });
  }

  // رفع الصورة وإضافة الدفتر
  Future<void> uploadLogoAndAddNotebook() async {
 }
  @override
  void initState() {
    super.initState();
    loadGrades(); // جلب البيانات عند تشغيل الصفحة
    loadGrades2();
  }

  @override
  Widget build(BuildContext context) {
   // _nameController.text='0';
   // _courseController.text='0';
   //
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.blueAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Center(
                  child: Text(
                    'رفع واجب',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // اختيار اللوجو
                _controller.selectedImage != null
                    ? Image.file(
                  _controller.selectedImage!,
                  height: 200,
                )
                    : Center(
                  child: SizedBox(),
                ),
                SizedBox(height: 30),


                SizedBox(height: 15),
                _buildTextField('عنوان الواجب', Icons.person, _nameController),

                SizedBox(height: 15),
                _buildTextField('تفاصيل الواجب', Icons.book, _courseController),
                SizedBox(height: 30),
                _buildTextField('الرابط', Icons.book, _tokenController),
                SizedBox(height: 30),
                _buildTextField('رقم الصفحة', Icons.book, _pageController),
                SizedBox(height: 30),
                Center(
                  child: _isUploading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () async {

                      SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                      String username = sharedPreferences.get("id").toString();



                      print(username.toString());
                      // الصورة تم رفعها بنجاح، إتمام إضافة الدفتر
                      await myclient().assignment(
                          _nameController.text,

                          _courseController.text,
                          _tokenController.text, // رابط الصورة من الخادم
                          username,
                        _pageController.text
                      );


                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 32.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'رفع الواجب',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white54, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white, width: 2.0),
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}
