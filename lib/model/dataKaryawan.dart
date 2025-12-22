import 'package:aplikasiabsensi/model/jabatan.dart';
import 'package:aplikasiabsensi/model/jenisPTKP.dart';

class dataKaryawan {
  String? karyawanID;
  String userID;
  String jabatanID;
  String ptkpID;
  String namaLengkap;
  int gajiPokok;
  int uangMakan;
  String nomorTelepon;
  String alamat;
  String? tanggalMasuk;
  String? fotoProfil;
  String status;

  Jabatan? jabatan;
  JenisPTKP? jenisPTKP;

  dataKaryawan({
    this.karyawanID,
    required this.userID,
    required this.jabatanID,
    required this.ptkpID,
    required this.namaLengkap,
    required this.gajiPokok,
    required this.uangMakan,
    required this.nomorTelepon,
    required this.alamat,
    this.tanggalMasuk,
    this.fotoProfil,
    required this.status,
    this.jabatan,
    this.jenisPTKP,
  });

  factory dataKaryawan.fromMap(Map<String, dynamic> map) {
    return dataKaryawan(
      karyawanID: map['karyawanID']?.toString(),
      userID: map['userID'],
      jabatanID: map['jabatanID'],
      ptkpID: map['ptkpID'],
      namaLengkap: map['namaLengkap'],
      gajiPokok: map['gajiPokok'],
      uangMakan: map['uangMakan'],
      nomorTelepon: map['nomorTelepon'],
      alamat: map['alamat'],
      fotoProfil: map['fotoProfil'],
      tanggalMasuk: map['tanggalMasuk'],
      status: map['status'],
      jabatan: map['jenisJabatan'] != null
          ? Jabatan.fromMap(map['jenisJabatan'])
          : null,
      jenisPTKP: map['jenisPTKP'] != null
          ? JenisPTKP.fromMap(map['jenisPTKP'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'jabatanID': jabatanID,
      'ptkpID': ptkpID,
      'namaLengkap': namaLengkap,
      'gajiPokok': gajiPokok,
      'uangMakan': uangMakan,
      'nomorTelepon': nomorTelepon,
      'alamat': alamat,
      'fotoProfil': fotoProfil,
      'status': status,
    };
  }
}
