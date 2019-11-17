import 'package:elastic_hours/resources/utils/Constants.dart';
import 'model/config.dart';

final String tennant = "common";
final String clientId = MICROSOFT_AZURE_APP_ID;
final String scopes = "openid profile User.Read";
final String redirectUri = MICROSOFT_OAUTH_REDIRECT_URI;

final Config config = new Config(
    tennant,
    clientId,
    scopes,
    redirectUri);