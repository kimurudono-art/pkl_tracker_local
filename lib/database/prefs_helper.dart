import 'package:shared_preferences/shared_preferences.dart';
import '../models/profil_pkl.dart';

class PrefsHelper {
  PrefsHelper._();
  static final PrefsHelper instance = PrefsHelper._();

  Future<bool> getTemaGelap() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tema_gelap') ?? false;
  }

  Future<void> setTemaGelap(bool gelap) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tema_gelap', gelap);
  }

  Future<ProfilPkl?> getProfil() async {
    final prefs = await SharedPreferences.getInstance();
    final nama = prefs.getString('profil_nama');
    if (nama == null || nama.isEmpty) return null;

    return ProfilPkl(
      nama: nama,
      nis: prefs.getString('profil_nis') ?? '',
      kelas: prefs.getString('profil_kelas') ?? '',
      tempatPkl: prefs.getString('profil_tempat') ?? '',
      pembimbingIndustri: prefs.getString('profil_pembimbing_ind') ?? '',
      pembimbingSekolah: prefs.getString('profil_pembimbing_sek') ?? '',
      tanggalMulai: DateTime.parse(
        prefs.getString('profil_mulai') ?? DateTime.now().toIso8601String(),
      ),
      tanggalSelesai: DateTime.parse(
        prefs.getString('profil_selesai') ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Future<void> simpanProfil(ProfilPkl p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profil_nama', p.nama);
    await prefs.setString('profil_nis', p.nis);
    await prefs.setString('profil_kelas', p.kelas);
    await prefs.setString('profil_tempat', p.tempatPkl);
    await prefs.setString('profil_pembimbing_ind', p.pembimbingIndustri);
    await prefs.setString('profil_pembimbing_sek', p.pembimbingSekolah);
    await prefs.setString('profil_mulai', p.tanggalMulai.toIso8601String());
    await prefs.setString('profil_selesai', p.tanggalSelesai.toIso8601String());
  }

  Future<void> hapusProfil() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profil_nama');
    await prefs.remove('profil_nis');
    await prefs.remove('profil_kelas');
    await prefs.remove('profil_tempat');
    await prefs.remove('profil_pembimbing_ind');
    await prefs.remove('profil_pembimbing_sek');
    await prefs.remove('profil_mulai');
    await prefs.remove('profil_selesai');
  }
}