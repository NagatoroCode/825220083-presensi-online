import 'package:aplikasiabsensi/model/jenisStatus.dart';

class Checkout {
  String? checkoutID;
  String? userID;
  String? statusID;
  String tanggalKeluar;
  String waktuKeluar;
  String lokasiKeluar;
  String fotoKeluar;
  String deskripsi;
  jenisStatus? status;

  Checkout({
    this.checkoutID,
    this.userID,
    this.statusID,
    required this.tanggalKeluar,
    required this.waktuKeluar,
    required this.lokasiKeluar,
    required this.fotoKeluar,
    required this.deskripsi,
    this.status,
  });

  factory Checkout.fromMap(Map<String, dynamic> map) {
    return Checkout(
      checkoutID: map['checkoutID'] as String?,
      userID: map['userID'] as String?,
      statusID: map['statusID'] as String?,
      tanggalKeluar: map['tanggalKeluar'] ?? '',
      waktuKeluar: map['waktuKeluar'] ?? '',
      lokasiKeluar: map['lokasiKeluar'] ?? '',
      fotoKeluar: map['fotoKeluar'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      status: map['jenisStatus'] != null
          ? jenisStatus.fromMap(map['jenisStatus'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'statusID': statusID,
      'tanggalKeluar': tanggalKeluar,
      'waktuKeluar': waktuKeluar,
      'lokasiKeluar': lokasiKeluar,
      'fotoKeluar': fotoKeluar,
      'deskripsi': deskripsi,
    };
  }

  factory Checkout.empty() {
    return Checkout(
      checkoutID: null,
      userID: null,
      statusID: null,
      tanggalKeluar: '',
      waktuKeluar: '',
      lokasiKeluar: '',
      fotoKeluar: '',
      deskripsi: '',
      status: null,
    );
  }
}
