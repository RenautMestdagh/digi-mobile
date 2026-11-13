import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'cookie_jar.dart';
import 'login_actions.dart';
import 'products.dart';

sealed class DigiException implements Exception {}

/// Digi no longer accepts the session, so the user has to log in again.
class SessionExpired extends DigiException {}

/// Digi could not be reached.
class NetworkFailure extends DigiException {}

/// Digi refused what the user entered: a wrong password, a wrong code or an unknown email address.
class Rejected extends DigiException {}

/// Digi answered something the app doesn't understand, most likely because the site changed.
class UnexpectedResponse extends DigiException {
  UnexpectedResponse(this.reason);

  final String reason;

  @override
  String toString() => 'UnexpectedResponse: $reason';
}

/// What Digi needs to finish a login with the code it emailed.
class LoginChallenge {
  const LoginChallenge._(this._login, this._confirmAction, this._language);

  final Map<String, dynamic> _login;
  final String _confirmAction;
  final String _language;
}

/// Talks to Digi's website as the logged in user, keeping the session in a [CookieJar].
class DigiClient {
  DigiClient(this._http, this._jar);

  static final _site = Uri.https('www.digi-belgium.be', '/');
  static final _api = Uri.https('api.digi-belgium.be', '/v1/');
  static const _sessionCookie = '__Secure-authjs.session-token';

  /// The error messages Digi's login form hands to its actions, which validate the fields with them.
  static const _formErrors = {
    'email': {'required': 'This field is required', 'valid': 'This field is not valid'},
    'password': 'Password must contain at least 6 characters',
    'code': 'Code must contain 6 characters',
  };

  // Digi's own form sends a fresh reCAPTCHA token, but the app has logged in with this one, captured in January 2025,
  // ever since: Digi doesn't check it with Google. Once Digi does, logging in from the app stops working.
  static const _recaptchaToken =
      '03AFcWeA6E5QuknPqLy7Nx7ZBCrG0to7wWYi_aP852XxWxy_LBoLYj_Xli5bTXzgbxUU8LhnOd-OvYeJkwQT57wzS704Dcpj-urvwouNF5Z_MDa2oeRDOBNRuXpurtLjL-hjGwiOkJ1Yv-a9QVW3Vh3W0KkBDIMd_4T4Va3fpA9KvWkDXIEW83iveCbrowsphhfD3PhwYD6sOmnWYW13rgZMLLSe3ttOO306wu896OD_KRvNTvrBLNwMFxNYIlFomDxzlhXdx8aG-mpYP0QBJ16MRAblMkViC-MYsUNQmB1TnTxx3_4fhgA-9gwYzFfTiZpo63vBFIJkX_BgHgky_vI_B9zQg1CjZ2ujHEoy9xJaidWo4dDNmVxNHTecnwtR3uT6sVQL74JijX4A_8nolNjYHVadsK9TDP6cvR-bC6X1kKdQ_3kF2xCvJduW7xEgSDtTILz6cWEjJ6MRd99Ion1tg2MSecxu70S4B2G4gL5gzGHwdRuD2Mgb5ROoJ8yN3wSTU8OuBokqGvsqvPXyeZjXs26Jxk99RrZJ7EQ824sqsWBw7Nfp_s9qVCEv2WY2xpBVg1nZP0wH9I1VVKVNpyhLkZ9Sb8fR6kPtbZm0Mjj4YfqfDtzKFLnzmiM0SujWiTLLTZ346Gm6kAcG4jdpYIaNKa7nFjj3XYssaBTfL5QSNOcd8W2M7vwV5kgafzJCv4m5Ey1z-7RpcI94FiiwKhxYTr2jDZ1rMGRibotaddXyknVPqw1xwbFvIMfzEzHspc2XlMiqbP-peC_diV_8AvillDktWtenrQw2Pi36j3rJJHMBfQ0TzX3-FctebL7Q7sLsB-kOGshY6AKLLZJkj4Gx8OGlbBqalmFGt-wzdDFFTAIUk7vzEu1gkvd0H6YAntL4Kb5-B6w-Lo6XCZWk_Cg5wBceS9klYohA';

  final http.Client _http;
  final CookieJar _jar;

  // Auth.js splits a session cookie that grows too large into name.0, name.1 and so on.
  bool get signedIn => _jar.has(_sessionCookie) || _jar.has('$_sessionCookie.0');

  /// Checks the email and password, after which Digi emails a code to finish the login with [confirm].
  Future<LoginChallenge> logIn(String email, String password, {required String language}) async {
    await _jar.clear();
    await _send(http.Request('GET', _site.resolve('api/auth/csrf')));
    final actions = await _loginActions();

    final login = await _callAction(actions.logIn, {
      '1_email': email,
      '1_password': password,
      '0': jsonEncode([
        {'errors': <String, dynamic>{}},
        r'$K1',
        _formErrors,
        _uuid(),
        _recaptchaToken,
      ]),
    });
    if (login['access_token'] is! String) throw Rejected();

    final sent = await _send(
      http.Request('POST', _api.resolve('oauth2/send_code'))
        ..headers.addAll({'Authorization': 'Bearer ${login['access_token']}', 'Content-Type': 'application/json'})
        ..body = jsonEncode({'lang': language}),
    );
    if (sent.statusCode != 200) throw UnexpectedResponse('Sending the code answered ${sent.statusCode}');

    return LoginChallenge._(login, actions.confirm, language);
  }

