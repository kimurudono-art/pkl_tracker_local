import 'package:flutter/material.dart';
import '../database/pkl_repository.dart';
import '../models/presensi.dart';
import '../widgets/kartu_ringkasan.dart';

class PresensiScreen extends StatefulWidget {
  const PresensiScreen({super.key});

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  final _repo = PklRepository();
  Presensi? _hariIni;
  List<Presensi> _daftar = [];
  String _filterStatus = 'Semua';
  String _filterBulan = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  List<String> _opsiBulan() {
    final tahun = DateTime.now().year;
    return List.generate(
      12,
      (i) => '$tahun-${(i + 1).toString().padLeft(2, '0')}',
    );
  }

  Future<void> _muat() async {
    setState(() => _loading = true);
    final hariIni = await _repo.ambilPresensiHariIni(_todayKey());
    final list = await _repo.ambilPresensi(
      bulan: _filterBulan.isEmpty ? null : _filterBulan,
      status: _filterStatus,
    );
    if (!mounted) return;
    setState(() {
      _hariIni = hariIni;
      _daftar = list;
      _loading = false;
    });
  }

  Future<void> _checkIn() async {
    if (_hariIni != null) return;
    final now = DateTime.now();
    final data = Presensi(
      tanggal: DateTime(now.year, now.month, now.day),
      jamMasuk: formatJamSekarang(now),
      jamPulang: null,
      status: 'Hadir',
      keterangan: null,
    );
    await _repo.tambahPresensi(data);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Check-in berhasil pada ${data.jamMasuk}')),
    );
    await _muat();
  }

  Future<void> _checkOut() async {
    if (_hariIni == null ||
        _hariIni!.status != 'Hadir' ||
        _hariIni!.jamPulang != null) {
      return;
    }
    final now = DateTime.now();
    final updated = Presensi(
      id: _hariIni!.id,
      tanggal: _hariIni!.tanggal,
      jamMasuk: _hariIni!.jamMasuk,
      jamPulang: formatJamSekarang(now),
      status: _hariIni!.status,
      keterangan: _hariIni!.keterangan,
    );
    await _repo.updatePresensi(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Check-out berhasil pada ${updated.jamPulang}')),
    );
    await _muat();
  }

  Future<void> _bukaDialogIzinSakit() async {
    if (_hariIni != null) return;
    final formKey = GlobalKey<FormState>();
    String jenis = 'Izin';
    final ketController = TextEditingController();

    final simpan = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Catat Izin / Sakit'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: jenis,
                  decoration: const InputDecoration(
                    labelText: 'Status Kehadiran',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Izin', child: Text('Izin')),
                    DropdownMenuItem(value: 'Sakit', child: Text('Sakit')),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => jenis = v);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ketController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Keterangan (Wajib)',
                    hintText: 'Contoh: Sakit demam / Urusan keluarga',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Keterangan wajib diisi untuk Izin/Sakit'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (simpan != true) return;
    final now = DateTime.now();
    await _repo.tambahPresensi(
      Presensi(
        tanggal: DateTime(now.year, now.month, now.day),
        jamMasuk: null,
        jamPulang: null,
        status: jenis,
        keterangan: ketController.text.trim(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Presensi $jenis berhasil disimpan')),
    );
    await _muat();
  }

  Future<void> _konfirmasiHapus(Presensi p) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Presensi?'),
        content: Text(
          'Data presensi tanggal ${formatTanggalIndo(p.tanggal)} akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ya != true) return;
    await _repo.hapusPresensi(p.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data presensi dihapus')),
    );
    await _muat();
  }

  @override
  Widget build(BuildContext context) {
    final sudahPresensi = _hariIni != null;
    final bisaCheckOut = _hariIni != null &&
        _hariIni!.status == 'Hadir' &&
        _hariIni!.jamPulang == null;

    return Scaffold(
      appBar: AppBar(title: const Text('Presensi Harian')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hari Ini: ${formatTanggalIndo(DateTime.now())}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      !sudahPresensi
                          ? 'Silakan lakukan Check-in saat tiba di tempat PKL.'
                          : _hariIni!.status == 'Hadir'
                              ? 'Masuk: ${_hariIni!.jamMasuk}  •  Pulang: ${_hariIni!.jamPulang ?? "Belum Check-out"}'
                              : 'Status hari ini: ${_hariIni!.status} (${_hariIni!.keterangan})',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: sudahPresensi ? null : _checkIn,
                            icon: const Icon(Icons.login),
                            label: const Text('Check-In'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: bisaCheckOut ? _checkOut : null,
                            icon: const Icon(Icons.logout),
                            label: const Text('Check-Out'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed:
                            sudahPresensi ? null : _bukaDialogIzinSakit,
                        icon: const Icon(Icons.event_busy),
                        label: const Text('Catat Izin / Sakit'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filterBulan,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Bulan',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Semua Bulan'),
                      ),
                      ..._opsiBulan().map(
                        (b) => DropdownMenuItem(
                          value: b,
                          child: Text(namaBulanDariKey(b)),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      _filterBulan = v ?? '';
                      _muat();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filterStatus,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                      DropdownMenuItem(value: 'Hadir', child: Text('Hadir')),
                      DropdownMenuItem(value: 'Izin', child: Text('Izin')),
                      DropdownMenuItem(value: 'Sakit', child: Text('Sakit')),
                    ],
                    onChanged: (v) {
                      _filterStatus = v ?? 'Semua';
                      _muat();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _daftar.isEmpty
                    ? const Center(
                        child: Text('Belum ada riwayat presensi'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _daftar.length,
                        itemBuilder: (context, i) {
                          final p = _daftar[i];
                          final warnaStatus = p.status == 'Hadir'
                              ? Colors.teal
                              : (p.status == 'Izin'
                                  ? Colors.orange
                                  : Colors.red);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    warnaStatus.withValues(alpha: 0.15),
                                foregroundColor: warnaStatus,
                                child: Text(p.status[0]),
                              ),
                              title: Text(
                                '${formatTanggalIndo(p.tanggal)} • ${p.status}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                p.status == 'Hadir'
                                    ? 'Masuk: ${p.jamMasuk ?? "-"} | Pulang: ${p.jamPulang ?? "-"}'
                                    : 'Keterangan: ${p.keterangan ?? "-"}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _konfirmasiHapus(p),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}