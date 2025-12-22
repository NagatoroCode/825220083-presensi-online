import 'package:aplikasiabsensi/model/jenisStatus.dart';

class PengajuanIzin {
  String? izinID;
  String? userID;
  String? statusID;
  String? waktuMulai;
  String? waktuSelesai;
  String tanggalIzin;
  String alasanIzin;
  String statusPengajuan;
  String? tanggalPengajuan;
  String? tanggalVerifikasi;

  jenisStatus? status;

  PengajuanIzin({
    this.izinID,
    this.userID,
    this.statusID,
    this.waktuMulai,
    this.waktuSelesai,
    required this.tanggalIzin,
    required this.alasanIzin,
    required this.statusPengajuan,
    this.tanggalPengajuan,
    this.tanggalVerifikasi,
    this.status,
  });

  factory PengajuanIzin.fromMap(Map<String, dynamic> Map) {
    return PengajuanIzin(
      izinID: Map['izinID']?.toString(),
      userID: Map['userID']?.toString(),
      statusID: Map['statusID']?.toString(),
      waktuMulai: Map['waktuMulai'],
      waktuSelesai: Map['waktuSelesai'],
      tanggalIzin: Map['tanggalIzin'],
      alasanIzin: Map['alasanIzin'],
      statusPengajuan: Map['statusPengajuan'],
      tanggalPengajuan: Map['tanggalPengajuan'],
      tanggalVerifikasi: Map['tanggalVerifikasi'],

      status: Map['jenisStatus'] != null
          ? jenisStatus.fromMap(Map['jenisStatus'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'statusID': statusID,
      'waktuMulai': waktuMulai,
      'waktuSelesai': waktuSelesai,
      'tanggalIzin': tanggalIzin,
      'alasanIzin': alasanIzin,
      'statusPengajuan': statusPengajuan,
      'tanggalVerifikasi': tanggalVerifikasi,
    };
  }

  PengajuanIzin copyWith({
    String? izinID,
    String? userID,
    String? statusID,
    String? waktuMulai,
    String? waktuSelesai,
    String? tanggalIzin,
    String? alasanIzin,
    String? statusPengajuan,
    String? tanggalVerifikasi,
    jenisStatus? status,
  }) {
    return PengajuanIzin(
      izinID: izinID ?? this.izinID,
      userID: userID ?? this.userID,
      statusID: statusID ?? this.statusID,
      waktuMulai: waktuMulai ?? this.waktuMulai,
      waktuSelesai: waktuSelesai ?? this.waktuSelesai,
      tanggalIzin: tanggalIzin ?? this.tanggalIzin,
      alasanIzin: alasanIzin ?? this.alasanIzin,
      statusPengajuan: statusPengajuan ?? this.statusPengajuan,
      tanggalPengajuan: tanggalPengajuan ?? this.tanggalPengajuan,
      tanggalVerifikasi: tanggalVerifikasi ?? this.tanggalVerifikasi,
      status: status ?? this.status,
    );
  }
}
