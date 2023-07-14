import 'package:flutter/material.dart';

testFuture([String debugLabel = 'debug']) {


  Future<String> fetch(String requestOptions) async {
    return Future<String>((){
      print('hello');
      return Future.value('hello');
    }).then((value) {
      print('$value hello1');
      return throw '$value hello1';
    }).then((value) {
      print('$value hello2');
      return '$value hello2';
    });

    // FutureBuilder
  }

  fetch('requestOptions');

}