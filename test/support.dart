import 'dart:convert';
import 'dart:io';

import 'package:digi_mobile/data/cookie_jar.dart';
import 'package:digi_mobile/data/digi_client.dart';
import 'package:digi_mobile/main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

const testEmail = 'test@dynamate.be';
const testPassword = 'Correct-Horse-1';
const testCode = '123456';
const sessionCookie = '__Secure-authjs.session-token';

/// The ids of the login actions in test/fixtures/login_chunk.js.
const logInAction = '9bb82ed88f8631c32f4bffd3d6716649b3efeeb4';
const confirmAction = '6fb932ad4b4669bff644a3b11f676edd81dfd869';

String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

/// Digi's website and API, answering like they do with the sanitized pages in test/fixtures.
class FakeDigi {
  final requests = <http.Request>[];

  /// Whether Digi still accepts the session cookie.
  var sessionValid = true;

  /// Whether the phone has no connection.
  var offline = false;

  /// Phone numbers whose product page fails.
  final failingNumbers = <String>{};

  late final client = MockClient(_answer);

  Iterable<http.Request> requestsTo(String path) => requests.where((request) => request.url.path == path);

  Future<http.Response> _answer(http.Request request) async {
    if (offline) throw http.ClientException('Failed host lookup', request.url);
    requests.add(request);

    return switch ((request.method, request.url.host, request.url.path)) {
      ('GET', 'www.digi-belgium.be', '/api/auth/csrf') => _response(
        '{"csrfToken":"fake-csrf"}',
        cookies: ['__Host-authjs.csrf-token=fake-csrf%7Cfake-hash; Path=/; HttpOnly; Secure; SameSite=Lax'],
      ),
      ('GET', 'www.digi-belgium.be', '/en/login') => _response(fixture('login.html')),
      ('GET', 'www.digi-belgium.be', '/_next/static/chunks/3206-35f0313c510071ea.js') => _response(
        fixture('login_chunk.js'),
      ),
      ('GET', 'www.digi-belgium.be', final path) when path.startsWith('/_next/static/') => _response('/* chunk */'),
      ('POST', 'www.digi-belgium.be', '/en/login') => _action(request),
      ('POST', 'api.digi-belgium.be', '/v1/oauth2/send_code') =>
        request.headers['Authorization'] == 'Bearer fake-access-token'
            ? _response('{"meta":{"status":{"error":false}}}')
            : _response('{"error":"unauthorized"}', status: 401),
      ('POST', 'api.digi-belgium.be', '/v1/auth/lost-password') =>
        (jsonDecode(request.body) as Map<String, dynamic>)['email'] == testEmail
            ? _response('{"meta":{"status":{"error":false,"message":"OK"}}}')
            : _response('{"meta":{"status":{"error":true,"message":"Unknown email"}}}'),
      ('GET', 'www.digi-belgium.be', '/api/auth/session') => _response(
        _signedIn(request) ? '{"user":{"name":"Test Customer"},"expires":"2099-01-01T00:00:00.000Z"}' : 'null',
      ),
      ('GET', 'www.digi-belgium.be', '/nl/my-digi/my-products') =>
        _signedIn(request) ? _response(fixture('my_products.html')) : _response('', status: 307, location: '/login'),
      ('GET', 'www.digi-belgium.be', '/nl/my-digi/my-products/mobile') =>
        !_signedIn(request)
            ? _response('', status: 307, location: '/login')
            : failingNumbers.contains(request.url.queryParameters['phone-nr'])
            ? _response('Internal Server Error', status: 500)
            : _response(fixture('product.html')),
      ('POST', 'www.digi-belgium.be', '/api/auth/signout') => _response(
        '',
        status: 302,
        location: '/',
        cookies: ['$sessionCookie=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; HttpOnly; Secure; SameSite=Lax'],
      ),
      _ => _response('Not found', status: 404),
    };
  }

  bool _signedIn(http.Request request) =>
      sessionValid && (request.headers['Cookie'] ?? '').contains('$sessionCookie=fake-session');

  /// Answers a Next.js server action of the login page like Next.js does, as a React Server Components stream.
  http.Response _action(http.Request request) {
    String? field(String name) => RegExp('name="$name"\r\n\r\n(.*?)\r\n--', dotAll: true).firstMatch(request.body)?[1];
    String result(Object value) => '0:["\$@1",["fake-build",null]]\n1:${jsonEncode(value)}\n';

    return switch (request.headers['Next-Action']) {
      logInAction when field('1_email') == testEmail && field('1_password') == testPassword => _response(
        result({'ok': true, 'access_token': 'fake-access-token', 'refresh_token': 'fake-refresh-token'}),
      ),
      logInAction => _response(
        result({
          'ok': true,
          'meta': {
            'status': {'error': true, 'message': 'Wrong email or password'},
          },
        }),
      ),
      confirmAction when field('1_code') == testCode && field('0')!.contains('fake-access-token') => _response(
        result({'authenticated': true}),
        cookies: ['$sessionCookie=fake-session; Path=/; Expires=Fri, 01 Jan 2100 00:00:00 GMT; HttpOnly; Secure'],
      ),
      confirmAction => _response(
        result({
          'errors': {
            'code': ['Wrong code'],
          },
        }),
      ),
      _ => _response('Server action not found.', status: 404),
    };
  }

  http.Response _response(String body, {int status = 200, String? location, List<String> cookies = const []}) =>
      http.Response.bytes(
        utf8.encode(body),
        status,
        headers: {
          'content-type': 'text/html; charset=utf-8',
          'location': ?location,
          if (cookies.isNotEmpty) 'set-cookie': cookies.join(', '),
        },
      );
}

/// Opens the app in Dutch on a device whose storage holds a session when [signedIn].
Future<void> pumpApp(
  WidgetTester tester,
  FakeDigi digi, {
  bool signedIn = false,
  Size size = const Size(400, 800),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  tester.platformDispatcher.localesTestValue = const [Locale('nl')];
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);

  FlutterSecureStorage.setMockInitialValues({});
  final jar = await CookieJar.open();
  if (signedIn) {
    await jar.save(Uri.https('www.digi-belgium.be', '/en/login'), [
      '$sessionCookie=fake-session; Path=/; Expires=Fri, 01 Jan 2100 00:00:00 GMT; HttpOnly; Secure',
    ]);
  }

  await tester.pumpWidget(DigiApp(client: DigiClient(digi.client, jar)));
  await tester.pumpAndSettle();
}

/// The cookies the app keeps in the device's encrypted storage.
Future<String> storedCookies() async => await const FlutterSecureStorage().read(key: 'cookies') ?? '';
