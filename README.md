# Encryption File Galeri App Android 11-13

Aplikasi Flutter untuk mengenkripsi dan mendekripsi file (terutama gambar) menggunakan algoritma AES. Aplikasi ini mendukung pengambilan kunci enkripsi dari server, pengelolaan Device ID, dan penyimpanan cache menggunakan SharedPreferences.

---

## 🔗 Demo Aplikasi
Anda dapat melihat demo penggunaan aplikasi ini di TikTok:

Atau kunjungi langsung melalui tautan berikut:
https://www.tiktok.com/@kunttycat/video/7428903489788595476

## 🚀 Fitur Utama
1. **Enkripsi File Gambar**
   - Mendukung format gambar: `.jpg`, `.jpeg`, `.png`, dan `.gif`.
   - File dienkripsi menggunakan algoritma AES dengan mode **CBC (Cipher Block Chaining)**.
   - Menggunakan **IV (Initialization Vector)** acak untuk keamanan tambahan.

2. **Dekripsi File**
   - File yang telah terenkripsi dapat didekripsi menggunakan kunci yang sama.

3. **Manajemen Kunci Enkripsi**
   - Kunci enkripsi diambil dari server melalui endpoint API.
   - Kunci disimpan dalam **cache lokal** menggunakan `SharedPreferences` untuk meningkatkan performa.

4. **Device ID Unik**
   - Aplikasi menghasilkan Device ID unik untuk setiap perangkat menggunakan plugin `device_info_plus`.

5. **Permintaan Izin Akses Penyimpanan**
   - Menggunakan `permission_handler` untuk memastikan aplikasi memiliki akses ke file dalam perangkat.

6. **UI untuk Menampilkan File Terenkripsi**
   - Halaman khusus untuk menampilkan daftar file yang telah dienkripsi.

---

## 🛠️ Teknologi yang Digunakan
- **Flutter**: Framework utama untuk membangun aplikasi.
- **encrypt**: Untuk proses enkripsi dan dekripsi menggunakan AES.
- **permission_handler**: Untuk mengelola izin perangkat.
- **device_info_plus**: Untuk mendapatkan informasi perangkat, seperti Device ID.
- **shared_preferences**: Untuk menyimpan data kecil secara lokal.
- **http**: Untuk mengakses API server (mengambil kunci enkripsi).
- **image**: Untuk memproses file gambar.
- **google_fonts** dan **font_awesome_flutter**: Untuk mempercantik UI.

---

## 🖥️ Cara Menggunakan

### 1. Persiapan
- Pastikan Anda sudah menginstal [Flutter SDK](https://docs.flutter.dev/get-started/install).
- Tambahkan **API Endpoint** untuk mendapatkan kunci enkripsi di file `_getEncryptionKey()`.

### 2. Clone Repository
```bash
git clone
cd file-encryption-app
```

### 3. Endpoint API yang Dibutuhkan
```bash
URL: https://example.com/get-encryption-key/{deviceId}
Metode: GET
Parameter: deviceId: Device ID unik yang dihasilkan aplikasi.
```
```bash
Response Contoh:
{
  "key": "64_character_hexadecimal_key"
}
```
Pastikan server menggunakan protokol HTTPS untuk keamanan data.


### 💡 Kontribusi
Kontribusi sangat dihargai! Jika Anda memiliki ide untuk meningkatkan aplikasi atau menemukan bug, silakan:
1. **Pull Request**
   - Buat Pull Request untuk menambahkan fitur atau memperbaiki masalah.

2. **Report Issues**
   - Laporkan masalah di tab Issues.

### 📧 Kontak
Jika ada pertanyaan atau saran, silakan hubungi saya melalui:
- **Discord**: @kunttycat

### 📝 Lisensi
Proyek ini dilisensikan di bawah lisensi MIT. Anda bebas menggunakan, memodifikasi, dan mendistribusikan ulang kode ini dengan syarat menyertakan informasi lisensi.
---
