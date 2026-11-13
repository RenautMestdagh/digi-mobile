import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'digi_client.dart';

class Product {
  const Product({
    required this.name,
    required this.number,
    required this.url,
    this.usage = const [],
    this.notes = const [],
    this.error,
  });

  final String name;
  final String number;
  final Uri url;
  final List<Usage> usage;
  final List<String> notes;

  /// Why the usage of this product could not be loaded.
  final DigiException? error;
}

class Usage {
  const Usage({required this.type, required this.limit, required this.used, this.share});

  final String type;
  final String limit;
  final String used;

  /// The used part of the limit, when both are amounts of data.
  final double? share;
}

/// The products on the my-products page at [page], without their usage.
List<Product> parseProducts(String html, Uri page) => [
  for (final card in parse(html).querySelectorAll('.card-service:not(.add-service)'))
    if (card.querySelector('.card-service-btn')?.attributes['href'] case final href?)
      Product(
        name: _text(card.querySelector('.card-service-title')),
        number: _text(card.querySelector('.card-service-description')),
        url: page.resolve(href),
      ),
];

/// Adds the usage on the product page to [product].
Product parseUsage(Product product, String html) {
  final document = parse(html);

  return Product(
    name: product.name,
    number: product.number,
    url: product.url,
    usage: [for (final card in document.querySelectorAll('.card-progress')) _usage(card)],
    notes: [
      for (final box in document.querySelectorAll('.info-box.primary'))
        if (box.querySelector('a') == null)
          for (final paragraph in box.querySelectorAll('.info-box-message p')) _text(paragraph),
    ],
  );
}

Usage _usage(Element card) {
  final limit = card.querySelector('.card-progress-description')?.clone(true);
  limit?.querySelectorAll('.tooltip-element').forEach((tooltip) => tooltip.remove());
  final title = _text(card.querySelector('.card-progress-title'));
  final used = title.substring(title.lastIndexOf(': ') + 1).trim();
  final limitKb = _kilobytes(_text(limit));
  final usedKb = _kilobytes(used);

  return Usage(
    type: _text(card.querySelector('h6')),
    limit: _text(limit),
    used: used,
    share: limitKb != null && usedKb != null && limitKb > 0 ? usedKb / limitKb : null,
  );
}

double? _kilobytes(String amount) {
  final match = RegExp(r'^([\d.,]+)\s*([KMG])B$', caseSensitive: false).firstMatch(amount);
  final value = double.tryParse(match?[1]?.replaceAll(',', '.') ?? '');
  if (match == null || value == null) return null;

  return value *
      switch (match[2]!.toUpperCase()) {
        'G' => 1024 * 1024,
        'M' => 1024,
        _ => 1,
      };
}

/// The text of [element] with its line breaks and without the whitespace of the markup.
String _text(Element? element) => (element?.nodes ?? <Node>[])
    .map((node) => node is Element && node.localName == 'br' ? '\n' : node.text ?? '')
    .join()
    .split('\n')
    .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
    .join('\n')
    .trim();
