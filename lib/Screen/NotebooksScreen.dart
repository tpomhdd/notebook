import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolnot/Screen/NotePage.dart';
import 'package:schoolnot/Screen/Notebook_Barcodes.dart';
import 'package:schoolnot/Screen/testbarcode.dart';

import '../Model/Notebook.dart';
import '../services/NotebookService.dart';
import 'BarcodeSlider.dart';

class NotebooksScreen extends StatefulWidget {
  final String phoneNumber;

  NotebooksScreen({required this.phoneNumber});

  @override
  _NotebooksScreenState createState() => _NotebooksScreenState();
}

class _NotebooksScreenState extends State<NotebooksScreen> {
  late NotebookService _notebookService;
  List<Notebook> _notebooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _notebookService = NotebookService();
    _fetchNotebooks();
  }

  Future<void> _fetchNotebooks() async {
    try {
      final notebooks = await _notebookService.fetchNotebooks(widget.phoneNumber);
      setState(() {
        _notebooks = notebooks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل الدفاتر: $e')),
      );
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(

        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _notebooks.isEmpty
              ? Center(child: Text('لا توجد دفاتر متاحة.', style: TextStyle(fontSize: 18, color: Colors.white)))
              : Container(
            height: double.infinity,
                child: Column(
                  children: [
SizedBox(height: 100,)   ,                 Center(
                      child: Text(
                        'دفاتري',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    Container(
                      height: 555,
                      child: ListView.builder(
            itemCount: _notebooks.length,
            itemBuilder: (context, index) {
                      final notebook = _notebooks[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4), // Shadow direction
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Text(
                              notebook.name.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              'الصف: ${notebook.grade}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            onTap: () {
                         notebook.subject;
                         Get.to(NotePage(id: notebook.subject.toString(),idnote: notebook.id.toString(),));

                              // توجيه المستخدم لصفحة التفاصيل (يمكنك إضافة صفحة تفاصيل هنا)
                            },
                          ),
                        ),
                      );
            },
          ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
