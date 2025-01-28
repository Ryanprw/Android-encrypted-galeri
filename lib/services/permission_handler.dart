import 'package:permission_handler/permission_handler.dart';

Future<void> requestManageExternalStoragePermission() async {
  if (await Permission.manageExternalStorage.request().isGranted) {
    print("Izin MANAGE_EXTERNAL_STORAGE diberikan");
  } else {
    if (await Permission.manageExternalStorage.isPermanentlyDenied) {
      openAppSettings(); // Arahkan pengguna ke pengaturan jika izin ditolak permanen
    } else {
      await Permission.manageExternalStorage
          .request(); // Permintaan izin normal
    }
  }
}
