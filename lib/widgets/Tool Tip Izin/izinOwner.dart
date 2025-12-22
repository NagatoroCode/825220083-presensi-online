import 'package:aplikasiabsensi/pages/Owner/Izin%20Cuti/approvalCutiOwner_page.dart';
import 'package:aplikasiabsensi/pages/Owner/Izin%20Kerja/approvalIzinOwner_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Tooltipizinowner extends StatelessWidget {
  const Tooltipizinowner({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        final Size size = renderBox.size;

        showMenu<int>(
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
                  Icon(Icons.work_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Izin Kerja"),
                ],
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: Row(
                children: [
                  Icon(Icons.beach_access, color: Colors.blue),
                  SizedBox(width: 8),
                  Text("Izin Cuti"),
                ],
              ),
            ),
          ],
        ).then((value) {
          if (value == 1) {
            Get.to(() => ApprovalIzinOwner());
          } else if (value == 2) {
            Get.to(() => ApprovalCutiOwner());
          }
        });
      },
      child: const Icon(Icons.calendar_month_rounded),
    );
  }
}
