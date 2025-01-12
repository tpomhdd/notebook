import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:schoolnot/Screen/BarcodeSlider.dart';


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolnot/Screen/BarcodeSlider.dart';
import 'package:schoolnot/Screen/NotebookScreenPage.dart';
import 'package:schoolnot/Screen/testbarcode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;
import 'package:schoolnot/Widget/man_widget/mytext.dart';

import 'package:turn_page_transition/turn_page_transition.dart';

import '../Widget/CustomDrawer.dart';
import '../services/PrintService.dart';
import '../services/SubjectService.dart';
import 'NotePage.dart';

class HomePage extends StatefulWidget {
  final String id;
  final String idnote;
  const HomePage({Key? key, required this.id, required this.idnote}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  String? _username; // اسم المستخدم
  bool _isLoading = false;
  String? _message;
  Map<String, dynamic>? _notebook;
  String? subjectName;
  String? subjectid;
  bool isLoading = true;
  final SubjectService _subjectService = SubjectService();



  Future<void> fetchSubject() async {
    try {
      String name = await _subjectService.fetchSubjectName(int.parse(widget.id));
      setState(() {
        subjectName = name;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        subjectName = "غير متوفر";
        isLoading = false;
      });
    }
  }

  Future<void> fetchNotebook() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _notebook = null;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _username = widget.idnote;

    if (_username == null || _username!.isEmpty) {
      setState(() {
        _message = 'اسم المستخدم غير متوفر';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://schoolnot.tpowep.com/notebook-by-id?id=$_username'),
      );
      print('https://schoolnot.tpowep.com/notebook-by-id?id=$_username');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          print(data['data'][0].toString());
          setState(() {
            _notebook = data['data'][0];
            _message = data['message'];
          });
        } else {
          setState(() {
            _message = 'الدفتر غير موجود';
          });
        }
      } else {
        setState(() {
          _message = 'فشل في جلب البيانات';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'حدث خطأ: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    fetchSubject();
    fetchNotebook();
  }


@override
  Widget build(BuildContext context) {
    final GlobalKey _globalKey = GlobalKey();
// متغير لتتبع الصفحة الحالية
  final List<Widget> pages = List.generate(
    50, // عدد الصفحات التي تريد إنشاؤها
        (index) => PageContent(
      title: "الصفحة ${index + 1}",
      id: widget.idnote,
      content:index.toString(),
    ),
  );

  return Directionality(
      textDirection: TextDirection.ltr,

      child: Scaffold(

        floatingActionButton: FloatingActionButton(
          onPressed: () => PrintService.printScreen(context, _globalKey),
          child: Icon(Icons.print,size: 25,),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat, // تحريك الزر إلى اليسار


        appBar: AppBar(),  backgroundColor: Color(0xFF5A7968), // اللون الأخضر الخلفي
        drawer: CustomDrawer(),
        body: RepaintBoundary(
          key: _globalKey,

          child: Center(
            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // الشريط الرمادي العلوي مع النص
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'دفتر مدرسي',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_notebook != null && _notebook!['logoUrl'] != null)
                  Container(
                    width: 200,
                    height: 200,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      image: DecorationImage(
                        image: NetworkImage(_notebook!['logoUrl']),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                SizedBox(height: 22,),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // الانتقال إلى الصفحة التالية
                      currentIndex = (currentIndex + 1) % pages.length;
                    });
                    Navigator.of(context).push(
                      TurnPageRoute(
                        overleafColor: Colors.white, // لون الوجه الخلفي للصفحة
                        transitionDuration: Duration(milliseconds: 800), // سرعة الطي
                        reverseTransitionDuration: Duration(milliseconds: 800),
                        builder: (context) => pages[currentIndex], // الانتقال إلى الصفحة التالية
                      ),
                    );
                  },
                  child: Text("انتقل إلى الصفحة التالية"),
                ),


                SizedBox(height: 100),
                Container(
                  height: 200,
                  child: Row(


                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(

                          padding: EdgeInsets.all(8),
                          child: _notebook != null && _notebook!['Subject'] != null
                              ? Container(
                            color: Colors.transparent,
                            height: 150,
                            width: 100,
                            child: BarcodeSlider20(id: _notebook!['Subject'].toString()),
                          )
                              : Container(
                            height:75 ,
                            width: 75,
                            alignment: Alignment.center,
                            child: Text(
                              'جاري التحميل',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      // الحقول السفلية (اسم، المادة، الصف)
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 250,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildField('الاسم', _notebook != null ? _notebook!['namenot'] ?? '' : ''),
                                SizedBox(height: 10),
                                buildField('الصف', _notebook != null ? _notebook!['grade'] ?? '' : ''),
                                buildField('المادة',subjectName.toString()),
                                SizedBox(height: 10),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // الرقم داخل الدائرة



                // QR Code السفلي

              ],
            ),
          ),
        ),
      ),
    );

  }
}
class PageContent extends StatefulWidget {
  final String title;
  final  String content;
  final String id;

  PageContent({required this.title, required this.id, required this.content});

  @override
  _PageContentState createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  final GlobalKey _globalKey = GlobalKey();
  List<Map<String, dynamic>> assignments = [];

  @override
  void initState() {
    super.initState();
    fetchAssignments();
  }

  Future<void> fetchAssignments() async {
    try {
      final response =
      await http.get(Uri.parse('https://schoolnot.tpowep.com/getAssignmentall?notebook=${widget.id}'));
      print('https://schoolnot.tpowep.com/getAssignmentall?notebook=${widget.id}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          assignments = List<Map<String, dynamic>>.from(data['Assignment']);
        });
      } else {
        throw Exception('❌ فشل جلب البيانات');
      }
    } catch (e) {
      print('🚨 خطأ أثناء جلب البيانات: $e');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // تحويل `widget.content` إلى رقم بأمان
    int index = 0;


    final assignment = assignments[index];
print(assignment.toString());
    return Scaffold(
      bottomNavigationBar: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: Text("العودة إلى الصفحة الرئيسية"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => PrintService.printScreen(context, _globalKey),
        child: Icon(Icons.print, size: 25),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: RepaintBoundary(
        key: _globalKey,
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16),
          child: Stack(
            children: [
              // خلفية الصفحة المسطرة
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

              // قائمة البيانات من API
              Positioned.fill(
                child:assignment['page']==widget.content? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText(color: Colors.black, text: assignment['description'] ?? 'بدون وصف', size: 22),
                    BarcodePage(
                      url: assignment['file_path'],
                      address: assignment['assignment_name'] ?? 'بدون اسم',
                    ),
                  ],
                ):SizedBox(),
              ),

              // مكان الباركود
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  color: Colors.transparent,
                  height: 150,
                  width: 100,
                  child: BarcodeSlider20(id: widget.id),
                ),
              ),

              // عنوان الصفحة
              Positioned(
                bottom: 1,
                left: 20,
                child: Container(
                  color: Colors.transparent,
                  height: 150,
                  width: 100,
                  child: Text(
                    widget.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
