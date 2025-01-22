import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/cookie_utils.dart';

class AuthService {
  static final String csrfUrl = 'https://www.digi-belgium.be/api/auth/csrf';
  static final String sessionUrl = 'https://www.digi-belgium.be/api/auth/session';
  static final String loginUrl = 'https://www.digi-belgium.be/en/login';
  static final String oauthUrl = 'https://api.digi-belgium.be/v1/oauth2/send_code';
  static final String signoutUrl = 'https://www.digi-belgium.be/api/auth/signout';
  static final String forgotPasswordUrl = 'https://api.digi-belgium.be/v1/auth/lost-password';

  static String accessToken = '';
  static String refreshToken = '';
  static var loginResponse = {};

  static Future<void> fetchCsrfToken() async {
    try {
      final response = await http.get(Uri.parse(csrfUrl));
      handleCookies(response.headersSplitValues);
      print('CSRF Token: ${getCookie("__Host-authjs.csrf-token")}');
    } catch (error) {
      print('Error fetching CSRF token: $error');
    }
  }

  static Future<void> getSession() async {
    try {
      // Prepare the multipart request for finalizing login
      final uri = Uri.parse(sessionUrl);

      // Send the request
      final response = await http.get(
        uri,
        headers: {
          'Cookie': getAllCookies(),
        },
      );
      handleCookies(response.headersSplitValues);
    } catch (error) {
      print('Error getting session: $error');
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      // Prepare the multipart request
      final uri = Uri.parse(loginUrl);
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Cookie': getAllCookies(),
          'Next-Action': '9bb82ed88f8631c32f4bffd3d6716649b3efeeb4',
        })
        ..fields['1_email'] = email
        ..fields['1_password'] = password
        ..fields['0'] =
            '[{"errors":{}},"\$K1",{"email":{"required":"This field is required","valid":"This field is not valid"},"password":"Password must contain at least 6 characters","code":"Code must contain 6 characters"},"69d731e0-d1f8-11ef-b7a9-ed35e98c3d6f","03AFcWeA6E5QuknPqLy7Nx7ZBCrG0to7wWYi_aP852XxWxy_LBoLYj_Xli5bTXzgbxUU8LhnOd-OvYeJkwQT57wzS704Dcpj-urvwouNF5Z_MDa2oeRDOBNRuXpurtLjL-hjGwiOkJ1Yv-a9QVW3Vh3W0KkBDIMd_4T4Va3fpA9KvWkDXIEW83iveCbrowsphhfD3PhwYD6sOmnWYW13rgZMLLSe3ttOO306wu896OD_KRvNTvrBLNwMFxNYIlFomDxzlhXdx8aG-mpYP0QBJ16MRAblMkViC-MYsUNQmB1TnTxx3_4fhgA-9gwYzFfTiZpo63vBFIJkX_BgHgky_vI_B9zQg1CjZ2ujHEoy9xJaidWo4dDNmVxNHTecnwtR3uT6sVQL74JijX4A_8nolNjYHVadsK9TDP6cvR-bC6X1kKdQ_3kF2xCvJduW7xEgSDtTILz6cWEjJ6MRd99Ion1tg2MSecxu70S4B2G4gL5gzGHwdRuD2Mgb5ROoJ8yN3wSTU8OuBokqGvsqvPXyeZjXs26Jxk99RrZJ7EQ824sqsWBw7Nfp_s9qVCEv2WY2xpBVg1nZP0wH9I1VVKVNpyhLkZ9Sb8fR6kPtbZm0Mjj4YfqfDtzKFLnzmiM0SujWiTLLTZ346Gm6kAcG4jdpYIaNKa7nFjj3XYssaBTfL5QSNOcd8W2M7vwV5kgafzJCv4m5Ey1z-7RpcI94FiiwKhxYTr2jDZ1rMGRibotaddXyknVPqw1xwbFvIMfzEzHspc2XlMiqbP-peC_diV_8AvillDktWtenrQw2Pi36j3rJJHMBfQ0TzX3-FctebL7Q7sLsB-kOGshY6AKLLZJkj4Gx8OGlbBqalmFGt-wzdDFFTAIUk7vzEu1gkvd0H6YAntL4Kb5-B6w-Lo6XCZWk_Cg5wBceS9klYohA"]'; // Same JSON as in the JavaScript code

      // Send the request
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      handleCookies(response.headersSplitValues);
      loginResponse = jsonDecode(responseBody.body.split('\n')[1].substring(2).trim());

      if (loginResponse['errors']?['_form']?.contains('You already signed in') == true) {
        print('User is already logged in');
        return true;
      }

      accessToken = loginResponse['access_token'];
      refreshToken = loginResponse['refresh_token'];

      print('Login successful');
      return true;
    } catch (error) {
      print('Error during login: $error');
      return false;
    }
  }

  static Future<void> sendCode() async {
    try {
      final payload = jsonEncode({'lang': 'eng'});
      await http.post(Uri.parse(oauthUrl),
          headers: {
            'Cookie': getAllCookies(),
            'Authorization': 'Bearer ' + accessToken,
            'Content-Type': 'application/json',
          },
          body: payload);
      print('Code sent successfully');
    } catch (error) {
      print('Error sending code: $error');
    }
  }

  static Future<bool> finalizeLogin(String code) async {
    try {
      // Prepare the multipart request for finalizing login
      final uri = Uri.parse(loginUrl);
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Cookie': getAllCookies(),
          'Next-Action': '6fb932ad4b4669bff644a3b11f676edd81dfd869',
        })
        ..fields['1_code'] = code
        ..fields['0'] = '[{"errors":{}},"\$K1",{"email":{"required":"This field is required","valid":"This field is not valid"},"password":"Password must contain at least 6 characters","code":"Code must contain 6 characters"},{"show":true,"data":${jsonEncode(loginResponse)}},"en"]'; // Same JSON as in the JavaScript code

      // Send the request
      final response = await request.send();
      handleCookies(response.headersSplitValues);

      final sessionToken = getCookie('__Secure-authjs.session-token');
      if (sessionToken != null) {
        print('Login finalized successfully: $sessionToken');
        return true;
      } else {
        print('Authentication failed. No session token found.');
        return false;
      }
    } catch (error) {
      print('Error finalizing login: $error');
      return false;
    }
  }

  static Future<void> signout() async {
    try {
      final csrfToken = getCookie('__Host-authjs.csrf-token')?.split('|')[0];
      final callbackUrl = getCookie('__Secure-authjs.callback-url');

      final formData = {
        'csrfToken': csrfToken,
        'callbackUrl': callbackUrl,
      };

      final response = await http.post(Uri.parse(signoutUrl), body: formData, headers: {
        'Cookie': getAllCookies(),
        'Content-Type': 'application/x-www-form-urlencoded',
      });

      handleCookies(response.headersSplitValues);
      if (getCookie('__Secure-authjs.session-token') == null) {
        print('Successfully signed out');
      } else {
        print('Error during signout: session token still present');
      }
    } catch (error) {
      print('Error during signout: $error');
    }
  }

  static Future<void> forgotPassword(String email) async {
    try {
      final payload = jsonEncode({"lang": "en", "email": email});
      await http.post(Uri.parse(forgotPasswordUrl),
          headers: {
            'Cookie': getAllCookies(),
            'Content-Type': 'application/json',
          },
          body: payload);
      print('Code sent successfully');
    } catch (error) {
      print('Error sending code: $error');
    }
  }
}