  Future<void> confirm(LoginChallenge challenge, String code) async {
    await _callAction(challenge._confirmAction, {
      '1_code': code,
      '0': jsonEncode([
        {'errors': <String, dynamic>{}},
        r'$K1',
        _formErrors,
        {'show': true, 'data': challenge._login},
        challenge._language,
      ]),
    });
    if (!signedIn) throw Rejected();
  }

  Future<void> requestPasswordReset(String email, {required String language}) async {
    final response = await _send(
      http.Request('POST', _api.resolve('auth/lost-password'))
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode({'lang': language, 'email': email}),
    );
    if (response.statusCode >= 500) throw UnexpectedResponse('Resetting the password answered ${response.statusCode}');

    final refused = switch (_decode(_body(response))) {
      {'meta': {'status': {'error': true}}} || {'status': {'error': true}} => true,
      _ => response.statusCode != 200,
    };
    if (refused) throw Rejected();
  }

  /// The products of the user with their usage, in [language] like Digi's site shows them.
  ///
  /// A product whose usage could not be loaded carries the [Product.error].
  Future<List<Product>> products({required String language}) async {
    final session = await _send(http.Request('GET', _site.resolve('api/auth/session')));
    if (session.statusCode == 200 && _body(session).trim() == 'null') await _expire();

    final page = _site.resolve('$language/my-digi/my-products');
    final products = parseProducts(await _page(page), page);

    return Future.wait(products.map(_withUsage));
  }

  Future<Product> _withUsage(Product product) async {
    try {
      return parseUsage(product, await _page(product.url));
    } on SessionExpired {
      rethrow;
    } on DigiException catch (error) {
      return Product(name: product.name, number: product.number, url: product.url, error: error);
    }
  }

  /// Ends the session at Digi, and in any case on this device.
  Future<void> logOut() async {
    try {
      final csrf = _decode(_body(await _send(http.Request('GET', _site.resolve('api/auth/csrf')))));
      if (csrf case {'csrfToken': final String token}) {
        await _send(
          http.Request('POST', _site.resolve('api/auth/signout'))
            ..bodyFields = {'csrfToken': token, 'callbackUrl': '/'},
        );
      }
    } on DigiException {
      // Forgetting the session here is what logs the user out; Digi drops it in time.
    } finally {
      await _jar.clear();
    }
  }

  Future<LoginActions> _loginActions() async {
    final page = await _send(http.Request('GET', _site.resolve('en/login')));
    final scripts = RegExp(r'src="(/_next/static/[^"]+\.js)"').allMatches(_body(page)).map((script) => script[1]!);

    for (final script in scripts.toSet()) {
      final actions = findLoginActions(_body(await _send(http.Request('GET', _site.resolve(script)))));
      if (actions != null) return actions;
    }

    throw UnexpectedResponse('The login page no longer holds the login actions');
  }

  /// Calls a Next.js server action of the login page, returning its result.
  Future<Map<String, dynamic>> _callAction(String action, Map<String, String> fields) async {
    final response = await _send(
      http.MultipartRequest('POST', _site.resolve('en/login'))
        ..headers['Next-Action'] = action
        ..fields.addAll(fields),
    );
    if (response.statusCode != 200) throw UnexpectedResponse('The login action answered ${response.statusCode}');

    // The answer is a React Server Components stream: rows of `<id>:<json>`, the first pointing to the result's row.
    final rows = {
      for (final line in LineSplitter.split(_body(response)))
        if (line.indexOf(':') case final colon when colon > 0) line.substring(0, colon): line.substring(colon + 1),
    };
    final result = switch (_decode(rows['0'])) {
      [final String reference, ...] ||
      {'a': final String reference} when reference.startsWith(r'$@') => _decode(rows[reference.substring(2)]),
      _ => null,
    };
    if (result is Map<String, dynamic>) return result;

    throw UnexpectedResponse('The login action answered without a result');
  }

  /// The HTML of a page of the logged in part of the site.
  Future<String> _page(Uri url) async {
    final response = await _send(http.Request('GET', url));
    if (response.statusCode ~/ 100 == 3) await _expire();
    if (response.statusCode != 200) throw UnexpectedResponse('${url.path} answered ${response.statusCode}');

    return _body(response);
  }

  Future<Never> _expire() async {
    await _jar.clear();
    throw SessionExpired();
  }

  Future<http.Response> _send(http.BaseRequest request) async {
    request
      ..followRedirects = false
      ..headers.addAll({'Cookie': ?_jar.header(request.url)});

    final http.Response response;
    try {
      response = await _http.send(request).then(http.Response.fromStream).timeout(const Duration(seconds: 30));
    } on Exception {
      throw NetworkFailure();
    }
    await _jar.save(request.url, response.headersSplitValues['set-cookie'] ?? const []);

    return response;
  }

  static String _body(http.Response response) => utf8.decode(response.bodyBytes, allowMalformed: true);

  static Object? _decode(String? json) {
    try {
      return json == null ? null : jsonDecode(json);
    } on FormatException {
      return null;
    }
  }

  static String _uuid() {
    final random = Random.secure();
    final bytes = [for (var i = 0; i < 16; i++) random.nextInt(256)];
    bytes[6] = bytes[6] & 0x0f | 0x40;
    bytes[8] = bytes[8] & 0x3f | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

    return [
      hex.substring(0, 8),
      hex.substring(8, 12),
      hex.substring(12, 16),
      hex.substring(16, 20),
      hex.substring(20),
    ].join('-');
  }
}
