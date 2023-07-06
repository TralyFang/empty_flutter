
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('jsondecode', () {
    Map? result;
    try {
      result = jsonDecode('');
    } on Error catch (error) {
      print('urlInfo config error:$error');
    }catch (error) {
      print('urlInfo config other error:$error');
    }

    print('urlInfo config!$result, ${result?.isEmpty}');
  });
    /*
    *
FormatException: Unexpected end of input (at character 1)  ^, stack:
#0      _ChunkedJsonParser.fail (dart:convert-patch/convert_patch.dart:1405)
#1      _ChunkedJsonParser.close (dart:convert-patch/convert_patch.dart:523)
#2      _parseJson (dart:convert-patch/convert_patch.dart:41)
#3      JsonDecoder.convert (dart:convert/json.dart:612)
#4      JsonCodec.decode (dart:convert/json.dart:216)
#5      jsonDecode (dart:convert/json.dart:155)
    *
    * */

  test('&&&===', (){
    final rqMethod = "GET";
    var result = (rqMethod != "GET");
    result &= (!true || rqMethod != "GET");
    expect(result, false);

    // Early ends if policy does not require cache lookup.
    final policy = CachePolicy.refresh;
    var plre = (policy != CachePolicy.request && policy != CachePolicy.forceCache);
    expect(plre, false);
  });

}


enum CachePolicy {
  /// Same as [CachePolicy.request] when origin server has no cache config.
  ///
  /// In short, you'll save every successful GET requests.
  forceCache,

  /// Same as [CachePolicy.refresh] when origin server has no cache config.
  refreshForceCache,

  /// Requests and skips cache save even if
  /// response has cache directives.
  noCache,

  /// Requests regardless cache availability.
  /// Caches if response has cache directives.
  refresh,

  /// Returns the cached value if available (and un-expired).
  ///
  /// Checks against origin server otherwise and updates cache freshness
  /// with returned headers when validation is needed.
  ///
  /// Requests otherwise and caches if response has directives.
  request,
}