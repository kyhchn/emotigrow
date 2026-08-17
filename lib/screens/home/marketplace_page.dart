import 'package:flutter/material.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class MarketplaceItem {
  final String name;
  final String location;
  final String price;
  final String imageAsset;

  MarketplaceItem({
    required this.name,
    required this.location,
    required this.price,
    required this.imageAsset,
  });
}

class _MarketplacePageState extends State<MarketplacePage> {
  final List<MarketplaceItem> items = [
    MarketplaceItem(
      name: 'Selada Keriting',
      location: 'Kab. Sidoarjo',
      price: 'Rp 5.000 / kg',
      imageAsset: 'assets/images/selada_keriting.png',
    ),
    MarketplaceItem(
      name: 'Alat Monitoring Hidroponik Emotigrow',
      location: 'Karanganyar',
      price: 'Rp 1.380.000',
      imageAsset: 'assets/images/alat_hidroponik.png',
    ),
    MarketplaceItem(
      name: 'Insektisida Teballo 250SL ',
      location: 'Karanganyar',
      price: 'Rp 75.000 / kg',
      imageAsset: 'assets/images/teballo.png',
    ),
    MarketplaceItem(
      name: 'pH Buffer ACR 1 Set 250ml',
      location: 'Surabaya',
      price: 'Rp 50.000 / kg',
      imageAsset: 'assets/images/ph_buffer.png',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: List.generate(
            items.length,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 16, top: index == 0 ? 16 : 0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF097004).withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: MediaQuery.of(context).size.width * 0.2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(items[index].imageAsset),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[index].name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.black,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                items[index].location,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            items[index].price,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.55),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.construction_rounded,
                      size: 48,
                      color: const Color(0xFF097004),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Work in Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This page is currently under development. '
                      'Please check back later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
