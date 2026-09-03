import 'package:flutter/material.dart';
import '../models/product.dart';
import 'usage_card.dart';
import 'info_box.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  Text(
                    product.mobileNumber,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          // Usage data cards
          ...product.usageData.map((usage) {
            return UsageCard(usage: usage);
          }).toList(),
          SizedBox(height: 16),
          // Extra info
          if (product.outsideBundleCosts != null)
            InfoBox(text: product.outsideBundleCosts!),
          if (product.updateDate != null)
            InfoBox(text: product.updateDate!),
        ],
      ),
    );
  }
}
