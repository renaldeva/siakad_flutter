import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class AdminTagihanScreen extends StatefulWidget {
  const AdminTagihanScreen({super.key});

  @override
  State<AdminTagihanScreen> createState() => _AdminTagihanScreenState();
}

class _AdminTagihanScreenState extends State<AdminTagihanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TagihanUkt> _tagihan = [];
  List<RiwayatPembayaran> _riwayat = [];
  bool _loadingTagihan = true;
  bool _loadingRiwayat = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTagihan();
    _loadRiwayat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTagihan() async {
    setState(() => _loadingTagihan = true);
    try {
      final res = await ApiService.getSemuaTagihan();
      if (res['success'] == true) {
        setState(() {
          _tagihan =
              (res['data'] as List).map((e) => TagihanUkt.fromJson(e)).toList();
          _loadingTagihan = false;
        });
      }
    } catch (_) {
      setState(() => _loadingTagihan = false);
    }
  }

  Future<void> _loadRiwayat() async {
    setState(() => _loadingRiwayat = true);
    try {
      final res = await ApiService.getSemuaRiwayat();
      if (res['success'] == true) {
        setState(() {
          _riwayat = (res['data'] as List)
              .map((e) => RiwayatPembayaran.fromJson(e))
              .toList();
          _loadingRiwayat = false;
        });
      }
    } catch (_) {
      setState(() => _loadingRiwayat = false);
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
      case 'Terlambat':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _buatTagihan() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _BuatTagihanSheet(),
    );
    if (result == true) {
      _loadTagihan();
      _loadRiwayat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Tagihan'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Tagihan (${_tagihan.length})'),
            Tab(text: 'Riwayat (${_riwayat.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _buatTagihan,
        icon: const Icon(Icons.add),
        label: const Text('Buat Tagihan'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab Tagihan ──────────────────────────────────────────────────
          _loadingTagihan
              ? const Center(child: CircularProgressIndicator())
              : _tagihan.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long_outlined,
                              size: 72, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text('Belum ada tagihan',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _buatTagihan,
                            icon: const Icon(Icons.add),
                            label: const Text('Buat Tagihan Baru'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadTagihan,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
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
                                      Expanded(
                                        child: Text(t.namaMahasiswa,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15)),
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
                                              color:
                                                  _statusColor(t.statusTagihan),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            )),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sem ${t.semester} / ${t.tahunAkademik}  •  Gol. ${t.golonganUkt}',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                  Text(
                                    'Jatuh tempo: ${DateFormat('dd MMM yyyy').format(t.jatuhTempo)}',
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
                                            fontSize: 15,
                                            color: Color(0xFF1565C0),
                                          )),
                                      if (t.isLunas)
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
                    ),

          // ── Tab Riwayat Pembayaran ───────────────────────────────────────
          _loadingRiwayat
              ? const Center(child: CircularProgressIndicator())
              : _riwayat.isEmpty
                  ? const Center(
                      child: Text('Belum ada riwayat pembayaran',
                          style: TextStyle(color: Colors.grey)))
                  : RefreshIndicator(
                      onRefresh: _loadRiwayat,
                      child: ListView.builder(
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
                                    color: Colors.green, size: 20),
                              ),
                              title: Text(r.namaMahasiswa,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
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
                                ],
                              ),
                              trailing: Text(_fmt(r.jumlahBayar),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 14)),
                              isThreeLine: true,
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

// ─── Bottom Sheet Buat Tagihan ────────────────────────────────────────────────
class _BuatTagihanSheet extends StatefulWidget {
  const _BuatTagihanSheet();
  @override
  State<_BuatTagihanSheet> createState() => _BuatTagihanSheetState();
}

class _BuatTagihanSheetState extends State<_BuatTagihanSheet> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _mhsList = [];
  Map<String, dynamic>? _selected;
  bool _loadingMhs = true;
  bool _submitting = false;
  final _nilaiCtrl = TextEditingController();
  String _golongan = '1';
  int _semester = 1;
  int _tahun = DateTime.now().year;
  DateTime _jatuhTempo = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    ApiService.getMahasiswa().then((res) {
      if (res['success'] == true) {
        setState(() {
          _mhsList = List<Map<String, dynamic>>.from(res['data']);
          _loadingMhs = false;
        });
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selected == null) return;
    setState(() => _submitting = true);
    try {
      final res = await ApiService.buatTagihan(
        nim: _selected!['nim'],
        semester: _semester,
        tahunAkademik: _tahun,
        nilaiUkt: double.parse(_nilaiCtrl.text.replaceAll('.', '')),
        golongan: _golongan,
        jatuhTempo: _jatuhTempo.toUtc().toIso8601String(),
      );
      if (res['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Tagihan berhasil dibuat!'),
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

  InputDecoration _dec(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _loadingMhs
          ? const SizedBox(
              height: 200, child: Center(child: CircularProgressIndicator()))
          : Form(
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
                  const Text('Buat Tagihan UKT',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Pilih mahasiswa
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selected,
                    decoration: _dec('Pilih Mahasiswa', Icons.person_outline),
                    isExpanded: true,
                    items: _mhsList
                        .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m['namaLengkap'] ?? '',
                                overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) => setState(() => _selected = v),
                    validator: (v) => v == null ? 'Pilih mahasiswa' : null,
                  ),
                  if (_selected != null) ...[
                    const SizedBox(height: 4),
                    Text(_selected!['programStudi'] ?? '',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                  const SizedBox(height: 12),

                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _semester,
                        decoration:
                            _dec('Semester', Icons.format_list_numbered),
                        items: List.generate(14, (i) => i + 1)
                            .map((s) => DropdownMenuItem(
                                value: s, child: Text('Sem $s')))
                            .toList(),
                        onChanged: (v) => setState(() => _semester = v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _tahun,
                        decoration:
                            _dec('Tahun', Icons.calendar_month_outlined),
                        items: List.generate(
                                5, (i) => DateTime.now().year - 2 + i)
                            .map((y) =>
                                DropdownMenuItem(value: y, child: Text('$y')))
                            .toList(),
                        onChanged: (v) => setState(() => _tahun = v!),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _nilaiCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        _dec('Nilai UKT (contoh: 5000000)', Icons.attach_money),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Masukkan nilai UKT';
                      if (double.tryParse(v.replaceAll('.', '')) == null)
                        return 'Tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _golongan,
                        decoration: _dec('Golongan', Icons.category_outlined),
                        items: List.generate(8, (i) => '${i + 1}')
                            .map((g) => DropdownMenuItem(
                                value: g, child: Text('Gol. $g')))
                            .toList(),
                        onChanged: (v) => setState(() => _golongan = v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _jatuhTempo,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null)
                            setState(() => _jatuhTempo = picked);
                        },
                        child: InputDecorator(
                          decoration: _dec('', Icons.event_outlined),
                          child: Text(
                              DateFormat('dd MMM yyyy').format(_jatuhTempo),
                              style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                    ),
                  ]),
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
                          : const Icon(Icons.save_outlined),
                      label:
                          Text(_submitting ? 'Menyimpan...' : 'Simpan Tagihan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
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
