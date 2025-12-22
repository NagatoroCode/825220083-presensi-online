import 'package:aplikasiabsensi/model/jenisCuti.dart';

class Pengajuancuti {
  String? cutiID;
  String? userID;
  String? jenisCutiID;
  String tanggalMulai;
  String tanggalSelesai;
  String alasanCuti;
  String statusPengajuan;
  String? tanggalPengajuan;
  String? tanggalVerifikasi;

  jenisCuti? cuti;

  Pengajuancuti({
    this.cutiID,
    this.userID,
    this.jenisCutiID,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.alasanCuti,
    required this.statusPengajuan,
    this.tanggalPengajuan,
    this.tanggalVerifikasi,
    this.cuti,
  });

  /// 🔹 Parsing dari Supabase ke model
  factory Pengajuancuti.fromMap(Map<String, dynamic> map) {
    return Pengajuancuti(
      cutiID: map['cutiID']?.toString(),
      userID: map['userID']?.toString(),
      jenisCutiID: map['jenisCutiID']?.toString(),
      tanggalMulai: map['tanggalMulai'],
      tanggalSelesai: map['tanggalSelesai'],
      alasanCuti: map['alasanCuti'],
      statusPengajuan: map['statusPengajuan'],
      tanggalPengajuan: map['tanggalPengajuan'],
      tanggalVerifikasi: map['tanggalVerifikasi'],
      cuti: map['jenisCuti'] != null
          ? jenisCuti.fromMap(map['jenisCuti'])
          : null,
    );
  }

  /// 🔹 Untuk kirim data ke Supabase
  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'jenisCutiID': jenisCutiID,
      'tanggalMulai': tanggalMulai,
      'tanggalSelesai': tanggalSelesai,
      'alasanCuti': alasanCuti,
      'statusPengajuan': statusPengajuan,
      'tanggalVerifikasi': tanggalVerifikasi,
    };
  }

  Pengajuancuti copyWith({
    String? cutiID,
    String? userID,
    String? jenisCutiID,
    String? tanggalMulai,
    String? tanggalSelesai,
    String? alasanCuti,
    String? statusPengajuan,
    String? tanggalVerifikasi,
    jenisCuti? cuti,
  }) {
    return Pengajuancuti(
      cutiID: cutiID ?? this.cutiID,
      userID: userID ?? this.userID,
      jenisCutiID: jenisCutiID ?? this.jenisCutiID,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      alasanCuti: alasanCuti ?? this.alasanCuti,
      statusPengajuan: statusPengajuan ?? this.statusPengajuan,
      tanggalPengajuan: tanggalPengajuan ?? this.tanggalPengajuan,
      tanggalVerifikasi: tanggalVerifikasi ?? this.tanggalVerifikasi,
      cuti: cuti ?? this.cuti,
    );
  }
}
