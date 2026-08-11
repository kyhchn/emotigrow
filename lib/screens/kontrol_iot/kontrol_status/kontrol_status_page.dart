import 'package:cakmoji_flutter/core/app_colors.dart';
import 'package:flutter/material.dart';

class KontrolStatusPage extends StatefulWidget {
  const KontrolStatusPage({super.key});

  @override
  State<KontrolStatusPage> createState() => _KontrolStatusPageState();
}

class KontrolStatusItem {
  final String name;
  final String place;
  final String asset;
  final String month;

  KontrolStatusItem({
    required this.name,
    required this.place,
    required this.asset,
    required this.month,
  });
}

class _KontrolStatusPageState extends State<KontrolStatusPage> {
  final List<KontrolStatusItem> items = [
    KontrolStatusItem(
      name: 'Selada',
      place: 'Dataran tinggi',
      asset: 'assets/images/selada.png',
      month: '1 bulan',
    ),
    KontrolStatusItem(
      name: 'Pakcoy',
      place: 'Dataran tinggi/rendah',
      asset: 'assets/images/pakcoy.png',
      month: '1 bulan',
    ),
    KontrolStatusItem(
      name: 'Cabai',
      place: 'Lahan terbuka',
      asset: 'assets/images/cabai.png',
      month: '2 bulan',
    ),
    KontrolStatusItem(
      name: 'Tomat',
      place: 'Dataran tinggi',
      asset: 'assets/images/tomat.png',
      month: '1 bulan',
    ),
    KontrolStatusItem(
      name: 'Kangkung',
      place: 'Dataran tinggi/rendah',
      asset: 'assets/images/kangkung.png',
      month: '3 bulan',
    ),
    KontrolStatusItem(
      name: 'Bayam',
      place: 'Dataran tinggi',
      asset: 'assets/images/bayam.png',
      month: '2 bulan',
    ),

    //tomat
    //kangkung
    //bayam
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Appbar with only ios back button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF097004)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          //generate for 20 items
          children: List.generate(
            items.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: controlStatusCard(context, items[index % items.length]),
            ),
          ),
        ),
      ),
    );
  }

  Container controlStatusCard(BuildContext context, KontrolStatusItem item) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF097004).withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF097004).withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Image.asset(
            item.asset,
            height: MediaQuery.of(context).size.height * 0.1,
            // aspect ratio 1:1
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.lightbulb_outline,
              size: 90,
              color: Color(0xFF097004),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  item.place,
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.month,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Show a dialog to confirm the action
                        // showDialog(
                        //   context: context,
                        //   builder: (context) => AlertDialog(
                        //     title: Text('Matikan Lampu?'),
                        //     content: Text(
                        //       'Apakah Anda yakin ingin mematikan lampu?',
                        //     ),
                        //     actions: [
                        //       TextButton(
                        //         onPressed: () => Navigator.of(context).pop(),
                        //         child: Text('Batal'),
                        //       ),
                        //       ElevatedButton(
                        //         onPressed: () {
                        //           // Close the dialog
                        //           Navigator.of(context).pop();
                        //           // Show a snackbar to confirm the action
                        //           ScaffoldMessenger.of(context).showSnackBar(
                        //             SnackBar(content: Text('Lampu dimatikan.')),
                        //           );
                        //         },
                        //         child: Text('Ya'),
                        //       ),
                        //     ],
                        //   ),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        // border radius 12
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Pilih',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
