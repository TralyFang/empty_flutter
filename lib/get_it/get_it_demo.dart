import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class UserModel {
  int? age;
  String? name;
}

class UserHandler {

  static void initHandler() {
    GetIt.I.registerSingleton<UserModel>(UserModel());
  }

  static void change(String name, int age) {
    GetIt.I<UserModel>()
      ..name = name
      ..age = age;
  }
}

class UserInfoWidget extends StatelessWidget with GetItMixin {
  UserInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // if (!GetIt.I.isRegistered<UserModel>()) UserHandler.initHandler();

    int? age = GetIt.I<UserModel>().age; //watchOnly((UserModel x) => x.age);
    String? name = GetIt.I<UserModel>().name; //watchOnly((UserModel x) => x.name);

    // int? age = watchOnly((UserModel x) => x.age);
    // String? name = watchOnly((UserModel x) => x.name);
    return Text('name:$name, age:$age');
  }
}
