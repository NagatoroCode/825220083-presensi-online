// file: historygaji.dart
import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/model/tarifProgresif.dart';
import 'package:aplikasiabsensi/model/tarifTer.dart';

class Historygaji {
  String? gajiID;
  String? karyawanID;
  String? tarifTerID;
  String? tarifProgresifID;

  String periodeBulan;
  String periodeTahun;

  String totalJamKerja;
  String totalJamLembur;

  int ekspektasiGaji;
  int gajiPokok;
  int uangMakan;
  int uangLembur;

  double tarifPajak;
  double potonganPajak;
  int totalGajiBruto;
  int totalGajiNetto;

  dataKaryawan? karyawan;
  tarifProgresif? progresif;
  tarifTer? ter;

  Historygaji({
    this.gajiID,
    this.karyawanID,
    this.tarifTerID,
    this.tarifProgresifID,
    required this.periodeBulan,
    required this.periodeTahun,
    required this.totalJamKerja,
    required this.totalJamLembur,
    required this.ekspektasiGaji,
    required this.gajiPokok,
    required this.uangMakan,
    required this.uangLembur,
    required this.tarifPajak,
    required this.potonganPajak,
    required this.totalGajiBruto,
    required this.totalGajiNetto,
    this.karyawan,
    this.progresif,
    this.ter,
  });

  factory Historygaji.fromMap(Map<String, dynamic> map) {
    return Historygaji(
      gajiID: map['gajiID']?.toString(),
      karyawanID: map['karyawanID']?.toString(),
      tarifTerID: map['tarifTerID']?.toString(),
      tarifProgresifID: map['tarifProgresifID']?.toString(),
      periodeBulan: map['periodeBulan']?.toString() ?? '0',
      periodeTahun: map['periodeTahun']?.toString() ?? '0',
      totalJamKerja: map['totalJamKerja']?.toString() ?? '00:00:00',
      totalJamLembur: map['totalJamLembur']?.toString() ?? '00:00:00',
      ekspektasiGaji: (map['ekspektasiGaji'] ?? 0).toInt(),
      gajiPokok: (map['gajiPokok'] ?? 0).toInt(),
      uangMakan: (map['uangMakan'] ?? 0).toInt(),
      uangLembur: (map['uangLembur'] ?? 0).toInt(),
      tarifPajak: (map['tarifPajak'] ?? 0).toDouble(),
      potonganPajak: (map['potonganPajak'] ?? 0).toDouble(),
      totalGajiBruto: (map['totalGajiBruto'] ?? 0).toInt(),
      totalGajiNetto: (map['totalGajiNetto'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'karyawanID': karyawanID,
      'tarifTerID': tarifTerID,
      'tarifProgresifID': tarifProgresifID,
      'periodeBulan': periodeBulan,
      'periodeTahun': periodeTahun,
      'totalJamKerja': totalJamKerja,
      'totalJamLembur': totalJamLembur,
      'ekspektasiGaji': ekspektasiGaji,
      'gajiPokok': gajiPokok,
      'uangMakan': uangMakan,
      'uangLembur': uangLembur,
      'tarifPajak': tarifPajak,
      'potonganPajak': potonganPajak,
      'totalGajiBruto': totalGajiBruto,
      'totalGajiNetto': totalGajiNetto,
    };
  }
}
