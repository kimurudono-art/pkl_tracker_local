import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/pkl_repository.dart';
import '../database/prefs_helper.dart';
import '../models/presensi.dart';
import '../models/profil_pkl.dart';
import '../widgets/kartu_ringkasan.dart';

class BerandaScreen extends StatefulWidget {
  final void Function(int tabIndex) onPindahTab;

  const BerandaScreen({super.key, required this.onPindahTab});

  @override
  State<BerandaScreen> createState() => BerandaScreenState();
}

class BerandaScreenState extends State<BerandaScreen> {
  final _repo = PklRepository();
  ProfilPkl? _profil;
  Presensi? _presensiHariIni;
  Map<String, dynamic> _rekap = {
    'hadir': 0,
    'izin': 0,
    'sakit': 0,
    'totalHari': 0,
    'persentase': 0.0,
    'totalJamKerja': 0.0,
    'jumlahLogbook': 0,
  };
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    muatData();
  }

  Future<void> muatData() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    final todayKey =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final profil = await PrefsHelper.instance.getProfil();
    final presensiToday = await _repo.ambilPresensiHariIni(todayKey);
    final rekap = await _repo.hitungRekap();

    if (!mounted) return;
    setState(() {
      _profil = profil;
      _presensiHariIni = presensiToday;
      _rekap = rekap;
      _loading = false;
    });
  }

  Future<void> _salinRekapClipboard() async {
    final nama = _profil?.nama ?? 'Siswa PKL';
    final tempat = _profil?.tempatPkl ?? '-';
    final teks = '''
REKAP PKL - $nama
Tempat PKL: $tempat
- Hadir: ${_rekap['hadir']} hari
- Izin: ${_rekap['izin']} hari
- Sakit: ${_rekap['sakit']} hari
- Persentase Kehadiran: ${(_rekap['persentase'] as double).toStringAsFixed(1)}%
- Total Jam Kerja: ${(_rekap['totalJamKerja'] as double).toStringAsFixed(1)} jam
- Total Logbook: ${_rekap['jumlahLogbook']} catatan
''';
    await Clipboard.setData(ClipboardData(text: teks.trim()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rekap berhasil disalin ke clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PKL Tracker Local'),
        actions: [
          IconButton(
            tooltip: 'Salin Rekap',
            icon: const Icon(Icons.copy_all_outlined),
            onPressed: _salinRekapClipboard,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: muatData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildKartuProfil(cs),
                  const SizedBox(height: 16),
                  _buildStatusHariIni(cs),
                  const SizedBox(height: 20),
                  Text(
                    'Rekapitulasi PKL',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: KartuRingkasan(
                          judul: 'Kehadiran',
                          nilai:
                              '${(_rekap['persentase'] as double).toStringAsFixed(1)}%',
                          subjudul:
                              '${_rekap['hadir']} dari ${_rekap['totalHari']} hari',
                          ikon: Icons.verified_user_outlined,
                          warna: Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KartuRingkasan(
                          judul: 'Total Jam Kerja',
                          nilai:
                              '${(_rekap['totalJamKerja'] as double).toStringAsFixed(1)} j',
                          subjudul: 'Akumulasi durasi',
                          ikon: Icons.access_time,
                          warna: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: KartuRingkasan(
                          judul: 'Total Logbook',
                          nilai: '${_rekap['jumlahLogbook']}',
                          subjudul: 'Kegiatan tercatat',
                          ikon: Icons.menu_book_outlined,
                          warna: Colors.orange.shade800,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KartuRingkasan(
                          judul: 'Hadir / Izin / Sakit',
                          nilai:
                              '${_rekap['hadir']} / ${_rekap['izin']} / ${_rekap['sakit']}',
                          subjudul: 'Rincian status',
                          ikon: Icons.pie_chart_outline,
                          warna: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildKartuProfil(ColorScheme cs) {
    if (_profil == null) {
      return Card(
        color: cs.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profil PKL Belum Diisi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Lengkapi data diri, tempat DU/DI, pembimbing, dan periode PKL terlebih dahulu.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => widget.onPindahTab(3),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Isi Profil PKL'),
              ),
            ],
          ),
        ),
      );
    }

    final p = _profil!;
    return Card(
      elevation: 0,
      color: cs.primaryContainer.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  child: Text(p.nama.isNotEmpty ? p.nama[0].toUpperCase() : 'S'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nama,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text('NIS ${p.nis} • ${p.kelas}'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _barisInfo(Icons.business, 'Tempat PKL', p.tempatPkl),
            const SizedBox(height: 6),
            _barisInfo(
              Icons.engineering_outlined,
              'Pembimbing DU/DI',
              p.pembimbingIndustri,
            ),
            const SizedBox(height: 6),
            _barisInfo(
              Icons.school_outlined,
              'Pembimbing Sekolah',
              p.pembimbingSekolah,
            ),
            const SizedBox(height: 6),
            _barisInfo(
              Icons.date_range,
              'Periode',
              '${formatTanggalIndo(p.tanggalMulai)} – ${formatTanggalIndo(p.tanggalSelesai)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _barisInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(value, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildStatusHariIni(ColorScheme cs) {
    String statusTeks;
    if (_presensiHariIni == null) {
      statusTeks = 'Belum melakukan presensi hari ini.';
    } else if (_presensiHariIni!.status == 'Hadir') {
      final masuk = _presensiHariIni!.jamMasuk ?? '-';
      final pulang = _presensiHariIni!.jamPulang ?? 'Belum Check-out';
      statusTeks = 'Hadir • Masuk: $masuk | Pulang: $pulang';
    } else {
      statusTeks =
          'Status: ${_presensiHariIni!.status} (${_presensiHariIni!.keterangan ?? '-'})';
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(Icons.fingerprint, color: cs.primary, size: 32),
        title: Text('Presensi Hari Ini (${formatTanggalIndo(DateTime.now())})'),
        subtitle: Text(statusTeks),
        trailing: TextButton(
          onPressed: () => widget.onPindahTab(1),
          child: const Text('Buka'),
        ),
      ),
    );
  }
}