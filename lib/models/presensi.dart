class Presensi {
  final int? id;
  final DateTime tanggal;
  final String? jamMasuk;
  final String? jamPulang;
  final String status; // 'Hadir', 'Izin', 'Sakit'
  final String? keterangan;

  Presensi({
    this.id,
    required this.tanggal,
    this.jamMasuk,
    this.jamPulang,
    required this.status,
    this.keterangan,
  });

  String get tanggalKey =>
      '${tanggal.year.toString().padLeft(4, '0')}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        'id': id,
        'tanggal': tanggalKey,
        'jamMasuk': jamMasuk,
        'jamPulang': jamPulang,
        'status': status,
        'keterangan': keterangan,
      };

  factory Presensi.fromMap(Map<String, dynamic> map) => Presensi(
        id: map['id'] as int?,
        tanggal: DateTime.parse(map['tanggal'] as String),
        jamMasuk: map['jamMasuk'] as String?,
        jamPulang: map['jamPulang'] as String?,
        status: map['status'] as String,
        keterangan: map['keterangan'] as String?,
      );
}