class Mahasiswa {
  final int id;
  final String nim;
  final String namaLengkap;
  final String programStudi;
  final String fakultas;
  final int angkatan;
  final String statusAkademik;
  final String? email;
  final String? noHp;
  final double totalTunggakan;

  Mahasiswa({
    required this.id,
    required this.nim,
    required this.namaLengkap,
    required this.programStudi,
    required this.fakultas,
    required this.angkatan,
    required this.statusAkademik,
    this.email,
    this.noHp,
    this.totalTunggakan = 0,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> j) => Mahasiswa(
    id: j['id'] ?? 0,
    nim: j['nim'] ?? '',
    namaLengkap: j['namaLengkap'] ?? '',
    programStudi: j['programStudi'] ?? '',
    fakultas: j['fakultas'] ?? '',
    angkatan: j['angkatan'] ?? 0,
    statusAkademik: j['statusAkademik'] ?? 'Aktif',
    email: j['email'],
    noHp: j['noHp'],
    totalTunggakan: (j['totalTunggakan'] ?? 0).toDouble(),
  );
}

class TagihanUkt {
  final int id;
  final String nomorTagihan;
  final String nimMahasiswa;
  final String namaMahasiswa;
  final int semester;
  final int tahunAkademik;
  final double nilaiUkt;
  final String golonganUkt;
  final String statusTagihan;
  final DateTime tanggalTagihan;
  final DateTime jatuhTempo;
  final DateTime? tanggalLunas;

  TagihanUkt({
    required this.id,
    required this.nomorTagihan,
    required this.nimMahasiswa,
    required this.namaMahasiswa,
    required this.semester,
    required this.tahunAkademik,
    required this.nilaiUkt,
    required this.golonganUkt,
    required this.statusTagihan,
    required this.tanggalTagihan,
    required this.jatuhTempo,
    this.tanggalLunas,
  });

  factory TagihanUkt.fromJson(Map<String, dynamic> j) => TagihanUkt(
    id: j['id'] ?? 0,
    nomorTagihan: j['nomorTagihan'] ?? '',
    nimMahasiswa: j['nimMahasiswa'] ?? '',
    namaMahasiswa: j['namaMahasiswa'] ?? '',
    semester: j['semester'] ?? 0,
    tahunAkademik: j['tahunAkademik'] ?? 0,
    nilaiUkt: (j['nilaiUkt'] ?? 0).toDouble(),
    golonganUkt: j['golonganUkt'] ?? '',
    statusTagihan: j['statusTagihan'] ?? '',
    tanggalTagihan: DateTime.parse(j['tanggalTagihan']),
    jatuhTempo: DateTime.parse(j['jatuhTempo']),
    tanggalLunas: j['tanggalLunas'] != null
        ? DateTime.parse(j['tanggalLunas'])
        : null,
  );

  bool get isLunas => statusTagihan == 'Lunas';
  bool get isTerlambat => !isLunas && DateTime.now().isAfter(jatuhTempo);
}

class RiwayatPembayaran {
  final int id;
  final String nomorTransaksi;
  final String nimMahasiswa;
  final String namaMahasiswa;
  final int tagihanUktId;
  final double jumlahBayar;
  final String metodePembayaran;
  final String statusPembayaran;
  final String? keterangan;
  final DateTime tanggalBayar;

  RiwayatPembayaran({
    required this.id,
    required this.nomorTransaksi,
    required this.nimMahasiswa,
    required this.namaMahasiswa,
    required this.tagihanUktId,
    required this.jumlahBayar,
    required this.metodePembayaran,
    required this.statusPembayaran,
    this.keterangan,
    required this.tanggalBayar,
  });

  factory RiwayatPembayaran.fromJson(Map<String, dynamic> j) =>
      RiwayatPembayaran(
        id: j['id'] ?? 0,
        nomorTransaksi: j['nomorTransaksi'] ?? '',
        nimMahasiswa: j['nimMahasiswa'] ?? '',
        namaMahasiswa: j['namaMahasiswa'] ?? '',
        tagihanUktId: j['tagihanUktId'] ?? 0,
        jumlahBayar: (j['jumlahBayar'] ?? 0).toDouble(),
        metodePembayaran: j['metodePembayaran'] ?? '',
        statusPembayaran: j['statusPembayaran'] ?? '',
        keterangan: j['keterangan'],
        tanggalBayar: DateTime.parse(j['tanggalBayar']),
      );
}

class DashboardSummary {
  final int totalMahasiswa;
  final int totalTagihan;
  final int tagihanLunas;
  final int tagihanBelumBayar;
  final double totalPenerimaan;
  final int totalTransaksi;
  final double persentaseLunas;

  DashboardSummary({
    required this.totalMahasiswa,
    required this.totalTagihan,
    required this.tagihanLunas,
    required this.tagihanBelumBayar,
    required this.totalPenerimaan,
    required this.totalTransaksi,
    required this.persentaseLunas,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> j) => DashboardSummary(
    totalMahasiswa: j['totalMahasiswa'] ?? 0,
    totalTagihan: j['totalTagihan'] ?? 0,
    tagihanLunas: j['tagihanLunas'] ?? 0,
    tagihanBelumBayar: j['tagihanBelumBayar'] ?? 0,
    totalPenerimaan: (j['totalPenerimaan'] ?? 0).toDouble(),
    totalTransaksi: j['totalTransaksi'] ?? 0,
    persentaseLunas: (j['persentaseLunas'] ?? 0).toDouble(),
  );
}
