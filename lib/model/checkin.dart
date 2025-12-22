import 'package:aplikasiabsensi/model/jenisStatus.dart';

class Checkin {
  String? checkinID;
  String? userID;
  String? statusID;
  String tanggalMasuk;
  String waktuMasuk;
  String lokasiMasuk;
  double longitudeMasuk;
  double latitudeMasuk;
  String fotoMasuk;
  String deskripsi;
  jenisStatus? status;

  Checkin({
    this.checkinID,
    this.userID,
    this.statusID,
    required this.tanggalMasuk,
    required this.waktuMasuk,
    required this.lokasiMasuk,
    required this.longitudeMasuk,
    required this.latitudeMasuk,
    required this.fotoMasuk,
    required this.deskripsi,
    this.status,
  });

  factory Checkin.empty() {
    return Checkin(
      tanggalMasuk: '',
      waktuMasuk: '',
      lokasiMasuk: '',
      longitudeMasuk: 0.0,
      latitudeMasuk: 0.0,
      fotoMasuk: '',
      deskripsi: '',
    );
  }

  factory Checkin.fromMap(Map<String, dynamic> map) {
    return Checkin(
      checkinID: map['checkinID'] as String?,
      userID: map['userID'] as String?,
      statusID: map['statusID'] as String?,
      tanggalMasuk: map['tanggalMasuk'] ?? '',
      waktuMasuk: map['waktuMasuk'] ?? '',
      lokasiMasuk: map['lokasiMasuk'] ?? '',
      longitudeMasuk: (map['longitudeMasuk'] ?? 0.0).toDouble(),
      latitudeMasuk: (map['latitudeMasuk'] ?? 0.0).toDouble(),
      fotoMasuk: map['fotoMasuk'] ?? '',
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
      'tanggalMasuk': tanggalMasuk,
      'waktuMasuk': waktuMasuk,
      'lokasiMasuk': lokasiMasuk,
      'longitudeMasuk': longitudeMasuk,
      'latitudeMasuk': latitudeMasuk,
      'fotoMasuk': fotoMasuk,
      'deskripsi': deskripsi,
    };
  }
}
