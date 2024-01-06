// ignore_for_file: non_constant_identifier_names

import 'package:database_work/StoreToken.dart';
import 'package:database_work/pages/settings_pages/admin_manage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:database_work/main.dart';
import 'package:flutter/services.dart';

late List<dynamic> roles; //当前可选的角色

class NewUser extends StatefulWidget {
  const NewUser({super.key});

  @override
  NU createState() => NU();
}

class NU extends State<NewUser> {
  final Username = TextEditingController();
  final Userpwd = TextEditingController();
  final Userpid = TextEditingController();
  String chooseValue = '';

  @override
  void initState() {
    super.initState();
    chooseValue = roles[0]['name'];
  }

  @override
  Widget build(BuildContext context) {
    // 请求创建用户
    void createUser() async {
      String token = await getToken();
      final dio = Dio();
      var response = await dio.post('$baseUrl/set/user/add',
        options: Options(headers: {'AccessToken': token}),
        data: {'password':Userpwd.text,'phone':Userpid.text,'role_identity':roles.firstWhere((role) => role['name'] == chooseValue, orElse: () => {},)['identity'],'username':Username.text},
      );

      final Map<String,dynamic> ret = response.data;
      await Future.delayed(const Duration(milliseconds: 100));
      if(!context.mounted) return;
      mySnackbar(ret['msg'], context);
      Navigator.pop(context);
    }

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: Username,
                decoration:  const InputDecoration(labelText: '用户名'),
              ),
              const SizedBox(height: 20,),
              TextField(
                controller: Userpwd,
                decoration:  const InputDecoration(labelText: '密码'),
              ),
              const SizedBox(height: 20,),
              TextField(
                decoration: const InputDecoration(labelText: '手机号'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                controller: Userpid,
              ),
              const SizedBox(height: 40,),
              Row(
                children: [
                  const SizedBox(child: Text('身份选择：'),),
                  DropdownButton<String> (
                    value: chooseValue,
                    icon: const Icon(Icons.arrow_downward),
                    onChanged: (String? chosen) {
                      setState(() {
                        chooseValue = chosen!;
                      });
                    },
                    items: roles.map<DropdownMenuItem<String>>((dynamic value) {
                      return DropdownMenuItem<String>(
                        value: value['name'],
                        child: Text(value['name']),
                      );
                    }).toList(),
                  )
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: ()=> Navigator.of(context).pop(),
                    child: const Text('退出'),
                  ),
                  TextButton(
                    onPressed: createUser,
                    child: const Text('提交'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EditUser extends StatefulWidget {
  final int? index; // 将index参数改为可选的

  const EditUser({Key? key, this.index}) : super(key: key); // 在构造函数中初始化index

  @override
  EU createState() => EU(index); // 将index传递给EU
}

class EU extends State<EditUser> {
  final Username = TextEditingController();
  final Userpwd = TextEditingController();
  final Userpid = TextEditingController();
  String chooseValue = '';

  final int? ind;
  EU(this.ind);

  @override
  void initState() {
    super.initState();
    chooseValue = roles[0]['name'];
  }

  @override
  Widget build(BuildContext context) {
    // 请求编辑用户
    void editUser() async {
      String token = await getToken();
      final dio = Dio();
      var response = await dio.put('$baseUrl/set/user/update',
        options: Options(headers: {'AccessToken': token}),
        data: {'identity':admins[ind!]['identity'],'password':'none','phone':Userpid.text,'role_identity':roles.firstWhere((role) => role['name'] == chooseValue, orElse: () => {},)['identity'],'username':Username.text},
      );

      final Map<String,dynamic> ret = response.data;
      await Future.delayed(const Duration(milliseconds: 100));
      if(!context.mounted) return;
      Navigator.of(context).pop();
      mySnackbar(ret['msg'], context);
    }

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: Username,
                decoration:  const InputDecoration(labelText: '用户名'),
              ),
              const SizedBox(height: 20,),
              TextField(
                decoration: const InputDecoration(labelText: '手机号'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                controller: Userpid,
              ),
              const SizedBox(height: 40,),
              Row(
                children: [
                  const SizedBox(child: Text('身份选择：'),),
                  DropdownButton<String> (
                    value: chooseValue,
                    icon: const Icon(Icons.arrow_downward),
                    onChanged: (String? chosen) {
                      setState(() {
                        chooseValue = chosen!;
                      });
                    },
                    items: roles.map<DropdownMenuItem<String>>((dynamic value) {
                      return DropdownMenuItem<String>(
                        value: value['name'],
                        child: Text(value['name']),
                      );
                    }).toList(),
                  )
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: ()=> Navigator.of(context).pop(),
                    child: const Text('退出'),
                  ),
                  TextButton(
                    onPressed: editUser,
                    child: const Text('提交'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}