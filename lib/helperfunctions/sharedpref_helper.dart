import 'package:shared_preferences/shared_preferences.dart';

const String userIdKey = 'USERKEY';
const String userNameKey = 'USERNAMEKEY';
const String displayNameKey = 'USERDISPLAYNAMEKEY';
const String userEmailKey = 'USEREMAILKEY';
const String userProfilePicKey = 'USERPROFILEPICKEY';

class SharedPreferenceHelper {
  static final instance = SharedPreferenceHelper._();

  String? _userName;
  String? _userEmail;
  String? _userId;
  String? _displayName;
  String? _userProfileUrl;

  SharedPreferenceHelper._();

  factory SharedPreferenceHelper() => instance;

  Future<void> initialise() async {
    await Future.wait([
      SharedPreferences.getInstance().then((prefs) {
        _userName = prefs.getString(userNameKey) ?? '';
      }),
      SharedPreferences.getInstance().then((prefs) {
        _userEmail = prefs.getString(userEmailKey) ?? '';
      }),
      SharedPreferences.getInstance().then((prefs) {
        _userId = prefs.getString(userIdKey) ?? '';
      }),
      SharedPreferences.getInstance().then((prefs) {
        _displayName = prefs.getString(displayNameKey) ?? '';
      }),
      SharedPreferences.getInstance().then((prefs) {
        _userProfileUrl = prefs.getString(userProfilePicKey) ?? '';
      }),
    ]);
  }

  set userName(String userName) {
    _userName = userName;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(userNameKey, userName),
    );
  }

  set userEmail(String userEmail) {
    _userEmail = userEmail;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(userEmailKey, userEmail),
    );
  }

  set userId(String userId) {
    _userId = userId;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(userIdKey, userId),
    );
  }

  set displayName(String displayName) {
    _displayName = displayName;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(displayNameKey, displayName),
    );
    return;
  }

  set userProfileUrl(String userProfileUrl) {
    _userProfileUrl = userProfileUrl;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(userProfilePicKey, userProfileUrl),
    );
  }

  String get userName {
    assert(
      _userName != null,
      '_userName == null - forgot to call SharedPreferenceHelper.initialise()?',
    );
    return _userName!;
  }

  String get userEmail {
    assert(
      _userEmail != null,
      '_userEmail == null - forgot to call SharedPreferenceHelper.initialise()?',
    );
    return _userEmail!;
  }

  String get userId {
    assert(
      _userId != null,
      '_userId == null - forgot to call SharedPreferenceHelper.initialise()?',
    );
    return _userId!;
  }

  String get displayName {
    assert(
      _displayName != null,
      '_displayName == null - forgot to call SharedPreferenceHelper.initialise()?',
    );
    return _displayName!;
  }

  String get userProfileUrl {
    assert(
      _userProfileUrl != null,
      '_userProfileUrl == null - forgot to call SharedPreferenceHelper.initialise()?',
    );
    return _userProfileUrl!;
  }
}
