import 'dart:async';
import 'package:uuid/uuid.dart';
import 'request/authorization_request.dart';
import 'model/config.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class RequestCode {
  final StreamController<String> _onCodeListener = new StreamController();
  final FlutterWebviewPlugin _webView = new FlutterWebviewPlugin();
  final Config _config;
  AuthorizationRequest _authorizationRequest;

  var _onCodeStream;
  
  RequestCode(Config config) : _config = config {
    _authorizationRequest = new AuthorizationRequest(config);
  }

  Future<String> requestCode() async {
    var code;
     String urlParams = _constructUrlParams();

    String authState = new Uuid().v1();
    String authNonce = new Uuid().v1();
    urlParams = urlParams + "&response_mode=fragment";
    urlParams = urlParams + "&state"+authState;
    urlParams = urlParams + "&nonce="+authNonce;

    await _webView.launch(
        Uri.encodeFull("${_authorizationRequest.url}?$urlParams"),
        clearCookies: _authorizationRequest.clearCookies, 
        hidden: false,  
        rect: _config.screenSize
    );

    _webView.onUrlChanged.listen((String url) {
      Uri uri = Uri.parse(url);

      if(uri.queryParameters["error"] != null) {
        _webView.close();
        throw new Exception("Access denied or authentation canceled."); 
      }
      
      // if (uri.queryParameters["code"] != null) {
      //   _webView.close();
      // _onCodeListener.add(uri.queryParameters["code"]);
      // }  
      if(uri.hasFragment && uri.fragment.split('=')[0] == 'access_token'){
        _webView.close();
        _onCodeListener.add(url);
      }     
    });

    code = await _onCode.first;
    return code;
  }

  
  Future<void> clearCookies() async {
    await _webView.launch("", hidden: true, clearCookies: true);
    await _webView.close();
  }

  Stream<String> get _onCode =>
      _onCodeStream ??= _onCodeListener.stream.asBroadcastStream();

  String _constructUrlParams() => _mapToQueryParams(_authorizationRequest.parameters);

  String _mapToQueryParams(Map<String, String> params) {
    final queryParams = <String>[];
    params
        .forEach((String key, String value) => queryParams.add("$key=$value"));
    return queryParams.join("&");
  }
}