import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/prefs_helper.dart';
import '../models/profil_pkl.dart';
import '../widgets/kartu_ringkasan.dart';

class PengaturanScreen extends StatefulWidget {
  final bool temaGelap;
  final ValueChanged<bool> onUbahTema;
  final VoidCallback onDataBerubah;

  const PengaturanScreen({
    super.key,
    required this.temaGelap,
    required this.onUbahTema,
    required this.onDataBerubah,
  });

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nama = TextEditingController();
  final _nis = TextEditingController();
  final _kelas = TextEditingController();
  final _tempat = TextEditingController();
  final _pembimbingInd = TextEditingController();
  final _pembimbingSek = TextEditingController();

  DateTime _mulai = DateTime.now();
  DateTime _selesai = DateTime.now().add(const Duration(days: 90));
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _muatProfil();
  }

  Future<void> _muatProfil() async {
    final p = await PrefsHelper.instance.getProfil();
    if (!mounted) return;
    if (p != null) {
      _nama.text = p.nama;
      _nis.text = p.nis;
      _kelas.text = p.kelas;
      _tempat.text = p.tempatPkl;
      _pembimbingInd.text = p.pembimbingIndustri;
      _pembimbingSek.text = p.pembimbingSekolah;
      _mulai = p.tanggalMulai;
      _selesai = p.tanggalSelesai;
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nama.dispose();
    _nis.dispose();
    _kelas.dispose();
    _tempat.dispose();
    _pembimbingInd.dispose();
    _pembimbingSek.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(bool isMulai) async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: isMulai ? _mulai : _selesai,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (hasil != null) {
      setState(() {
        if (isMulai) {
          _mulai = hasil;
        } else {
          _selesai = hasil;
        }
      });
    }
  }

  Future<void> _simpanProfil() async {
    if (!_formKey.currentState!.validate()) return;

    final tglMulai = DateTime(_mulai.year, _mulai.month, _mulai.day);
    final tglSelesai = DateTime(_selesai.year, _selesai.month, _selesai.day);

    if (tglSelesai.isBefore(tglMulai)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal selesai tidak boleh sebelum tanggal mulai'),
        ),
      );
      return;
    }

    final profil = ProfilPkl(
      nama: _nama.text.trim(),
      nis: _nis.text.trim(),
      kelas: _kelas.text.trim(),
      tempatPkl: _tempat.text.trim(),
      pembimbingIndustri: _pembimbingInd.text.trim(),
      pembimbingSekolah: _pembimbingSek.text.trim(),
      tanggalMulai: tglMulai,
      tanggalSelesai: tglSelesai,
    );

    await PrefsHelper.instance.simpanProfil(profil);
    widget.onDataBerubah();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil PKL berhasil disimpan')),
    );
  }

  Future<void> _konfirmasiHapusSemua() async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Seluruh Data?'),
        content: const Text(
          'Semua data profil, presensi, dan logbook akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (ya != true) return;
    await DatabaseHelper.instance.hapusSemuaTabel();
    await PrefsHelper.instance.hapusProfil();

    _nama.clear();
    _nis.clear();
    _kelas.clear();
    _tempat.clear();
    _pembimbingInd.clear();
    _pembimbingSek.clear();
    widget.onDataBerubah();

    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seluruh data berhasil dihapus')),
    );
  }

  String? _wajib(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Pengaturan')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: SwitchListTile(
                    title: const Text('Tema Gelap (Dark Mode)'),
                    subtitle: const Text('Simpan preferensi tampilan aplikasi'),
                    secondary: const Icon(Icons.dark_mode_outlined),
                    value: widget.temaGelap,
                    onChanged: widget.onUbahTema,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Data Profil PKL',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nama,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap Siswa',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => _wajib(v, 'Nama'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nis,
                              decoration: const InputDecoration(
                                labelText: 'NIS',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => _wajib(v, 'NIS'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _kelas,
                              decoration: const InputDecoration(
                                labelText: 'Kelas',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => _wajib(v, 'Kelas'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _tempat,
                        decoration: const InputDecoration(
                          labelText: 'Tempat PKL (DU/DI)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => _wajib(v, 'Tempat PKL'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _pembimbingInd,
                        decoration: const InputDecoration(
                          labelText: 'Pembimbing Industri',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => _wajib(v, 'Pembimbing industri'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _pembimbingSek,
                        decoration: const InputDecoration(
                          labelText: 'Pembimbing Sekolah',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => _wajib(v, 'Pembimbing sekolah'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pilihTanggal(true),
                              icon: const Icon(Icons.event_available),
                              label: Text('Mulai:\n${formatTanggalIndo(_mulai)}'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pilihTanggal(false),
                              icon: const Icon(Icons.event_busy),
                              label:
                                  Text('Selesai:\n${formatTanggalIndo(_selesai)}'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _simpanProfil,
                          icon: const Icon(Icons.save),
                          label: const Text('Simpan Profil PKL'),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 36),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onPressed: _konfirmasiHapusSemua,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Hapus Seluruh Data Aplikasi'),
                ),
              ],
            ),
    );
  }
}