
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


}
