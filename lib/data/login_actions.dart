/// The ids of the Next.js server actions behind Digi's login form, which may change whenever Digi rebuilds its site.
typedef LoginActions = ({String logIn, String confirm});

/// Finds the login actions in [script], a JavaScript chunk of the login page, or null when it doesn't hold them.
///
/// The login form submits the email and password to one action, asks Digi's API to email the code, and submits that
/// code to a second action. Both actions are exports of a module that declares them as `x=(0,n.$)("<id>")`.
LoginActions? findLoginActions(String script) {
  final sendCode = script.indexOf('/oauth2/send_code');
  if (sendCode < 0) return null;

  final calls = RegExp(r'\(0,(\w+)\.(\w+)\)\(\w+,\w+,\w+,\w+,\w+\)').allMatches(script).toList();
  final logIn = calls.where((call) => call.start < sendCode).lastOrNull;
  final confirm = calls.where((call) => call.start > sendCode && call[1] == logIn?[1]).firstOrNull;
  if (logIn == null || confirm == null) return null;

  final import = RegExp('[^\\w\$]${logIn[1]}=\\w+\\((\\d+)\\)').allMatches(script.substring(0, logIn.start)).lastOrNull;
  final module = import == null ? -1 : script.indexOf(RegExp('[^\\w\$]${import[1]}:function\\('));
  if (module < 0) return null;

  String? id(String export) {
    final variable = RegExp('[{,]$export:function\\(\\)\\{return (\\w+)\\}').firstMatch(script.substring(module))?[1];

    return variable == null
        ? null
        : RegExp('[^\\w\$]$variable=\\(0,\\w+\\.[\\w\$]+\\)\\("([0-9a-f]{40,})"')
              .firstMatch(script.substring(module))?[1];
  }

  final logInId = id(logIn[2]!);
  final confirmId = id(confirm[2]!);

  return logInId == null || confirmId == null ? null : (logIn: logInId, confirm: confirmId);
}
