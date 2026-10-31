# Outfit AI Frontend

Aplikasi Flutter untuk membantu pengguna menemukan rekomendasi outfit berdasarkan kebutuhan, budget, dan prompt yang diinputkan. Aplikasi ini memiliki dua mode utama: rekomendasi otomatis dari AI dan pemilihan outfit manual dari katalog produk.

## Fitur

- Rekomendasi outfit otomatis berbasis AI
- Input prompt kebutuhan outfit seperti acara, gaya, atau suasana
- Pengaturan budget dengan slider
- Katalog produk manual untuk memilih item berdasarkan kategori
- Preview outfit hasil rekomendasi beserta penjelasan singkat
- Integrasi dengan backend rekomendasi melalui API
- Dukungan gambar hasil rekomendasi dan item produk

## Stack Teknologi

- Flutter
- Dart
- HTTP client untuk komunikasi API
- image_picker

## Arsitektur Aplikasi

Aplikasi ini terdiri dari:

- `lib/main.dart` - entry point aplikasi
- `lib/screens/` - halaman utama seperti Home, Catalog, Result, dan Preview
- `lib/services/` - service untuk komunikasi dengan backend rekomendasi
- `lib/state/` - controller state aplikasi
- `lib/models/` - model data product dan rekomendasi
- `lib/widgets/` - komponen UI reusable

## Prasyarat

Pastikan perangkat sudah terinstall:

- Flutter SDK 3.13+
- Android Studio / VS Code dengan Flutter extension
- Emulator Android atau perangkat fisik
- Backend recommendation service yang berjalan di port 8000

## Setup dan Menjalankan Aplikasi

1. Clone repository:

   ```bash
   git clone https://github.com/MuhamadAndris/outfit-ai.git
   cd outfit_ai
   ```

2. Install dependency:

   ```bash
   flutter pub get
   ```

3. Jalankan aplikasi:

   ```bash
   flutter run
   ```

4. Jika backend berjalan di URL lain, gunakan konfigurasi custom:

   ```bash
   flutter run --dart-define=API_BASE_URL=http://localhost:8000
   ```

   Untuk Android emulator:

   ```bash
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
   ```

   Untuk HP nyata / perangkat Android di jaringan yang sama, cek IP komputer terlebih dahulu lewat terminal/cmd:

   ```bash
   ipconfig
   ```

   Cari IPv4 Address, lalu jalankan:

   ```bash
   flutter run --dart-define=API_BASE_URL=http://10.252.107.104:8000
   ```

   Contoh di atas artinya backend sedang berjalan di komputer dengan IP `10.252.107.104` pada port `8000`. Pastikan HP dan laptop tersambung ke jaringan Wi-Fi yang sama.

## Endpoint Backend yang Digunakan

Aplikasi ini mengirim request ke endpoint berikut:

```text
POST /api/v1/recommendations
```

Request biasanya berisi:

- `prompt`
- `budget`
- `previous_combinations`
- `refresh`
- `mode`

## Struktur Folder

```text
outfit_ai_fe/
├── android/
├── ios/
├── lib/
│   ├── core/
│   ├── models/
│   ├── screens/
│   ├── services/
│   ├── state/
│   └── widgets/
├── test/
├── analysis_options.yaml
├── pubspec.yaml
├── README.md
└── .gitignore
```

## Menjalankan Test

```bash
flutter test
```

## Catatan

- Mode AI memanggil backend rekomendasi untuk menghasilkan kombinasi outfit.
- Mode manual memungkinkan pengguna memilih produk satu per kategori.
- Jika rekomendasi tidak ditemukan, aplikasi menampilkan snackbar bahwa budget saat ini belum cocok.

## Kontribusi

Pull request sangat terbuka untuk perbaikan UI, optimasi fitur, dan peningkatan kualitas rekomendasi.

## Lisensi

Project ini dibuat untuk kebutuhan tugas kuliah dan belum ditetapkan lisensi publik.
