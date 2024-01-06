// ignore_for_file: unused_local_variable, non_constant_identifier_names, dead_code

import 'package:database_work/AuthService.dart';
import 'package:database_work/StoreToken.dart';
import 'package:database_work/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

List<dynamic> otherMenus = [];

Future<List<dynamic>> getOtherMenus(List<dynamic> menuData) async {
  List<dynamic> temp = [];
  for (var menu in menuData) {
    if (menu['identity'] != '1' && menu['identity'] != '2') {
      if(menu['sub_menus'] != null && menu['sub_menus'].isNotEmpty) {
        temp.add(menu['sub_menus']);
      } else {
        temp.add(menu);
      }
    }
  }
  return temp;
}


Future<List<dynamic>> FetchAccessOtherPage() async {
  final dio = Dio();

  String token = await getToken();
  var response = await dio.get(
    '$baseUrl/menus',
    options: Options(headers: {'AccessToken':token}),
  );

  return response.data['data'];
}

class login_msg{
  final String username;
  final String password;

  login_msg(this.username, this.password);

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}

class Login extends StatefulWidget{
  final ValueChanged<login_msg> goSignin;

  const Login({
    required this.goSignin,
    super.key,
  });

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login>{
  final _userctrl = TextEditingController();
  final _pwdcrtl = TextEditingController();

  Future<void> Gologin() async{
    
    
    final String username = _userctrl.text;
    final String password = _pwdcrtl.text;
    
    AuthService AS = AuthService();
    login_msg ls = login_msg(username,password);
    final String? verify = await AS.login(ls.toJson());

    if(verify == "OK" )
    {
      await Future.delayed(const Duration(seconds: 1));
      if (!context.mounted) return;
      setState(() {playProgressInd = !playProgressInd;});
      mySnackbar('登录成功', context,3000);
      await Future.delayed(const Duration(milliseconds: 100));
      if (!context.mounted) return;
      Navigator.of(context).pushNamed('/HomePage');
    }
    else if(verify == "-1")
    {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('错误'),
          content: Text(
            AS.GetMsg(),
          ),
          actions: [
              TextButton(
              child: const Text('Okay'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
      setState(() {playProgressInd = !playProgressInd;pro = Colors.red;});
    }
    else
    {
      await Future.delayed(const Duration(seconds: 1));
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('未知错误'),
          content: Text(
            AS.GetMsg(),
          ),
          actions: [
              TextButton(
              child: const Text('Okay'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
      setState(() {playProgressInd = !playProgressInd;pro = Colors.red;});
    }
    List<dynamic> tempother = await FetchAccessOtherPage();
    otherMenus = tempother;
    // otherMenus = await getOtherMenus(tempother);
  }
  bool playProgressInd = false;
  var pro = Colors.blue;

  @override
  Widget build(BuildContext context) 
  {
    final double? progressVal = playProgressInd ? null : 0.7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('管理系统'),
      ),
      body:  Center(
        child: Card(
          child: Container(
            constraints: BoxConstraints.loose(const Size(600,600)),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('管理系统'),
                TextField(
                  decoration: const InputDecoration(labelText: '用户名'),
                  controller: _userctrl,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: '密码'),
                  obscureText: true,
                  controller: _pwdcrtl,
                ),
                const SizedBox(height: 10,),
                LinearProgressIndicator(
                  value: progressVal,
                  color: pro,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: !playProgressInd ? () async{
                      setState(()  {
                        playProgressInd = !playProgressInd;
                        pro = Colors.blue; 
                      });
                      await Gologin();
                    } : null,
                    child: const Text('登录'),
                  ), 
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}