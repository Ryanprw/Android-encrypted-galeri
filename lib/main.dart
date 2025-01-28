import 'package:flutter/material.dart';
import 'package:private_vpn/screens/encryption_button.dart';
import 'services/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FileEncryptionScreen(),
    );
  }
}

class FileEncryptionScreen extends StatefulWidget {
  @override
  _FileEncryptionScreenState createState() => _FileEncryptionScreenState();
}

class _FileEncryptionScreenState extends State<FileEncryptionScreen> {
  @override
  void initState() {
    super.initState();
    requestManageExternalStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double height = size.height;
    final double width = size.width;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 43, 43, 43),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/map.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'VPN Private',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.07,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.015),
                Image.asset(
                  'assets/images/iconvpx.png',
                  height: height * 0.15,
                ),
                SizedBox(height: height * 0.015),
                Text(
                  "We have always been committed to protecting ",
                  style: GoogleFonts.inika(
                    color: Colors.white,
                    fontSize: width * 0.030,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.01),
                Text(
                  "your privacy and your data",
                  style: GoogleFonts.inika(
                    color: Colors.white,
                    fontSize: width * 0.030,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.04),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                  child: EncryptionButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
