import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

/// Extension on [GoogleSignIn] that adds an `authenticatedClient` method.
///
/// This method can be used to retrieve an authenticated [gapis.AuthClient]
/// client that can be used with the rest of the `googleapis` libraries.
extension GoogleApisGoogleSignInAuth on GoogleSignIn {
  /// Retrieve a `googleapis` authenticated client.
  Future<gapis.AuthClient?> authenticatedClient({
    @visibleForTesting GoogleSignInAuthentication? debugAuthentication,
    @visibleForTesting List<String>? debugScopes,
  }) async {
    final GoogleSignInAuthentication? auth =
        debugAuthentication ?? await currentUser?.authentication;
    final String? oathTokenString = auth?.accessToken;
    if (oathTokenString == null) {
      return null;
    }
    final gapis.AccessCredentials credentials = gapis.AccessCredentials(
      gapis.AccessToken(
        'Bearer',
        oathTokenString,
        //
        // See https://github.com/flutter/flutter/issues/80905
        DateTime.now().toUtc().add(const Duration(days: 365)),
      ),
      null, // We don't have a refreshToken
      debugScopes ?? scopes,
    );

    return gapis.authenticatedClient(http.Client(), credentials);
  }
}
