import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ManualAndMenuPage extends StatelessWidget {
  const ManualAndMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // backgroundColor: Colors.transparent,
        title: Text('Cakmoji Guidebook'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Builder(
        builder: (context) {
          final double height = MediaQuery.of(context).size.height;
          return CarouselSlider(
            options: CarouselOptions(
              height: height,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              // autoPlay: false,
            ),
            // loop the email from 1 unttil 15 from the images/carouse/number.png
            items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
                .map(
                  (item) => Center(
                    child: Image.asset(
                      "assets/images/carousel/$item.png",
                      fit: BoxFit.contain,
                      height: height,
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
