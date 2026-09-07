import 'package:flutter_test/flutter_test.dart';
import 'package:pet_track_mobile/core/network/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('logout storage clears access and refresh tokens', () async {
    SharedPreferences.setMockInitialValues({
      'access_token': 'access-test',
      'refresh_token': 'refresh-test',
    });
    final storage = TokenStorage();

    await storage.clearTokens();

    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);
    expect(await storage.hasTokens(), isFalse);
  });
}
