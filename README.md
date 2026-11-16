# PKL Tracker Local (JO-03)

Aplikasi mobile offline berbasis Flutter untuk mencatat presensi harian dan logbook kegiatan Praktik Kerja Lapangan (PKL) siswa SMK. Seluruh data tersimpan secara lokal pada perangkat menggunakan SQLite dan Shared Preferences.

## Fitur Utama
- **Profil PKL & Pengaturan Tema (F-01 & F-06):** Menyimpan identitas siswa, tempat DU/DI, pembimbing industri & sekolah, periode PKL, serta preferensi tema terang/gelap menggunakan Shared Preferences.
- **Presensi Harian (F-02):** Check-in dan Check-out otomatis berdasarkan waktu perangkat, pencatatan Izin/Sakit dengan keterangan wajib, serta validasi satu presensi per tanggal.
- **Logbook Harian (F-03):** Operasi CRUD (Tambah, Lihat, Ubah, Hapus dengan konfirmasi) catatan kegiatan PKL dengan validasi jam selesai dan uraian minimal 20 karakter.
- **Pencarian & Filter (F-04):** Memfilter riwayat presensi (bulan & status) serta mencari catatan logbook berdasarkan kata kunci dan bulan.
- **Rekapitulasi Otomatis (F-05):** Menampilkan jumlah hari Hadir/Izin/Sakit, total jam kerja, jumlah logbook, persentase kehadiran, serta fitur salin rekap ke clipboard.

## Cara Menjalankan
1. Pastikan Flutter SDK telah terpasang di komputer (`flutter --version`).
2. Masuk ke direktori proyek:
   ```bash
   cd pkl_tracker_local