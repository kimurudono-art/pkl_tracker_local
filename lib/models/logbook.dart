class Logbook {
  final int? id;
  final DateTime tanggal;
  final String jamMulai;
  final String jamSelesai;
  final String kegiatan;
  final String kompetensi;
  final String? kendala;
  final String? solusi;

  Logbook({
    this.id,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.kegiatan,
    required this.kompetensi,
    this.kendala,
    this.solusi,
  });

  String get tanggalKey =>
      '${tanggal.year.toString().padLeft(4, '0')}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        'id': id,
        'tanggal': tanggalKey,
        'jamMulai': jamMulai,
        'jamSelesai': jamSelesai,
        'kegiatan': kegiatan,
        'kompetensi': kompetensi,
        'kendala': kendala,
        'solusi': solusi,
      };

  factory Logbook.fromMap(Map<String, dynamic> map) => Logbook(
        id: map['id'] as int?,
        tanggal: DateTime.parse(map['tanggal'] as String),
        jamMulai: map['jamMulai'] as String,
        jamSelesai: map['jamSelesai'] as String,
        kegiatan: map['kegiatan'] as String,
        kompetensi: map['kompetensi'] as String,
        kendala: map['kendala'] as String?,
        solusi: map['solusi'] as String?,
      );
}