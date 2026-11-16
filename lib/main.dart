import 'package:flutter/material.dart';
import 'database/prefs_helper.dart';
import 'screens/beranda_screen.dart';
import 'screens/logbook_screen.dart';
import 'screens/pengaturan_screen.dart';
import 'screens/presensi_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final temaAwal = await PrefsHelper.instance.getTemaGelap();
  runApp(MyApp(temaGelapAwal: temaAwal));
}

class MyApp extends StatelessWidget {
  final bool temaGelapAwal;

  const MyApp({super.key, this.temaGelapAwal = false});

  @override
  Widget build(BuildContext context) {
    return PklTrackerApp(temaGelapAwal: temaGelapAwal);
  }
}

class PklTrackerApp extends StatefulWidget {
  final bool temaGelapAwal;

  const PklTrackerApp({super.key, required this.temaGelapAwal});

  @override
  State<PklTrackerApp> createState() => _PklTrackerAppState();
}

class _PklTrackerAppState extends State<PklTrackerApp> {
  late bool _temaGelap = widget.temaGelapAwal;

  Future<void> _ubahTema(bool gelap) async {
    await PrefsHelper.instance.setTemaGelap(gelap);
    setState(() => _temaGelap = gelap);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PKL Tracker Local',
      debugShowCheckedModeBanner: false,
      themeMode: _temaGelap ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: HalamanUtama(
        temaGelap: _temaGelap,
        onUbahTema: _ubahTema,
      ),
    );
  }
}

class HalamanUtama extends StatefulWidget {
  final bool temaGelap;
  final ValueChanged<bool> onUbahTema;

  const HalamanUtama({
    super.key,
    required this.temaGelap,
    required this.onUbahTema,
  });

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _index = 0;
  final _berandaKey = GlobalKey<BerandaScreenState>();

  void _pindahTab(int index) {
    setState(() => _index = index);
    if (index == 0) {
      _berandaKey.currentState?.muatData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final halaman = [
      BerandaScreen(key: _berandaKey, onPindahTab: _pindahTab),
      const PresensiScreen(),
      const LogbookScreen(),
      PengaturanScreen(
        temaGelap: widget.temaGelap,
        onUbahTema: widget.onUbahTema,
        onDataBerubah: () => _berandaKey.currentState?.muatData(),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: halaman,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _pindahTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.fingerprint_outlined),
            selectedIcon: Icon(Icons.fingerprint),
            label: 'Presensi',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Logbook',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}