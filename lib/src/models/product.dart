import 'usage_data.dart';

class Product {
  final String title;
  final String mobileNumber;
  final String productUrl;
  final List<UsageData> usageData;
  final String? outsideBundleCosts;
  final String? updateDate;

  Product({
    required this.title,
    required this.mobileNumber,
    required this.productUrl,
    required this.usageData,
    this.outsideBundleCosts,
    this.updateDate,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final List<dynamic> usageDataJson = json['usageData'] ?? [];
    final List<UsageData> usageDataList = usageDataJson
        .map((item) => UsageData.fromJson(item as Map<String, dynamic>))
        .toList();

    return Product(
      title: json['title'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      productUrl: json['productUrl'] ?? '',
      usageData: usageDataList,
      outsideBundleCosts: json['outsideBundleCosts'],
      updateDate: json['updateDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'mobileNumber': mobileNumber,
      'productUrl': productUrl,
      'usageData': usageData.map((item) => item.toJson()).toList(),
      'outsideBundleCosts': outsideBundleCosts,
      'updateDate': updateDate,
    };
  }
}
