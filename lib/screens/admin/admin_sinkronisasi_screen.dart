import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminSinkronisasiScreen extends StatefulWidget {
  const AdminSinkronisasiScreen({super.key});

  @override
  State<AdminSinkronisasiScreen> createState() =>
      _AdminSinkronisasiScreenState();
}

class _AdminSinkronisasiScreenState extends State<AdminSinkronisasiScreen> {
  bool _loading = false;
  bool _previewLoading = false;
  String? _pesan;
  bool? _sukses;
  List<dynamic> _previewData = [];
  Map<String, dynamic>? _hasil;

  Future<void> _sinkronisasi() async {
    setState(() {
      _loading = true;
      _pesan = null;
      _sukses = null;
      _hasil = null;
    });
    try {
      final res = await ApiService.sinkronisasiMahasiswa();
      setState(() {
        _loading = false;
        _sukses = res['success'] == true;
        _pesan = res['message'];
        _hasil = res['data'];
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _sukses = false;
        _pesan = 'Error: $e';
      });
    }
  }

  Future<void> _preview() async {
    setState(() {
      _previewLoading = true;
      _previewData = [];
    });
    try {
      final res = await ApiService.previewApiMahasiswa();
      if (res['success'] == true) {
        setState(() {
          _previewData = res['data'] ?? [];
          _previewLoading = false;
        });
      } else {
        setState(() => _previewLoading = false);
      }
    } catch (e) {
      setState(() => _previewLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sinkronisasi Data')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Informasi Sinkronisasi',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    SizedBox(height: 8),
                    Text(
                      'Proses ini akan mengambil data mahasiswa dari '
                      'API Mahasiswa eksternal dan menyimpannya ke database secara dinamis.',
                      style: TextStyle(fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    Text('Sumber: mahasiswa-api-psi.vercel.app',
                        style: TextStyle(fontSize: 11, color: Colors.blue)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Preview button
            OutlinedButton.icon(
              icon: _previewLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.preview),
              label: const Text('Preview Data dari API Mahasiswa'),
              onPressed: _previewLoading ? null : _preview,
            ),

            // Preview list
            if (_previewData.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('${_previewData.length} data ditemukan:',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...(_previewData.take(5).map((m) => Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.person_outline),
                      title: Text(m['nama'] ?? m['namaLengkap'] ?? ''),
                      subtitle: Text(m['programStudi'] ?? ''),
                    ),
                  ))),
              if (_previewData.length > 5)
                Text('... dan ${_previewData.length - 5} data lainnya',
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center),
            ],

            const SizedBox(height: 16),

            // Sync button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.sync),
                label:
                    Text(_loading ? 'Menyinkronkan...' : 'Mulai Sinkronisasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                ),
                onPressed: _loading ? null : _sinkronisasi,
              ),
            ),

            // Result
            if (_pesan != null) ...[
              const SizedBox(height: 16),
              Card(
                color: (_sukses ?? false)
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(
                          (_sukses ?? false) ? Icons.check_circle : Icons.error,
                          color: (_sukses ?? false) ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          (_sukses ?? false) ? 'Berhasil' : 'Gagal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                (_sukses ?? false) ? Colors.green : Colors.red,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Text(_pesan!),
                      if (_hasil != null) ...[
                        const Divider(),
                        _Row('Data Diambil', '${_hasil!['jumlahDataDiambil']}'),
                        _Row('Data Baru', '${_hasil!['jumlahDataBaru']}'),
                        _Row('Data Diperbarui',
                            '${_hasil!['jumlahDataDiupdate']}'),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
