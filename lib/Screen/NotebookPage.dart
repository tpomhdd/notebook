
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:schoolnot/Screen/BarcodeSlider.dart';
import 'package:schoolnot/Screen/Notebook_Barcodes.dart';
import 'package:schoolnot/Screen/assignment.dart';
import 'package:schoolnot/Screen/testbarcode.dart';
import 'package:schoolnot/Widget/CustomDrawer.dart';
import 'package:schoolnot/services/myclient.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotebookPage extends StatefulWidget {
  final String id;
  const NotebookPage({Key? key, required this.id}) : super(key: key);

  @override
  State<NotebookPage> createState() => _NotebookPageState();
}

class _NotebookPageState extends State<NotebookPage> {
  String? _username; // اسم المستخدم
  bool _isLoading = false;
  String? _message;
  Map<String, dynamic>? _notebook;
  late Future<List<Map<String, String>>> barcodeList;
  Future<List<Map<String, String>>> fetchBarcodes() async {
    final response = await http.get(Uri.parse('https://schoolnot.tpowep.com/contentsub?subject_id=${widget.id}'));

    if (response.statusCode == 200) {
      final List<dynamic> rawData = json.decode(response.body);

      // فك التعشيش (Extract inner list)
      if (rawData.isNotEmpty && rawData[0] is List) {
        final List<dynamic> nestedData = rawData[0]; // استخدام القائمة الداخلية
        return nestedData.map((item) {
          return {
            'content_url': item['content_url'].toString(),
            'barcode_id': item['barcode_id'].toString(),
          };
        }).toList();
      } else {
        throw Exception('تنسيق البيانات غير متوقع');
      }
    } else {
      throw Exception('فشل تحميل البيانات');
    }
  }

  @override
  void initState() {
    super.initState();
    barcodeList = fetchBarcodes();
    _loadSelectedFrame();
  }

  Future<void> fetchNotebook() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _notebook = null;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _username = sharedPreferences.getString("username");

    if (_username == null || _username!.isEmpty) {
      setState(() {
        _message = 'اسم المستخدم غير متوفر';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://schoolnot.tpowep.com/notebook-by-phone?phone=$_username'),
      );
      print('https://schoolnot.tpowep.com/notebook-by-phone?phone=$_username');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['notebook'] != null) {
          setState(() {
            _notebook = data['notebook'];
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
    } }
  String? _selectedFrame;

  Future<void> _loadSelectedFrame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedFrame = prefs.getString('selected_frame');
    });
  }

  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent.withOpacity(0.9),
        ),
        drawer: CustomDrawer(),
        body: Stack(
          children: [
            // خلفية بتدرج ألوان
            Container(
              width: MediaQuery.of(context).size.width, // عرض الشاشة
              height: MediaQuery.of(context).size.height, // ارتفاع الشاشة
              decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(_selectedFrame!),
        fit: BoxFit.cover,
      ),),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent.withOpacity(0.5), Colors.lightBlue.shade100.withOpacity(0.5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // محتوى الصفحة
            SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 500,
                      child: FutureBuilder<List<Map<String, String>>>(
                        future: barcodeList,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            print('حدث خطأ: ${snapshot.error}');
                            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                          }

                          final barcodes = snapshot.data ?? [];
                          return PageView.builder(
                            itemCount: barcodes.length,
                            itemBuilder: (context, index) {
                              return Container(
                                  width: MediaQuery.of(context).size.width, // عرض الشاشة
                                  height: MediaQuery.of(context).size.height, // ارتفاع الشاشة

                                  child: BarcodePage(

                                    url: barcodes[index]['content_url'].toString(), address:  barcodes[index]['barcode_id'].toString(),)); // عرض الباركود

                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(Assignment());

                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          'إنشاء  واجب',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  // مكون لعرض معلومات الطالب بشكل بطاقات
  Widget _buildInfoCard(String label, String value) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.info, color: Colors.blueAccent),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}
