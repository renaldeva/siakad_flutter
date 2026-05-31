import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class MhsCariScreen extends StatefulWidget {
  const MhsCariScreen({super.key});

  @override
  State<MhsCariScreen> createState() => _MhsCariScreenState();
}

class _MhsCariScreenState extends State<MhsCariScreen> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _hasil = [];
  bool _loading = false;
  bool _sudahCari = false;
  Map<String, dynamic>? _mahasiswaTerpilih;

  Future<void> _cari() async {
    final keyword = _searchCtrl.text.trim();
    if (keyword.isEmpty) return;
    setState(() {
      _loading = true;
      _sudahCari = true;
      _mahasiswaTerpilih = null;
    });
    try {
      final res = await ApiService.getMahasiswa(search: keyword);
      if (res['success'] == true) {
        setState(() {
          _hasil = List<Map<String, dynamic>>.from(res['data']);
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _inisial(String nama) {
    final p = nama.trim().split(' ');
    return p.length >= 2
        ? '${p[0][0]}${p[1][0]}'.toUpperCase()
        : nama.isNotEmpty
            ? nama[0].toUpperCase()
            : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portal Mahasiswa')),
      body: _mahasiswaTerpilih != null
          ? _MhsTagihanView(
              mahasiswa: _mahasiswaTerpilih!,
              onBack: () => setState(() => _mahasiswaTerpilih = null),
            )
          : Column(
              children: [
                // Banner info
                Container(
                  width: double.infinity,
                  color: Colors.blue.shade50,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cari nama kamu untuk melihat tagihan & riwayat pembayaran',
                          style: TextStyle(color: Colors.blue, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Ketik nama kamu...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          onSubmitted: (_) => _cari(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _cari,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cari'),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : !_sudahCari
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.person_search,
                                      size: 80, color: Colors.grey),
                                  SizedBox(height: 12),
                                  Text('Masukkan nama untuk mencari',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          : _hasil.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.search_off,
                                          size: 64, color: Colors.grey),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Nama "${_searchCtrl.text}" tidak ditemukan',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  itemCount: _hasil.length,
                                  itemBuilder: (ctx, i) {
                                    final m = _hasil[i];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              const Color(0xFF1565C0),
                                          child: Text(
                                            _inisial(m['namaLengkap'] ?? ''),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        title: Text(m['namaLengkap'] ?? '',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                          '${m['programStudi'] ?? ''}  •  Angkatan ${m['angkatan']}',
                                        ),
                                        trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16),
                                        onTap: () => setState(
                                            () => _mahasiswaTerpilih = m),
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

// ─── View tagihan milik mahasiswa terpilih ────────────────────────────────────
class _MhsTagihanView extends StatefulWidget {
  final Map<String, dynamic> mahasiswa;
  final VoidCallback onBack;
  const _MhsTagihanView({required this.mahasiswa, required this.onBack});

  @override
  State<_MhsTagihanView> createState() => _MhsTagihanViewState();
}

class _MhsTagihanViewState extends State<_MhsTagihanView>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<TagihanUkt> _tagihan = [];
  List<RiwayatPembayaran> _riwayat = [];
  bool _loadingT = true;
  bool _loadingR = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadTagihan();
    _loadRiwayat();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadTagihan() async {
    setState(() => _loadingT = true);
    try {
      final res = await ApiService.getTagihanByNim(widget.mahasiswa['nim']);
      if (res['success'] == true) {
        setState(() {
          _tagihan =
              (res['data'] as List).map((e) => TagihanUkt.fromJson(e)).toList();
          _loadingT = false;
        });
      }
    } catch (_) {
      setState(() => _loadingT = false);
    }
  }

  Future<void> _loadRiwayat() async {
    setState(() => _loadingR = true);
    try {
      final res =
          await ApiService.getRiwayatPembayaran(widget.mahasiswa['nim']);
      if (res['success'] == true) {
        setState(() {
          _riwayat = (res['data'] as List)
              .map((e) => RiwayatPembayaran.fromJson(e))
              .toList();
          _loadingR = false;
        });
      }
    } catch (_) {
      setState(() => _loadingR = false);
    }
  }

  String _fmt(double val) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(val);

  Color _statusColor(String s) {
    switch (s) {
      case 'Lunas':
        return Colors.green;
      case 'Cicilan':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _bayar(TagihanUkt t) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _BayarSheet(tagihan: t),
    );
    if (result == true) {
      _loadTagihan();
      _loadRiwayat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.mahasiswa;
    return Column(
      children: [
        // Info mahasiswa
        Container(
          width: double.infinity,
          color: const Color(0xFF1565C0),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: widget.onBack,
                  ),
                  Expanded(
                    child: Text(m['namaLengkap'] ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 48, bottom: 8),
                child: Text(
                  '${m['programStudi']}  •  Angkatan ${m['angkatan']}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              TabBar(
                controller: _tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: 'Tagihan (${_tagihan.length})'),
                  Tab(text: 'Riwayat (${_riwayat.length})'),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              // Tab tagihan
              _loadingT
                  ? const Center(child: CircularProgressIndicator())
                  : _tagihan.isEmpty
                      ? const Center(
                          child: Text('Belum ada tagihan',
                              style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _tagihan.length,
                          itemBuilder: (ctx, i) {
                            final t = _tagihan[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Semester ${t.semester} / ${t.tahunAkademik}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _statusColor(t.statusTagihan)
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: _statusColor(
                                                    t.statusTagihan)),
                                          ),
                                          child: Text(t.statusTagihan,
                                              style: TextStyle(
                                                color: _statusColor(
                                                    t.statusTagihan),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              )),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Golongan ${t.golonganUkt}  •  Jatuh tempo: ${DateFormat('dd MMM yyyy').format(t.jatuhTempo)}',
                                      style: TextStyle(
                                        color: t.isTerlambat
                                            ? Colors.red
                                            : Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Divider(height: 14),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_fmt(t.nilaiUkt),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF1565C0),
                                            )),
                                        if (!t.isLunas)
                                          ElevatedButton.icon(
                                            onPressed: () => _bayar(t),
                                            icon: const Icon(Icons.payment,
                                                size: 16),
                                            label: const Text('Bayar'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF1565C0),
                                              foregroundColor: Colors.white,
                                            ),
                                          )
                                        else
                                          const Row(children: [
                                            Icon(Icons.check_circle,
                                                color: Colors.green, size: 16),
                                            SizedBox(width: 4),
                                            Text('Lunas',
                                                style: TextStyle(
                                                    color: Colors.green)),
                                          ]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

              // Tab riwayat
              _loadingR
                  ? const Center(child: CircularProgressIndicator())
                  : _riwayat.isEmpty
                      ? const Center(
                          child: Text('Belum ada riwayat pembayaran',
                              style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _riwayat.length,
                          itemBuilder: (ctx, i) {
                            final r = _riwayat[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.shade100,
                                  child: const Icon(Icons.check,
                                      color: Colors.green),
                                ),
                                title: Text(_fmt(r.jumlahBayar),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.metodePembayaran),
                                    Text(
                                      DateFormat('dd MMM yyyy HH:mm')
                                          .format(r.tanggalBayar),
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    if (r.keterangan != null)
                                      Text(r.keterangan!,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey)),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Bottom Sheet Bayar ───────────────────────────────────────────────────────
class _BayarSheet extends StatefulWidget {
  final TagihanUkt tagihan;
  const _BayarSheet({required this.tagihan});
  @override
  State<_BayarSheet> createState() => _BayarSheetState();
}

class _BayarSheetState extends State<_BayarSheet> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahCtrl = TextEditingController();
  final _ketCtrl = TextEditingController();
  String _metode = 'Transfer Bank';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _jumlahCtrl.text = widget.tagihan.nilaiUkt.toStringAsFixed(0);
  }

  String _fmt(double val) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(val);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final res = await ApiService.bayarTagihan(
        tagihanId: widget.tagihan.id,
        jumlahBayar: double.parse(_jumlahCtrl.text.replaceAll('.', '')),
        metodePembayaran: _metode,
        keterangan: _ketCtrl.text.isEmpty ? null : _ketCtrl.text,
      );
      if (res['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Pembayaran berhasil!'),
              backgroundColor: Colors.green));
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tagihan;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Bayar Tagihan UKT',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Info tagihan
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Semester ${t.semester} / ${t.tahunAkademik}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(_fmt(t.nilaiUkt),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _jumlahCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Bayar',
                prefixText: 'Rp ',
                prefixIcon: const Icon(Icons.attach_money),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Masukkan jumlah';
                if (double.tryParse(v.replaceAll('.', '')) == null)
                  return 'Tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 12),

            const Text('Metode Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: ['Transfer Bank', 'Virtual Account', 'QRIS', 'Tunai']
                  .map((m) => ChoiceChip(
                        label: Text(m),
                        selected: _metode == m,
                        onSelected: (_) => setState(() => _metode = m),
                        selectedColor: const Color(0xFF1565C0).withOpacity(0.2),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _ketCtrl,
              decoration: InputDecoration(
                labelText: 'Keterangan (opsional)',
                prefixIcon: const Icon(Icons.notes_outlined),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                    _submitting ? 'Memproses...' : 'Konfirmasi Pembayaran'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
