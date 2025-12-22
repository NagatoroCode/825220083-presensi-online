import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/pages/Owner/Laporan%20Gaji/laporanGajiOwner_page.dart';
import 'package:aplikasiabsensi/pages/Owner/Laporan%20Harian/laporanHarianOwner_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TooltipLaporanOwner extends StatelessWidget {
  final dataKaryawan? karyawan;

  const TooltipLaporanOwner({super.key, this.karyawan});

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
              Get.to(() => LaporanHarianOwnerPage());
            } else if (selected == 2) {
              Get.to(() => LaporanGajiOwnerPage());
            }
          },
          child: const Icon(Icons.insert_chart_outlined_rounded),
        );
      },
    );
  }
}
