import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

void main() {

  test('queryString', (){

    // _router.define(forgot_password + '/:phoneNumber/:phoneNumberComplete/:country', handler: forgotPwdHandler);


    String url = "flutter://login_indoor/:showSMS";
    url = "flutter://login_indoor?name=liming&age=18";
    expect(parseQueryString(url), {'flutter://login_indoor?name': ['liming'], 'age': ['18']});
    url = "flutter://login_indoor/:showSMS";
    expect(parseQueryString(url), {'flutter://login_indoor/:showSMS': ['']});
    url = "flutter://login_indoor?name=liming&age=18&name=daming";
    expect(parseQueryString(url), {'flutter://login_indoor?name': ['liming'], 'age': ['18'], 'name':['daming']});
    url = "flutter://login_indoor?name=liming&age=18&name=daming&age=80";
    expect(parseQueryString(url), {'flutter://login_indoor?name': ['liming'], 'age': ['18','80'], 'name':['daming']});

  });

  test('uri.title', (){

    var params = {'url':['http://121.37.214.86/h5/talent/#/ExchangeGold?title=aaa']};

    String url = Uri.decodeComponent(params['url']?.first ?? '');

    var u = Uri.parse(url);

    var title = Uri.decodeComponent(_paramWithKey(params, u, 'title'));

    expect(title, 'aaa');
    // expect(u.queryParameters, {'title':'aaa'});

  });

  test('intercept.url', () {
    bool res = shouldIntercept('www.oyetalk.tv/ludo/game.js');
    expect(res, false);
    res = shouldIntercept('www.oyetalk.tv/ludo/tool/gamexxxx.js');
    expect(res, true);
    res = shouldIntercept('www.oyetalk.tv/ludo/tool/gameaaaa.css');
    expect(res, true);
  });

  test('regexp', (){
    isABC('A1234656B123456C');
  });



}

void isABC(String input) {
  RegExp mobile = new RegExp(r'[ABC]');
  bool isAbc = mobile.hasMatch(input);
  var matchs = mobile.allMatches(input).toList().map((e) {
    print('object: ${e.groupNames}, ${e.groupCount}');
  });
  print("是否包含ABC中任意字符：${isAbc}, $matchs");
}

String _paramWithKey(Map<String, List<String>> params, Uri uri, String paramKey) {
  String? paramValue = params[paramKey]?.first;
  if (null == paramValue || paramValue.isEmpty) {
    paramValue = uri.queryParameters[paramKey];
    if (paramValue == null) {
      var list = uri.fragment.split('?');
      var keyValue = list.firstWhere((element) => element.contains(paramKey), orElse: ()=> '');
      if (keyValue.isNotEmpty) {
        return keyValue.split('=').last;
      }
    }
  }
  return paramValue ?? '';
}


Map<String, List<String>> parseQueryString(String query) {
  /*
  //前瞻的内容只作为匹配要求，但是不是表达式的内容，所以下边的替换中，那个“ . ”没有被替换
        var str = "mo2use mouth mooTHse lmo.momop";
        var reg1 = /(mo)(?=\w)/g;
        var reg2 = /(mo)(?=\d)/g;
        var reg3 = /(mo)(?!\d)/g;
        console.log(str.replace(reg1,"X"));//X2use Xuth XoTHse lmo.XXp
        console.log(str.replace(reg2,"X"));//X2use mouth mooTHse lmo.momop
        console.log(str.replace(reg3,"X"));//mo2use Xuth XoTHse lX.XXp
  * */

  /*
  * url = "flutter://login_indoor?name=liming&age=18&name=daming&age=80";
    expect(parseQueryString(url), {'flutter://login_indoor?name': ['liming'], 'age': ['18','80'], 'name':['daming']});
  * */
  final search = RegExp('([^&=]+)=?([^&]*)');
  final params = <String, List<String>>{};
  if (query.startsWith('?')) query = query.substring(1);
  decode(String s) => Uri.decodeComponent(s.replaceAll('+', ' '));
  for (Match match in search.allMatches(query)) {
    String key = decode(match.group(1)!);
    String value = decode(match.group(2)!);

    if (params.containsKey(key)) {
      params[key]!.add(value);
    } else {
      params[key] = [value];
    }
  }
  return params;
}

bool shouldIntercept(String url) {


  List<String> interceptRegExpHosts = ['[^\\s]+(ludo/tool/game)[^\\s]+(.js|.css)'];
  for (String host in interceptRegExpHosts) {
    try {
      return url.contains(RegExp(host));
    }catch (e) {
      return false;
    }
  }


  /*

// interceptContainHosts: [".js<&>path", ".js<&>path", ".css<&>path"]
// interceptRegExpHosts:[".js<$>reg", ".css<$>reg"]
  List<String> interceptContainHosts = ['.js<&>ludo/game'];
  for (String host in interceptContainHosts) {
    List<String> params = host.split('<&>');
    String suffix = url.split('.').last;
    if (params.first.contains(suffix) && url.contains(params.last)) {
      return true;
    }
  }
  List<String> interceptRegExpHosts = ['.js<\$>[^\\s]+(ludo/tool/game)[^\\s]+'];
  for (String host in interceptRegExpHosts) {
    List<String> params = host.split('<\$>');
    String suffix = url.split('.').last;
    print('first:${params.first}, last:${params.last}');
    if (params.first.contains(suffix) && url.contains(RegExp(params.last))) {
      return true;
    }
  }

   */
  return false;
}