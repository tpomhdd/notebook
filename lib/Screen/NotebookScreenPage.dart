import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../services/PrintService.dart';
import 'BarcodeSlider.dart';

class NotebookScreenPage extends StatefulWidget {
 final String id;
 final String count;

const  NotebookScreenPage({ required this.id, required this.count});
  @override

  _NotebookScreenPageState createState() => _NotebookScreenPageState();
}

class _NotebookScreenPageState extends State<NotebookScreenPage> {
  final PageController _pageController = PageController();
  int pageCount = 5; // عدد الصفحات الافتراضي

  void _addNewPage() {
    setState(() {
      pageCount++; // زيادة عدد الصفحات عند الضغط على زر الإضافة
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: pageCount,
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return NotebookPage();
        },
      ),

    );
  }
}

class NotebookPage extends StatefulWidget {
  @override
  _NotebookPageState createState() => _NotebookPageState();
}

class _NotebookPageState extends State<NotebookPage> {
  final GlobalKey _globalKey = GlobalKey();

  Future<List<Map<String, dynamic>>> fetchAssignments() async {
    final response = await http.get(Uri.parse('https://schoolnot.tpowep.com/getAssignmentall'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['Assignment']);
    } else {
      throw Exception('فشل في جلب البيانات');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: Scaffold(
        bottomNavigationBar: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text("العودة إلى الصفحة الرئيسية"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // تنفيذ طباعة الشاشة
          },
          child: Icon(Icons.print, size: 25),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        body: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16),
          child: Stack(
            children: [
              // الخطوط المسطرة
              SingleChildScrollView(
                child: Column(
                  children: List.generate(
                    100,
                        (index) => Container(
                      height: 24,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // جلب البيانات وعرضها
              Positioned.fill(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchAssignments(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('حدث خطأ أثناء جلب البيانات'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('لا يوجد بيانات متاحة'));
                    }

                    final assignments = snapshot.data!;

                    return ListView.builder(
                      itemCount: assignments.length,
                      itemBuilder: (context, index) {
                        final assignment = assignments[index];
                        return ListTile(
                          title: Text(assignment['assignment_name'] ?? 'بدون اسم'),
                          subtitle: Text(assignment['description'] ?? 'بدون وصف'),
                          leading: assignment['file_path'] != null &&
                              assignment['file_path'].startsWith('http')
                              ? Image.network(assignment['file_path'], width: 50, height: 50, fit: BoxFit.cover)
                              : Icon(Icons.assignment),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
