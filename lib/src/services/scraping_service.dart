import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart' as html;

import '../utils/cookie_utils.dart';
import '../models/product.dart';
import '../models/usage_data.dart';

class ScrapingService {
  static final baseUrl = Uri.parse('https://www.digi-belgium.be/en/my-digi/');

  static Future<List<Product>?> scrapeProducts() async {
    try {

      final response = await http.Client().send(
          http.Request('GET', baseUrl.resolve('my-products'))
            ..headers['Cookie'] = getAllCookies()
            ..followRedirects = false
          );

      if (response.statusCode == 307) {
        return null;
      } else if (response.statusCode != 200) throw new Exception("Status code not 200");

      var document = parse(await response.stream.bytesToString());

      final allServices = document.querySelectorAll('.card-service:not(.add-service)');
      List<Product> scrapedServices = [];

      for (html.Element product in allServices) {
        final title = product.querySelector('.card-service-title')?.text ?? '';
        final mobileNumber = product.querySelector('.card-service-description')?.text ?? '';
        final productUrl = product.querySelector('.card-service-btn')?.attributes['href'] ?? '';

        scrapedServices.add(Product(
          title: title,
          mobileNumber: mobileNumber,
          productUrl: productUrl,
          usageData: [],
        ));
      }

      return scrapedServices;
    } catch (e) {
      print("Error during scraping: $e");
      return null;
    }
  }

  static Future<Product?> scrapeProduct(Product product) async {
    try {
      final response = await http.Client().send(
          http.Request('GET', baseUrl.resolve(product.productUrl))
            ..headers['Cookie'] = getAllCookies()
            ..followRedirects = false
      );

      if (response.statusCode != 200) throw new Exception("Status code not 200");

      // Parse the HTML response
      var document = parse(await response.stream.bytesToString());

      // Extract all 4 card-progress elements
      final progressCards = document.querySelectorAll('.card-progress');
      List<UsageData> usageData = [];

      for (html.Element card in progressCards) {
        final type = card.querySelector('h6')?.text ?? '';
        final limitElement = card.querySelector('.card-progress-description');
        String limit = '';
        if (limitElement != null) {
          final clonedElement = limitElement.clone(true);
          clonedElement.querySelectorAll('.tooltip-element').forEach((e) => e.remove());
          limit = clonedElement.text.trim();
        }
        final usedText = card.querySelector('.card-progress-title')?.text ?? '';
        final usedTextClean = usedText.replaceAll(' SMS', '');
        final used = usedTextClean.contains(': ') ? usedTextClean.split(': ')[1] : usedTextClean;

        final showProgressBar = limit.contains(' GB');
        double percentage = 0.0;
        if (showProgressBar) {
          final limitKB = _convertToKB(limit);
          final usedKB = _convertToKB(used);
          if (limitKB > 0) {
            percentage = usedKB / limitKB;
          }
        }

        usageData.add(UsageData(
          type: type,
          limit: limit,
          used: used,
          progressBar: showProgressBar,
          percentage: percentage,
        ));
      }

      // Extract extra info (outside bundle costs, update date)
      final infoBoxes = document.querySelectorAll('.info-box.primary .info-box-message p');
      String? outsideBundleCosts;
      String? updateDate;

      if (infoBoxes.length >= 2) {
        outsideBundleCosts = infoBoxes[0].innerHtml.replaceAll('<br>', '\n');
        updateDate = infoBoxes[1].innerHtml.replaceAll('<br>', '\n');
      }

      return Product(
        title: product.title,
        mobileNumber: product.mobileNumber,
        productUrl: product.productUrl,
        usageData: usageData,
        outsideBundleCosts: outsideBundleCosts,
        updateDate: updateDate,
      );

    } catch (e) {
      // Handle errors, e.g., network issues
      print("Error during scraping: $e");
      return null;
    }
  }

  // Helper method to convert MB/GB to KB
  static int _convertToKB(String data) {
    try {
      if (data.toLowerCase().contains('gb')) {
        final value = double.tryParse(data.replaceAll('GB', '').trim()) ?? 0;
        return (value * 1024 * 1024).toInt(); // Convert GB to KB
      } else if (data.toLowerCase().contains('mb')) {
        final value = double.tryParse(data.replaceAll('MB', '').trim()) ?? 0;
        return (value * 1024).toInt(); // Convert MB to KB
      } else if (data.toLowerCase().contains('kb')) {
        final value = double.tryParse(data.replaceAll('KB', '').trim()) ?? 0;
        return value.toInt();
      } else {
        return 0; // Default to 0 if the format is unknown
      }
    } catch (e) {
      print("Error converting data to KB: $e");
      return 0;
    }
  }
}
