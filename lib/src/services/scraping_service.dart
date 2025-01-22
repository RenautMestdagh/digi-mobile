import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart' as html;

import '../utils/cookie_utils.dart';

class ScrapingService {
  // This method scrapes the given URL and extracts and converts mobile usage data to KB
  static Future<Map<String, dynamic>?> scrapeOverview() async {
    try {
      // Send HTTP request with the session token in the cookie header
      final response = await http.get(
        Uri.parse("https://www.digi-belgium.be/en/my-digi/overview"),
        headers: {
          'Cookie': getAllCookies(),
        },
      );

      if (response.statusCode != 200) throw new Exception("Status code not 200");

      // Parse the HTML response
      var document = parse(response.body);

      // Look for the specific HTML structure containing the mobile data
      final allProducts = document.querySelectorAll('.card-progress');
      List<List<dynamic>> scrapedProducts = [];

      for (html.Element product in allProducts) {
        final type = product.querySelector('h6')?.text ?? '';
        final mobileNumber = product.querySelector('p')?.text ?? '';

        final dataInfo = product.querySelectorAll('.card-progress-title span');

        final used = dataInfo.isNotEmpty && dataInfo[0].text.isNotEmpty ? dataInfo[0].text : '0 MB';
        final available = dataInfo.length > 2 && dataInfo[2].text.isNotEmpty ? dataInfo[2].text : '15 GB';


        final usedKb = _convertToKB(used);
        final availableKb = _convertToKB(available);

        scrapedProducts.add([
          type,
          mobileNumber,
          usedKb,
          availableKb,
        ]);
      }

      String? usageInfo = document.querySelector('.info-box-message p')?.text;

      // Return the result as a Map with key "products"
      return {
        'products': scrapedProducts,
        'usageInfo': usageInfo,
      };
    } catch (e) {
      // Handle errors, e.g., network issues
      print("Error during scraping: $e");
      rethrow;
    }
  }


  // Helper method to convert MB/GB to KB
  static int _convertToKB(String value) {
    double numericValue = double.parse(value.split(' ')[0]);
    if (value.contains('MB')) {
      return (numericValue * 1000).toInt(); // Convert MB to KB
    } else if (value.contains('GB')) {
      return (numericValue * 1000000).toInt(); // Convert GB to KB
    } else {
      throw FormatException("Unsupported unit in $value");
    }
  }
}
