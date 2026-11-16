import 'package:flutter/material.dart';

String formatTanggalIndo(DateTime dt) {
  const namaBulan = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${dt.day.toString().padLeft(2, '0')} ${namaBulan[dt.month]} ${dt.year}';
}

String formatJamSekarang(DateTime dt) {
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

String namaBulanDariKey(String ym) {
  const namaBulan = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  final parts = ym.split('-');
  if (parts.length < 2) return ym;
  final m = int.tryParse(parts[1]) ?? 0;
  if (m < 1 || m > 12) return ym;
  return '${namaBulan[m]} ${parts[0]}';
}

class KartuRingkasan extends StatelessWidget {
  final String judul;
  final String nilai;
  final String subjudul;
  final IconData ikon;
  final Color warna;

  const KartuRingkasan({
    super.key,
    required this.judul,
    required this.nilai,
    required this.subjudul,
    required this.ikon,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(ikon, size: 20, color: warna),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    judul,
                    style: Theme.of(context).textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              nilai,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: warna,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subjudul,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}