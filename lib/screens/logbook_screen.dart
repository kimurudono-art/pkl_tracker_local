import 'package:flutter/material.dart';
import '../database/pkl_repository.dart';
import '../models/logbook.dart';
import '../widgets/kartu_ringkasan.dart';
import 'logbook_form_screen.dart';

class LogbookScreen extends StatefulWidget {
  const LogbookScreen({super.key});

  @override
  State<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  final _repo = PklRepository();
  List<Logbook> _daftar = [];
  String _kata = '';
  String _filterBulan = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _muat();
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
    final hasil = await _repo.ambilLogbook(
      kata: _kata,
      bulan: _filterBulan.isEmpty ? null : _filterBulan,
    );
    if (!mounted) return;
    setState(() {
      _daftar = hasil;
      _loading = false;
    });
  }

  Future<void> _bukaForm([Logbook? item]) async {
    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => LogbookFormScreen(logbook: item)),
    );
    if (berhasil == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            item == null
                ? 'Logbook berhasil ditambahkan'
                : 'Logbook berhasil diperbarui',
          ),
        ),
      );
      await _muat();
    }
  }

  Future<void> _konfirmasiHapus(Logbook item) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Logbook?'),
        content: Text(
          'Logbook tanggal ${formatTanggalIndo(item.tanggal)} akan dihapus permanen.',
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
    await _repo.hapusLogbook(item.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logbook berhasil dihapus')),
    );
    await _muat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logbook Harian')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari kegiatan atau kompetensi...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) {
                _kata = v.trim();
                _muat();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: DropdownButtonFormField<String>(
              initialValue: _filterBulan,
              decoration: const InputDecoration(
                labelText: 'Filter Bulan',
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
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _daftar.isEmpty
                    ? const Center(
                        child: Text('Data logbook tidak ditemukan'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                        itemCount: _daftar.length,
                        itemBuilder: (context, i) {
                          final item = _daftar[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _bukaForm(item),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${formatTanggalIndo(item.tanggal)}  •  ${item.jamMulai}–${item.jamSelesai}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          icon:
                                              const Icon(Icons.delete_outline),
                                          onPressed: () =>
                                              _konfirmasiHapus(item),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      item.kegiatan,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 6),
                                    Chip(
                                      label: Text(item.kompetensi),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    if (item.kendala != null &&
                                        item.kendala!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Kendala: ${item.kendala}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                    if (item.solusi != null &&
                                        item.solusi!.isNotEmpty)
                                      Text(
                                        'Solusi: ${item.solusi}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(),
        icon: const Icon(Icons.add),
        label: const Text('Logbook'),
      ),
    );
  }
}