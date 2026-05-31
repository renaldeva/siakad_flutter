import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti dengan URL backend Anda setelah deploy
  // static const String baseUrl = 'http://10.0.2.2:5000'; // Android emulator
  static const String baseUrl = 'http://localhost:5049'; // iOS simulator
  // static const String baseUrl = 'https://your-api.railway.app'; // Production

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ─── Helper ────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> _get(String path) async {
    final res = await http
        .get(Uri.parse('$baseUrl$path'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> _patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final res = await http
        .patch(
          Uri.parse('$baseUrl$path'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return jsonDecode(res.body);
  }

  // ─── SINKRONISASI ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> sinkronisasiMahasiswa() =>
      _post('/api/sinkronisasi/mahasiswa', {});

  static Future<Map<String, dynamic>> previewApiMahasiswa() =>
      _get('/api/sinkronisasi/preview');

  // ─── MAHASISWA ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getMahasiswa({
    String? search,
    String? prodi,
    String? status,
  }) {
    var path = '/api/mahasiswa';
    final params = <String, String>{};
    if (search != null) params['search'] = search;
    if (prodi != null) params['prodi'] = prodi;
    if (status != null) params['status'] = status;
    if (params.isNotEmpty) {
      path += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }
    return _get(path);
  }

  static Future<Map<String, dynamic>> getMahasiswaByNim(String nim) =>
      _get('/api/mahasiswa/$nim');

  // ─── TAGIHAN ───────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getSemuaTagihan() =>
      _get('/api/keuangan/tagihan');

  static Future<Map<String, dynamic>> getTagihanByNim(String nim) =>
      _get('/api/keuangan/tagihan/mahasiswa/$nim');

  static Future<Map<String, dynamic>> getTagihanById(int id) =>
      _get('/api/keuangan/tagihan/$id');

  static Future<Map<String, dynamic>> buatTagihan({
    required String nim,
    required int semester,
    required int tahunAkademik,
    required double nilaiUkt,
    required String golongan,
    required String jatuhTempo,
  }) =>
      _post('/api/keuangan/tagihan', {
        'nimMahasiswa': nim,
        'semester': semester,
        'tahunAkademik': tahunAkademik,
        'nilaiUkt': nilaiUkt,
        'golonganUkt': golongan,
        'jatuhTempo': jatuhTempo,
      });

  // ─── PEMBAYARAN ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> bayarTagihan({
    required int tagihanId,
    required double jumlahBayar,
    required String metodePembayaran,
    String? keterangan,
  }) =>
      _post('/api/keuangan/pembayaran', {
        'tagihanUktId': tagihanId,
        'jumlahBayar': jumlahBayar,
        'metodePembayaran': metodePembayaran,
        'keterangan': keterangan,
      });

  static Future<Map<String, dynamic>> getRiwayatPembayaran(String nim) =>
      _get('/api/keuangan/pembayaran/mahasiswa/$nim');

  static Future<Map<String, dynamic>> getSemuaRiwayat() =>
      _get('/api/keuangan/pembayaran');

  // ─── RINGKASAN & DASHBOARD ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getRingkasan(String nim) =>
      _get('/api/keuangan/ringkasan/$nim');

  static Future<Map<String, dynamic>> getDashboard() =>
      _get('/api/keuangan/dashboard');
}
