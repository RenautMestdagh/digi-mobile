import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the cookies Digi sets per host and path, like a browser, in the device's encrypted storage.
class CookieJar {
  CookieJar._(this._storage, this._cookies);

  static const _key = 'cookies';

  static Future<CookieJar> open([FlutterSecureStorage storage = const FlutterSecureStorage()]) async {
    final saved = await storage.read(key: _key);
    final cookies = [
      if (saved != null)
        for (final json in jsonDecode(saved) as List<dynamic>) _Cookie.fromJson(json as Map<String, dynamic>),
    ];

    return CookieJar._(storage, cookies);
  }

  final FlutterSecureStorage _storage;
  final List<_Cookie> _cookies;

  bool has(String name) => _cookies.any((cookie) => cookie.name == name && !cookie.expired);

  /// The Cookie header for a request to [url], or null when no cookie applies.
  String? header(Uri url) {
    final cookies = _cookies.where((cookie) => cookie.appliesTo(url));

    return cookies.isEmpty ? null : cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }

  /// Stores the Set-Cookie headers of a response to [url].
  Future<void> save(Uri url, List<String> setCookies) async {
    if (setCookies.isEmpty) return;

    for (final header in setCookies) {
      final Cookie parsed;
      try {
        parsed = Cookie.fromSetCookieValue(header);
      } on FormatException {
        continue;
      }

      final cookie = _Cookie.from(parsed, url);
      if (cookie == null) continue;

      _cookies.removeWhere((other) => other.sameAs(cookie));
      if (!cookie.expired) _cookies.add(cookie);
    }

    _cookies.removeWhere((cookie) => cookie.expired);
    await _storage.write(key: _key, value: jsonEncode(_cookies));
  }

  Future<void> clear() async {
    _cookies.clear();
    await _storage.delete(key: _key);
  }
}

class _Cookie {
  _Cookie({
    required this.name,
    required this.value,
    required this.domain,
    required this.hostOnly,
    required this.path,
    required this.secure,
    this.expires,
  });

  factory _Cookie.fromJson(Map<String, dynamic> json) => _Cookie(
    name: json['name'] as String,
    value: json['value'] as String,
    domain: json['domain'] as String,
    hostOnly: json['hostOnly'] as bool,
    path: json['path'] as String,
    secure: json['secure'] as bool,
    expires: switch (json['expires']) {
      final String expires => DateTime.parse(expires),
      _ => null,
    },
  );

  /// Null when [url] may not set the cookie, because its Domain is not the host or a parent of it.
  static _Cookie? from(Cookie cookie, Uri url) {
    final domain = cookie.domain?.toLowerCase().replaceFirst(RegExp(r'^\.'), '');
    if (domain != null && !_domainMatches(url.host, domain)) return null;

    final directory = url.path.substring(0, url.path.lastIndexOf('/') + 1);

    return _Cookie(
      name: cookie.name,
      value: cookie.value,
      domain: domain ?? url.host,
      hostOnly: domain == null,
      path: cookie.path ?? (directory.length > 1 ? directory.substring(0, directory.length - 1) : '/'),
      secure: cookie.secure,
      expires: switch (cookie.maxAge) {
        final int maxAge => DateTime.now().add(Duration(seconds: maxAge)),
        null => cookie.expires,
      },
    );
  }

  static bool _domainMatches(String host, String domain) => host == domain || host.endsWith('.$domain');

  final String name;
  final String value;
  final String domain;
  final bool hostOnly;
  final String path;
  final bool secure;
  final DateTime? expires;

  bool get expired => expires?.isBefore(DateTime.now()) ?? false;

  bool sameAs(_Cookie other) => name == other.name && domain == other.domain && path == other.path;

  bool appliesTo(Uri url) =>
      !expired &&
      (hostOnly ? url.host == domain : _domainMatches(url.host, domain)) &&
      (url.path == path || url.path.startsWith(path.endsWith('/') ? path : '$path/')) &&
      (!secure || url.scheme == 'https');

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'domain': domain,
    'hostOnly': hostOnly,
    'path': path,
    'secure': secure,
    'expires': expires?.toIso8601String(),
  };
}
