import 'package:flutter/material.dart';
import '../database/pkl_repository.dart';
import '../models/logbook.dart';
import '../widgets/kartu_ringkasan.dart';

class LogbookFormScreen extends StatefulWidget {
  final Logbook? logbook;

  const LogbookFormScreen({super.key, this.logbook});

  @override
  State<LogbookFormScreen> createState() => _LogbookFormScreenState();
}

class _LogbookFormScreenState extends State<LogbookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = PklRepository();

  late DateTime _tanggal;
  late TimeOfDay _jamMulai;
  late TimeOfDay _jamSelesai;

  late final TextEditingController _kegiatan;
  late final TextEditingController _kompetensi;
  late final TextEditingController _kendala;
  late final TextEditingController _solusi;

  @override
  void initState() {
    super.initState();
    final item = widget.logbook;
    _tanggal = item?.tanggal ?? DateTime.now();
    _jamMulai = item != null
        ? _parseTime(item.jamMulai)
        : const TimeOfDay(hour: 8, minute: 0);
    _jamSelesai = item != null
        ? _parseTime(item.jamSelesai)
        : const TimeOfDay(hour: 16, minute: 0);

    _kegiatan = TextEditingController(text: item?.kegiatan ?? '');
    _kompetensi = TextEditingController(text: item?.kompetensi ?? '');
    _kendala = TextEditingController(text: item?.kendala ?? '');
    _solusi = TextEditingController(text: item?.solusi ?? '');
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return const TimeOfDay(hour: 8, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _kegiatan.dispose();
    _kompetensi.dispose();
    _kendala.dispose();
    _solusi.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (hasil != null) setState(() => _tanggal = hasil);
  }

  Future<void> _pilihJam(bool mulai) async {
    final hasil = await showTimePicker(
      context: context,
      initialTime: mulai ? _jamMulai : _jamSelesai,
    );
    if (hasil != null) {
      setState(() {
        if (mulai) {
          _jamMulai = hasil;
        } else {
          _jamSelesai = hasil;
        }
      });
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final menitMulai = _jamMulai.hour * 60 + _jamMulai.minute;
    final menitSelesai = _jamSelesai.hour * 60 + _jamSelesai.minute;
    if (menitSelesai <= menitMulai) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jam selesai harus setelah jam mulai'),
        ),
      );
      return;
    }

    final data = Logbook(
      id: widget.logbook?.id,
      tanggal: DateTime(_tanggal.year, _tanggal.month, _tanggal.day),
      jamMulai: _formatTime(_jamMulai),
      jamSelesai: _formatTime(_jamSelesai),
      kegiatan: _kegiatan.text.trim(),
      kompetensi: _kompetensi.text.trim(),
      kendala: _kendala.text.trim().isEmpty ? null : _kendala.text.trim(),
      solusi: _solusi.text.trim().isEmpty ? null : _solusi.text.trim(),
    );

    await _repo.simpanLogbook(data);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.logbook != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Logbook' : 'Tambah Logbook'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              leading: const Icon(Icons.calendar_today),
              title: const Text('Tanggal Kegiatan'),
              subtitle: Text(formatTanggalIndo(_tanggal)),
              onTap: _pilihTanggal,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pilihJam(true),
                    icon: const Icon(Icons.schedule),
                    label: Text('Mulai: ${_formatTime(_jamMulai)}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pilihJam(false),
                    icon: const Icon(Icons.schedule_send),
                    label: Text('Selesai: ${_formatTime(_jamSelesai)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _kegiatan,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Uraian Kegiatan (min. 20 karakter)',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Uraian kegiatan wajib diisi';
                }
                if (v.trim().length < 20) {
                  return 'Uraian kegiatan minimal 20 karakter (saat ini ${v.trim().length})';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _kompetensi,
              decoration: const InputDecoration(
                labelText: 'Kompetensi Terkait',
                hintText: 'Contoh: Pemrograman Mobile / Basis Data',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Kompetensi wajib diisi'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _kendala,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Kendala (Opsional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _solusi,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Solusi (Opsional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: Text(isEdit ? 'Perbarui Logbook' : 'Simpan Logbook'),
            ),
          ],
        ),
      ),
    );
  }
}