/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/launcher.dart';

abstract class UriInterceptor {
  Uri parse(Uri uri, Uri originUri);
}

class UriParser {
  String _url = '';
  int _contextId;

  static RegExp exp = RegExp("^([a-z][a-z\d\+\-\.]*:)?\/\/");

  UriParser(contextId) : _contextId = contextId;

  Uri parse(Uri uri) {
    String path = uri.toString();

    KrakenController controller = KrakenController.getControllerOfJSContextId(_contextId)!;

    String href = controller.href;
    Uri uriHref = Uri.parse(href);

    // Treat empty scheme as https.
    if (path.startsWith('//')) {
      path = 'https:' + path;
    }

    if (!exp.hasMatch(path) && _contextId != null) {
      // relative path.
      if (path.startsWith('/')) {
        path = uriHref.scheme + '://' + uriHref.host + ':' + uriHref.port.toString() + path;
      } else {
        int lastPath = href.lastIndexOf('/');
        if (lastPath >= 0) {
          path = href.substring(0, href.lastIndexOf('/')) + '/' + path;
        }
      }
    }

    if (_uriInterceptor != null) {
      return _uriInterceptor!.parse(Uri.parse(path), uri);
    }

    return Uri.parse(path);
  }

  UriInterceptor? _uriInterceptor;

  void register(UriInterceptor? uriInterceptor) {
    _uriInterceptor = uriInterceptor;
  }

  Uri get url {
    return Uri.parse(_url);
  }

  String toString() {
    return _url;
  }
}
