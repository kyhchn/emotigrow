import 'package:cakmoji_flutter/core/app_colors.dart';
import 'package:flutter/material.dart';

class KontrolStatusPage extends StatefulWidget {
  const KontrolStatusPage({super.key});

  @override
  State<KontrolStatusPage> createState() => _KontrolStatusPageState();
}

class _KontrolStatusPageState extends State<KontrolStatusPage> {
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
            20,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: controlStatusCard(context),
            ),
          ),
        ),
      ),
    );
  }

  Container controlStatusCard(BuildContext context) {
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
            'assets/images/lamp.png',
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
                  'Lampu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Dataran tinggi',
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
                        '1 bulan',
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
