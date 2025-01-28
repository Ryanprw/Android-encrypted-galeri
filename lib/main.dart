import 'package:flutter/material.dart';
import 'package:private_vpn/screens/encryption_button.dart';
import 'services/permission_handler.dart'; // Import permission_handler.dart
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
    requestManageExternalStoragePermission(); // Meminta izin saat aplikasi dimulai
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar
    final size = MediaQuery.of(context).size;
    final double height = size.height;
    final double width = size.width;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 43, 43, 43), // Background gelap
      body: Stack(
        children: [
          // Gambar latar belakang
          Positioned.fill(
            child: Image.asset(
              'assets/images/map.png',
              fit: BoxFit.cover, // Mengatur gambar untuk menutupi seluruh area
            ),
          ),
          // Konten utama
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Teks "VPN Private"
                Text(
                  'VPN Private',
                  style: TextStyle(
                    color: Colors.white, // Warna teks putih
                    fontSize:
                        width * 0.07, // Menyesuaikan ukuran font (lebih kecil)
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.015), // Mengurangi jarak
                // Logo VPN
                Image.asset(
                  'assets/images/iconvpx.png', // Pastikan logo VPN ada di folder assets
                  height:
                      height * 0.15, // Menyesuaikan tinggi logo (lebih kecil)
                ),
                SizedBox(height: height * 0.015), // Mengurangi jarak
                // Teks untuk menjelaskan komitmen privasi
                Text(
                  "We have always been committed to protecting ",
                  style: GoogleFonts.inika(
                    color: Colors.white,
                    fontSize:
                        width * 0.030, // Menyesuaikan ukuran font (lebih kecil)
                  ),
                  textAlign:
                      TextAlign.center, // Mengatur teks agar justify center
                ),
                SizedBox(
                    height:
                        height * 0.01), // Menggunakan ukuran layar untuk jarak
                Text(
                  "your privacy and your data",
                  style: GoogleFonts.inika(
                    color: Colors.white,
                    fontSize:
                        width * 0.030, // Menyesuaikan ukuran font (lebih kecil)
                  ),
                  textAlign:
                      TextAlign.center, // Mengatur teks agar justify center
                ),
                SizedBox(
                    height:
                        height * 0.04), // Menggunakan ukuran layar untuk jarak
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          width * 0.1), // Memberikan padding di sekitar tombol
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
