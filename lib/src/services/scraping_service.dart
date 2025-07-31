import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart' as html;

import '../utils/cookie_utils.dart';

class ScrapingService {
  // This method scrapes the given URL and extracts and converts mobile usage data to KB
  static Future<Map<String, dynamic>?> scrapeOverview() async {
    try {
      // Send HTTP request with the session token in the cookie header

      final response = await http.Client().send(
          http.Request('GET', Uri.parse('https://www.digi-belgium.be/en/my-digi/overview'))
            ..headers['Cookie'] = getAllCookies()
            ..followRedirects = false
          );

      if (response.statusCode == 307) {
        return null;
      } else if (response.statusCode != 200) throw new Exception("Status code not 200");

      // Parse the HTML response
      var document = parse(await response.stream.bytesToString());

      // Look for the specific HTML structure containing the mobile data
      final allProducts = document.querySelectorAll('.card-progress');
      List<List<dynamic>> scrapedProducts = [];

      for (html.Element product in allProducts) {
        final type = product.querySelector('h6')?.text ?? '';
        final mobileNumber = product.querySelector('.card-progress-description')?.text ?? '';

        var dataInfo = product.querySelector('.card-progress-title')?.text.split('/') ?? [];

        String used = '0';
        String available = '0 MB'; // default with unit

        if (dataInfo.length == 2) {
          final unit = _extractUnit(dataInfo[1]); // e.g., 'GB'
          used = '${dataInfo[0].trim()} $unit';
          available = dataInfo[1].trim();
        }

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
      return null;
    }
  }

  static String _extractUnit(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('gb')) return 'GB';
    if (lower.contains('mb')) return 'MB';
    if (lower.contains('kb')) return 'KB';
    return 'MB'; // Default fallback
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
