-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.AbsensiCheckIn (
  checkinID uuid NOT NULL DEFAULT gen_random_uuid(),
  userID uuid DEFAULT auth.uid(),
  waktuMasuk time without time zone DEFAULT now(),
  lokasiMasuk text,
  fotoMasuk text,
  deskripsi text,
  statusID uuid NOT NULL,
  tanggalMasuk date,
  longitudeMasuk double precision,
  latitudeMasuk double precision,
  CONSTRAINT AbsensiCheckIn_pkey PRIMARY KEY (checkinID),
  CONSTRAINT AbsensicheckIn_userID_fkey FOREIGN KEY (userID) REFERENCES public.User(userID),
  CONSTRAINT AbsensiCheckIn_statusID_fkey FOREIGN KEY (statusID) REFERENCES public.jenisStatus(statusID)
);
CREATE TABLE public.AbsensiCheckOut (
  checkoutID uuid NOT NULL DEFAULT gen_random_uuid(),
  userID uuid DEFAULT auth.uid(),
  waktuKeluar time without time zone,
  lokasiKeluar text,
  fotoKeluar text,
  deskripsi text,
  statusID uuid NOT NULL,
  tanggalKeluar date,
  CONSTRAINT AbsensiCheckOut_pkey PRIMARY KEY (checkoutID),
  CONSTRAINT AbsensiCheckOut_userID_fkey FOREIGN KEY (userID) REFERENCES public.User(userID),
  CONSTRAINT AbsensiCheckOut_statusID_fkey FOREIGN KEY (statusID) REFERENCES public.jenisStatus(statusID)
);
CREATE TABLE public.User (
  userID uuid NOT NULL DEFAULT gen_random_uuid(),
  email character varying DEFAULT '120'::character varying,
  password character varying DEFAULT '30'::character varying,
  roleID uuid NOT NULL,
  CONSTRAINT User_pkey PRIMARY KEY (userID),
  CONSTRAINT User_roleID_fkey FOREIGN KEY (roleID) REFERENCES public.roleUser(roleID)
);
CREATE TABLE public.dataKaryawan (
  karyawanID uuid NOT NULL DEFAULT gen_random_uuid(),
  userID uuid,
  jabatanID uuid,
  ptkpID uuid,
  namaLengkap text,
  gajiPokok integer,
  uangMakan integer,
  nomorTelepon character varying DEFAULT '14'::character varying,
  alamat text,
  tanggalMasuk timestamp with time zone DEFAULT now(),
  fotoProfil text,
  status character varying DEFAULT '50'::character varying,
  CONSTRAINT dataKaryawan_pkey PRIMARY KEY (karyawanID),
  CONSTRAINT dataKaryawan_userID_fkey FOREIGN KEY (userID) REFERENCES public.User(userID),
  CONSTRAINT dataKaryawan_jabatanID_fkey FOREIGN KEY (jabatanID) REFERENCES public.jenisJabatan(jabatanID),
  CONSTRAINT dataKaryawan_ptkpID_fkey FOREIGN KEY (ptkpID) REFERENCES public.jenisPTKP(ptkpID)
);
CREATE TABLE public.historyGaji (
  gajiID uuid NOT NULL DEFAULT gen_random_uuid(),
  karyawanID uuid DEFAULT gen_random_uuid(),
  tarifTerID uuid DEFAULT gen_random_uuid(),
  tarifProgresifID uuid DEFAULT gen_random_uuid(),
  periodeBulan character varying,
  periodeTahun character varying,
  ekspektasiGaji bigint,
  gajiPokok bigint,
  uangMakan bigint,
  uangLembur bigint,
  tarifPajak real,
  potonganPajak double precision,
  totalGajiBruto bigint,
  totalGajiNetto bigint,
  totalJamKerja text,
  totalJamLembur text,
  CONSTRAINT historyGaji_pkey PRIMARY KEY (gajiID),
  CONSTRAINT historyGaji_tarifProgresifID_fkey FOREIGN KEY (tarifProgresifID) REFERENCES public.tarifProgresif(tarifProgresifID),
  CONSTRAINT historyGaji_tarifTerID_fkey FOREIGN KEY (tarifTerID) REFERENCES public.tarifTER(tarifTerID),
  CONSTRAINT historyGaji_karyawanID_fkey FOREIGN KEY (karyawanID) REFERENCES public.dataKaryawan(karyawanID)
);
CREATE TABLE public.jenisCuti (
  jenisCutiID uuid NOT NULL DEFAULT gen_random_uuid(),
  namaCuti text,
  CONSTRAINT jenisCuti_pkey PRIMARY KEY (jenisCutiID)
);
CREATE TABLE public.jenisJabatan (
  jabatanID uuid NOT NULL DEFAULT gen_random_uuid(),
  namaJabatan text,
  CONSTRAINT jenisJabatan_pkey PRIMARY KEY (jabatanID)
);
CREATE TABLE public.jenisPTKP (
  ptkpID uuid NOT NULL DEFAULT gen_random_uuid(),
  namaGolongan character varying DEFAULT '5'::character varying,
  deskripsi text,
  nilaiPTKP integer,
  CONSTRAINT jenisPTKP_pkey PRIMARY KEY (ptkpID)
);
CREATE TABLE public.jenisStatus (
  statusID uuid NOT NULL DEFAULT gen_random_uuid(),
  namaStatus text NOT NULL,
  CONSTRAINT jenisStatus_pkey PRIMARY KEY (statusID)
);
CREATE TABLE public.pengajuanCuti (
  cutiID uuid NOT NULL DEFAULT gen_random_uuid(),
  userID uuid DEFAULT auth.uid(),
  jenisCutiID uuid,
  tanggalMulai date NOT NULL,
  tanggalSelesai date NOT NULL,
  alasanCuti text,
  tanggalPengajuan timestamp without time zone NOT NULL DEFAULT now(),
  statusPengajuan text NOT NULL,
  tanggalVerifikasi timestamp without time zone,
  CONSTRAINT pengajuanCuti_pkey PRIMARY KEY (cutiID),
  CONSTRAINT pengajuanCuti_jenisCutiID_fkey FOREIGN KEY (jenisCutiID) REFERENCES public.jenisCuti(jenisCutiID),
  CONSTRAINT pengajuanCuti_userID_fkey FOREIGN KEY (userID) REFERENCES public.User(userID)
);
CREATE TABLE public.pengajuanIzin (
  izinID uuid NOT NULL DEFAULT gen_random_uuid(),
  userID uuid DEFAULT auth.uid(),
  statusID uuid,
  waktuMulai time without time zone,
  waktuSelesai time without time zone,
  tanggalIzin date,
  alasanIzin text,
  tanggalPengajuan timestamp without time zone NOT NULL DEFAULT now(),
  statusPengajuan text,
  tanggalVerifikasi timestamp without time zone,
  CONSTRAINT pengajuanIzin_pkey PRIMARY KEY (izinID),
  CONSTRAINT pengajuanIzin_userID_fkey FOREIGN KEY (userID) REFERENCES public.User(userID),
  CONSTRAINT pengajuanIzin_statusID_fkey FOREIGN KEY (statusID) REFERENCES public.jenisStatus(statusID)
);
CREATE TABLE public.rangeLocation (
  rangeID uuid NOT NULL DEFAULT gen_random_uuid(),
  checkinID uuid,
  longitude_realtime double precision,
  latitude_realtime double precision,
  tanggalDibuat timestamp without time zone NOT NULL DEFAULT now(),
  alamat_realtime text,
  jarak_radius real,
  CONSTRAINT rangeLocation_pkey PRIMARY KEY (rangeID),
  CONSTRAINT rangeLocation_checkinID_fkey FOREIGN KEY (checkinID) REFERENCES public.AbsensiCheckIn(checkinID)
);
CREATE TABLE public.roleUser (
  roleID uuid NOT NULL DEFAULT gen_random_uuid(),
  namaRole text NOT NULL,
  CONSTRAINT roleUser_pkey PRIMARY KEY (roleID)
);
CREATE TABLE public.tarifProgresif (
  tarifProgresifID uuid NOT NULL DEFAULT gen_random_uuid(),
  penghasilanMinimal bigint,
  penghasilanMaksimal bigint,
  tarifPajak real,
  CONSTRAINT tarifProgresif_pkey PRIMARY KEY (tarifProgresifID)
);
CREATE TABLE public.tarifTER (
  tarifTerID uuid NOT NULL DEFAULT gen_random_uuid(),
  ptkpID uuid,
  penghasilanMinimal integer,
  penghasilanMaksimal integer,
  tarifPajak real,
  CONSTRAINT tarifTER_pkey PRIMARY KEY (tarifTerID),
  CONSTRAINT tarifTER_ptkpID_fkey FOREIGN KEY (ptkpID) REFERENCES public.jenisPTKP(ptkpID)
);