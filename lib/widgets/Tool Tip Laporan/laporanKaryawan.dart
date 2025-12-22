import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/pages/Karyawan/Laporan%20Gaji/laporanGajiKaryawan_page.dart';
import 'package:aplikasiabsensi/pages/Karyawan/Laporan%20Harian/laporanHarian_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TooltipLaporanKaryawan extends StatelessWidget {
  final dataKaryawan? karyawan;

  const TooltipLaporanKaryawan({super.key, this.karyawan});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () async {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final Offset offset = renderBox.localToGlobal(Offset.zero);
            final Size size = renderBox.size;

            final selected = await showMenu<int>(
              context: context,
              position: RelativeRect.fromLTRB(
                offset.dx,
                offset.dy - 120,
                offset.dx + size.width,
                offset.dy,
              ),
              items: const [
                PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.article_outlined, color: Colors.green),
                      SizedBox(width: 8),
                      Text("Laporan Harian"),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.attach_money_outlined, color: Colors.purple),
                      SizedBox(width: 8),
                      Text("Laporan Gaji"),
                    ],
                  ),
                ),
              ],
            );

            // Navigasi sesuai pilihan
            if (selected == 1) {
              Get.to(() => LaporanHarianPage(userID: karyawan?.userID ?? ''));
            } else if (selected == 2) {
              Get.to(
                () => LaporanGajiPribadiPage(userID: karyawan?.userID ?? ''),
              );
            }
          },
          child: const Icon(Icons.insert_chart_outlined_rounded),
        );
      },
    );
  }
}
