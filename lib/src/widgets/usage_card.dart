import 'package:flutter/material.dart';
import '../models/usage_data.dart';

class UsageCard extends StatelessWidget {
  final UsageData usage;

  const UsageCard({
    super.key,
    required this.usage,
  });

  Color _getColorForPercentage(double pct) {
    if (pct < 0.75) return Colors.green;
    if (pct < 0.85) return Colors.yellow.shade600;
    if (pct < 0.95) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final clampedPercentage = usage.percentage.clamp(0.0, 1.0);
    final color = _getColorForPercentage(clampedPercentage);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color.fromRGBO(243, 245, 247, 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usage.type,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      usage.limit,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Text(
                  usage.used,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
          if (usage.progressBar)
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: FractionallySizedBox(
                widthFactor: clampedPercentage,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(clampedPercentage == 1.0 ? 12 : 0),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
