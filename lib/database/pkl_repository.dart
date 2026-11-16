import 'database_helper.dart';
import '../models/logbook.dart';
import '../models/presensi.dart';

class PklRepository {
  final _helper = DatabaseHelper.instance;

  // --- OPERASI PRESENSI ---
  Future<List<Presensi>> ambilPresensi({String? bulan, String? status}) async {
    final db = await _helper.database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (bulan != null && bulan.isNotEmpty) {
      whereClauses.add('tanggal LIKE ?');
      whereArgs.add('$bulan%');
    }
    if (status != null && status.isNotEmpty && status != 'Semua') {
      whereClauses.add('status = ?');
      whereArgs.add(status);
    }

    final rows = await db.query(
      'presensi',
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'tanggal DESC, id DESC',
    );
    return rows.map(Presensi.fromMap).toList();
  }

  Future<Presensi?> ambilPresensiHariIni(String tanggalKey) async {
    final db = await _helper.database;
    final rows = await db.query(
      'presensi',
      where: 'tanggal = ?',
      whereArgs: [tanggalKey],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Presensi.fromMap(rows.first);
  }

  Future<int> tambahPresensi(Presensi p) async {
    final db = await _helper.database;
    return db.insert('presensi', p.toMap());
  }

  Future<int> updatePresensi(Presensi p) async {
    final db = await _helper.database;
    return db.update(
      'presensi',
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }

  Future<int> hapusPresensi(int id) async {
    final db = await _helper.database;
    return db.delete('presensi', where: 'id = ?', whereArgs: [id]);
  }

  // --- OPERASI LOGBOOK ---
  Future<List<Logbook>> ambilLogbook({String? kata, String? bulan}) async {
    final db = await _helper.database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (kata != null && kata.isNotEmpty) {
      whereClauses.add('(kegiatan LIKE ? OR kompetensi LIKE ?)');
      whereArgs.addAll(['%$kata%', '%$kata%']);
    }
    if (bulan != null && bulan.isNotEmpty) {
      whereClauses.add('tanggal LIKE ?');
      whereArgs.add('$bulan%');
    }

    final rows = await db.query(
      'logbook',
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'tanggal DESC, id DESC',
    );
    return rows.map(Logbook.fromMap).toList();
  }

  Future<void> simpanLogbook(Logbook item) async {
    final db = await _helper.database;
    if (item.id == null) {
      await db.insert('logbook', item.toMap());
    } else {
      await db.update(
        'logbook',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    }
  }

  Future<int> hapusLogbook(int id) async {
    final db = await _helper.database;
    return db.delete('logbook', where: 'id = ?', whereArgs: [id]);
  }

  // --- PERHITUNGAN REKAP (F-05) ---
  Future<Map<String, dynamic>> hitungRekap() async {
    final semuaPresensi = await ambilPresensi();
    final semuaLogbook = await ambilLogbook();

    int hadir = 0;
    int izin = 0;
    int sakit = 0;
    int totalMenitKerja = 0;

    for (final p in semuaPresensi) {
      if (p.status == 'Hadir') {
        hadir++;
        if (p.jamMasuk != null && p.jamPulang != null) {
          totalMenitKerja += _selisihMenit(p.jamMasuk!, p.jamPulang!);
        }
      } else if (p.status == 'Izin') {
        izin++;
      } else if (p.status == 'Sakit') {
        sakit++;
      }
    }

    // Jika jam kerja dari presensi 0, hitung dari durasi logbook sebagai cadangan
    if (totalMenitKerja == 0) {
      for (final l in semuaLogbook) {
        totalMenitKerja += _selisihMenit(l.jamMulai, l.jamSelesai);
      }
    }

    final totalHari = semuaPresensi.length;
    final persentase = totalHari == 0 ? 0.0 : (hadir / totalHari) * 100;
    final totalJamKerja = totalMenitKerja / 60.0;

    return {
      'hadir': hadir,
      'izin': izin,
      'sakit': sakit,
      'totalHari': totalHari,
      'persentase': persentase,
      'totalJamKerja': totalJamKerja,
      'jumlahLogbook': semuaLogbook.length,
    };
  }

  int _selisihMenit(String mulai, String selesai) {
    final p1 = mulai.split(':');
    final p2 = selesai.split(':');
    if (p1.length < 2 || p2.length < 2) return 0;
    final m1 = (int.tryParse(p1[0]) ?? 0) * 60 + (int.tryParse(p1[1]) ?? 0);
    final m2 = (int.tryParse(p2[0]) ?? 0) * 60 + (int.tryParse(p2[1]) ?? 0);
    return m2 > m1 ? (m2 - m1) : 0;
  }
}