import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schoolnot/services/myclient.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Controller/GradesController.dart';
import '../Controller/ImageUploadController.dart';

class NotebookCustomizationScreen extends StatefulWidget {
  @override
  _NotebookCustomizationScreenState createState() =>
      _NotebookCustomizationScreenState();
}

class _NotebookCustomizationScreenState
    extends State<NotebookCustomizationScreen> {
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
  List<dynamic> subjects = []; // قائمة المواد


  List<dynamic> grades2 = []; // قائمة الصفوف
  String? pagetype;
  String? type;
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
  String? selectedSubject; // المادة المختارة

  // جلب المواد من API
  Future<void> loadSubjects() async {
    try {
      final List<dynamic> fetchedSubjects = await _gradesController.fetchSubjects();
      setState(() {
        subjects = fetchedSubjects;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل المواد')),
      );
    }
  }


  // رفع الصورة وإضافة الدفتر
  Future<void> uploadLogoAndAddNotebook() async {
    if (selectedGrade == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('يرجى اختيار الصف')));
      return;
    }

    if (_controller.selectedImage == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('يرجى اختيار شعار أولاً')));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // رفع الصورة
      final response = await _controller.uploadImage();
      if (response.contains('http')) {
         SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
        String username = sharedPreferences.get("username").toString();
_controller.id=selectedSubject;



        // الصورة تم رفعها بنجاح، إتمام إضافة الدفتر
        await myclient().AddNetbook(
          _nameController.text,
          selectedGrade.toString(), // الصف المختار
          selectedGrade2.toString(),
          _courseController.text,
          response, // رابط الصورة من الخادم
          username,
          _tokenController.text,
          selectedSubject.toString(),
          _pageController.text,
          type.toString(),
          pagetype.toString()
        );
         myclient.notebook('username');
         ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تم إنشاء الدفتر بنجاح')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('فشل رفع الشعار: $response')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }

  }
  @override
  void initState() {
    super.initState();
    loadSubjects();
    loadGrades(); // جلب البيانات عند تشغيل الصفحة
    loadGrades2();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
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
                    'تصميم الدفتر المدرسي',
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
                  child: GestureDetector(
                    onTap: () {
                      Get.defaultDialog(
                        title: 'اختيار الشعار',
                        content: Column(
                          children: [
                            MaterialButton(
                              onPressed: () => _controller
                                  .pickImage(ImageSource.gallery),
                              child: Text('المعرض'),
                            ),
                            MaterialButton(
                              onPressed: () =>
                                  _controller.pickImage(ImageSource.camera),
                              child: Text('الكاميرا'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade200, Colors.blueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade100,
                            blurRadius: 8,
                            offset: Offset(4, 4),
                          ),
                        ],
                      ),
                      child: Icon(Icons.add_a_photo,
                          size: 60, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'تفاصيل الدفتر:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 15),
                _buildTextField('الاسم', Icons.person, _nameController),
                SizedBox(height: 15),
                // قائمة المواد
                SizedBox(height: 16),
                // القائمة المنسدلة لاختيار الدور
                DropdownButtonFormField<String>(
                  value: pagetype,
                  decoration: InputDecoration(
                    labelText: 'اختر نوع الصفحات',
                    labelStyle: TextStyle(color: Colors.white),
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
                  items: ['A4', 'A5','A7']
                      .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
                      .toList(),
                  onChanged: (value) {
                    pagetype=value;

                  },
                ),
                SizedBox(height: 16),
                // القائمة المنسدلة لاختيار الدور
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: InputDecoration(
                    labelText: 'اختر نوع الدفتر',
                    labelStyle: TextStyle(color: Colors.white),
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

                  items: ["دفتر مدرسي", 'المفكرة']
                      .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
                      .toList(),
                  onChanged: (value) {
                    type=value;

                  },
                ),
                SizedBox(height: 16),
                _buildTextField('عدد الصفحات', Icons.pages, _pageController),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSubject,
                  decoration: InputDecoration(
                    labelText: 'اختر المادة',
                    labelStyle: TextStyle(color: Colors.white),
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
                  dropdownColor: Colors.blue.shade100,
                  hint: Text(
                    'اختر مادة',
                    style: TextStyle(color: Colors.white),
                  ),
                  items: subjects.map((subject) {
                    return DropdownMenuItem<String>(
                      value: subject['id'].toString(),
                      child: Text(
                        subject['name'],
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSubject = value;
                    });
                  },
                ),
                SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: selectedGrade,
                  decoration: InputDecoration(
                    labelText: 'اختر الصف',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.blue.withOpacity(0.2),
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
                  dropdownColor: Colors.blue.shade100,
                  hint: Text(
                    'اختر صفًا',
                    style: TextStyle(color: Colors.white),
                  ),
                  items: grades.map((grade) {
                    return DropdownMenuItem<String>(
                      value: grade['name'],
                      child: Text(
                        grade['name'],
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGrade = value;
                    });
                  },
                ),
                SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedGrade2,
                  decoration: InputDecoration(
                    labelText: 'اختر الصف',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.deepOrange.withOpacity(0.2),
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
                  dropdownColor: Colors.blue.shade100,
                  hint: Text(
                    'اختر الشعبة',
                    style: TextStyle(color: Colors.white),
                  ),
                  items: grades2.map((grade) {
                    return DropdownMenuItem<String>(
                      value: grade['name'],
                      child: Text(
                        grade['name'],
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGrade2 = value;
                    });
                  },
                ),
                SizedBox(height: 15),
          //      _buildTextField('الشعبة', Icons.group, _sectionController),
                SizedBox(height: 15),
                _buildTextField('الدورة/الورشة', Icons.book, _courseController),
                SizedBox(height: 30),
                Center(
                  child: _isUploading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: uploadLogoAndAddNotebook,
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
                      'إنشاء الدفتر',
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
