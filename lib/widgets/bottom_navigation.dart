import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/pages/Karyawan/CICO/CICO_page.dart';
import 'package:aplikasiabsensi/pages/Karyawan/Profile/profileKaryawan_page.dart';
import 'package:aplikasiabsensi/pages/Owner/Laporan%20Harian/laporanHarianOwner_page.dart';
import 'package:aplikasiabsensi/pages/Owner/Pengaturan/pengaturan_page.dart';
import 'package:aplikasiabsensi/pages/Owner/Profile/profileOwner.dart';
import 'package:aplikasiabsensi/pages/Owner/Izin%20Cuti/approvalCutiOwner_page.dart';
import 'package:aplikasiabsensi/pages/Owner/Izin%20Kerja/approvalIzinOwner_page.dart';
import 'package:aplikasiabsensi/widgets/Tool%20Tip%20Izin/izinKaryawan.dart';
import 'package:aplikasiabsensi/widgets/Tool%20Tip%20Laporan/laporanKaryawan.dart';
import 'package:aplikasiabsensi/widgets/Tool%20Tip%20Laporan/laporanOwner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuNavigationBar extends StatelessWidget {
  final String role;
  final dataKaryawan? karyawan;

  MenuNavigationBar({super.key, required this.role, this.karyawan});

  final NavigationController controller = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages;
    final List<NavigationDestination> destinasi;

    if (role == "Owner") {
      pages = [
        LaporanHarianOwnerPage(),
        Container(),
        PengaturanPage(),
        ProfileOwnerPage(),
      ];

      destinasi = [
        NavigationDestination(
          icon: Builder(builder: (context) => const TooltipLaporanOwner()),
          label: 'Laporan',
        ),
        NavigationDestination(
          icon: Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  final RenderBox renderBox =
                      context.findRenderObject() as RenderBox;
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
                      Get.to(() => const ApprovalIzinOwner());
                    } else if (value == 2) {
                      Get.to(() => const ApprovalCutiOwner());
                    }
                  });
                },
                child: const Icon(Icons.calendar_month_rounded),
              );
            },
          ),
          label: 'Izin',
        ),
        const NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Pengaturan',
        ),
        const NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ];
    } else {
      pages = [
        const UserhomePage(),
        Container(),
        Container(),
        ProfileKaryawanPage(karyawan: karyawan),
      ];

      destinasi = [
        const NavigationDestination(icon: Icon(Icons.home), label: 'CICO'),
        NavigationDestination(
          icon: Builder(
            builder: (context) {
              return Tooltipizinkaryawan(userID: karyawan?.userID ?? "-");
            },
          ),
          label: 'Izin',
        ),
        NavigationDestination(
          icon: Builder(
            builder: (context) {
              return TooltipLaporanKaryawan(karyawan: karyawan);
            },
          ),
          label: 'Laporan',
        ),
        const NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ];
    }

    return Obx(
      () => Scaffold(
        body: pages[controller.selectedIndex.value],
        bottomNavigationBar: NavigationBar(
          height: 80.0,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (int index) {
            if (role == "Owner" && (index == 0 || index == 1)) return;
            if (role == "Karyawan" && (index == 1 || index == 2)) return;
            controller.changeIndex(index);
          },
          destinations: destinasi,
        ),
      ),
    );
  }
}

class NavigationController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}
