import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolnot/Screen/NotebookCustomizationScreen.dart';
import 'package:schoolnot/Screen/NotebookPage.dart';
import 'package:schoolnot/Screen/NotebooksScreen.dart';
import 'package:schoolnot/Screen/assignment.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade500],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade300,
                    radius: 40,
                    //backgroundImage: AssetImage('assets/avatar.jpg'), // استبدل الصورة بأخرى أو أزلها
                    child: Icon(Icons.account_circle,color: Colors.white,size: 70,),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'مرحباً بك!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.book, color: Colors.white),
              title: Text(
                'قائمة الدفاتر',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                // الانتقال إلى صفحة قائمة الدفاتر
                Get.to(NotebooksScreen(phoneNumber: 'phoneNumber'));
              },
            ),
            Divider(color: Colors.white70),
            ListTile(
              leading: Icon(Icons.add, color: Colors.white),
              title: Text(
                'إضافة دفتر جديد',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                // الانتقال إلى صفحة إضافة دفتر جديد
                Get.to(NotebookCustomizationScreen());
              },
            ),
            Divider(color: Colors.white70),
            ListTile(
              leading: Icon(Icons.add, color: Colors.white),
              title: Text(
                'رفع واجب',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                // الانتقال إلى صفحة إضافة دفتر جديد
                Get.to(Assignment());
              },
            ),
          ],
        ),
      ),
    );
  }
}
