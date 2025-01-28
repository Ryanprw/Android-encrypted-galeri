import 'package:permission_handler/permission_handler.dart';

Future<void> requestManageExternalStoragePermission() async {
  if (await Permission.manageExternalStorage.request().isGranted) {
    print("Izin MANAGE_EXTERNAL_STORAGE diberikan");
  } else {
    if (await Permission.manageExternalStorage.isPermanentlyDenied) {
      openAppSettings();
    } else {
      await Permission.manageExternalStorage.request();
    }
  }
}
