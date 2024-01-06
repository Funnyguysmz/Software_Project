// ignore_for_file: non_constant_identifier_names

import 'package:database_work/StoreToken.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:database_work/main.dart';
import 'package:flutter/services.dart';

import 'role_manage.dart';

late List<dynamic> menu;  //全局menu

class NewCharacter extends StatefulWidget{
  const NewCharacter({super.key});

  @override
  NC createState() => NC();
}

class NC extends State<NewCharacter> {
  bool _isSuperAdmin = false;
  final rolename = TextEditingController();
  final rolesort = TextEditingController();

  late Set<String> _allowedPages;

  void removeSubMenus(List<dynamic> menuData) {
    for (var menu in menuData) {
      _allowedPages.remove(menu['identity']);
      if (menu['sub_menus'].isNotEmpty) {
        removeSubMenus(menu['sub_menus']);
      }
    }
  }

  List<Widget> generateMenu(List<dynamic> menuData, [String? parentIdentity]) {
    List<Widget> menuList = [];
    for (var menu in menuData) {
      if (menu['sub_menus'].isNotEmpty) {
        menuList.add(
          ExpansionTile(
            title: CheckboxListTile(
              title: Text(menu['name']),
              value: _allowedPages.contains(menu['identity']),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _allowedPages.add(menu['identity']);
                  } else {
                    _allowedPages.remove(menu['identity']);
                    removeSubMenus(menu['sub_menus']);
                  }
                });
              },
            ),
            children: generateMenu(menu['sub_menus'], menu['identity']),
          ),
        );
      } else {
        menuList.add(
          CheckboxListTile(
            title: Text(menu['name']),
            value: _allowedPages.contains(menu['identity']),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _allowedPages.add(menu['identity']);
                  if (parentIdentity != null && !_allowedPages.contains(parentIdentity)) {
                    _allowedPages.add(parentIdentity);
                  }
                } else {
                  _allowedPages.remove(menu['identity']);
                }
              });
            },
          ),
        );
      }
    }
    return menuList;
  }



  @override
  void initState() {
    super.initState();
    _allowedPages = {};
  }

  @override
  Widget build(BuildContext context) {

    //请求创建方法
    void createCh() async {
      String token = await getToken();
      final dio = Dio();
      var response  = await dio.post(
        '$baseUrl/set/role/create',
        options: Options(headers: {'AccessToken':token}),
        data: {'is_admin':_isSuperAdmin ? 1 : 0,'sort':int.parse(rolesort.text),'name':rolename.text,'menu_identities': _allowedPages.toList(),},
      );

      final String msg = response.data['msg'];
      await Future.delayed(const Duration(milliseconds: 100));
      if (!context.mounted) return;
      Navigator.of(context).pop();
      mySnackbar(msg, context);
    }

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: rolename,
                decoration: const InputDecoration(labelText: '身份名称'),
              ),
              TextField(
                decoration: const InputDecoration(labelText: '身份排序'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                controller: rolesort,
              ),
              SwitchListTile(
                title: const Text('超级管理员'),
                value: _isSuperAdmin,
                onChanged: (bool value){
                  setState(() {
                    _isSuperAdmin = value;
                  });
                },
              ),
              const SizedBox(child: Text('允许访问的页面：'),),
              ...generateMenu(menu),
              Row(
                children: [
                  TextButton(
                    onPressed: ()=> Navigator.of(context).pop(),
                    child: const Text('退出'),
                  ),
                  TextButton(
                    onPressed: createCh,
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

class EditCharacter extends StatefulWidget{
  const EditCharacter({Key? key, this.index}) : super(key: key);
  final int? index;
  @override
  EC createState() => EC(index);
}

class EC extends State<EditCharacter> {
  bool _isSuperAdmin = false;
  final rolename = TextEditingController();
  final rolesort = TextEditingController();
  final int? ind;
  EC(this.ind);

  late Set<String> _allowedPages;

  void removeSubMenus(List<dynamic> menuData) {
    for (var menu in menuData) {
      _allowedPages.remove(menu['identity']);
      if (menu['sub_menus'].isNotEmpty) {
        removeSubMenus(menu['sub_menus']);
      }
    }
  }

  List<Widget> generateMenu(List<dynamic> menuData, [String? parentIdentity]) {
    List<Widget> menuList = [];
    for (var menu in menuData) {
      if (menu['sub_menus'].isNotEmpty) {
        menuList.add(
          ExpansionTile(
            title: CheckboxListTile(
              title: Text(menu['name']),
              value: _allowedPages.contains(menu['identity']),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _allowedPages.add(menu['identity']);
                  } else {
                    _allowedPages.remove(menu['identity']);
                    removeSubMenus(menu['sub_menus']);
                  }
                });
              },
            ),
            children: generateMenu(menu['sub_menus'], menu['identity']),
          ),
        );
      } else {
        menuList.add(
          CheckboxListTile(
            title: Text(menu['name']),
            value: _allowedPages.contains(menu['identity']),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _allowedPages.add(menu['identity']);
                  if (parentIdentity != null && !_allowedPages.contains(parentIdentity)) {
                    _allowedPages.add(parentIdentity);
                  }
                } else {
                  _allowedPages.remove(menu['identity']);
                }
              });
            },
          ),
        );
      }
    }
    return menuList;
  }

  @override
  void initState() {
    super.initState();
    _allowedPages = {};
  }

  @override
  Widget build(BuildContext context) {

    //请求编辑方法
    void createCh() async {
      String token = await getToken();
      final dio = Dio();
      var response  = await dio.put(
        '$baseUrl/set/role/update',
        options: Options(headers: {'AccessToken':token}),
        data: {'identity':roles[ind!]['identity'],'is_admin':_isSuperAdmin ? 1 : 0,'sort':int.parse(rolesort.text),'name':rolename.text,'menu_identities': _allowedPages.toList(),},
      );

      final String msg = response.data['msg'];
      await Future.delayed(const Duration(milliseconds: 100));
      if (!context.mounted) return;
      mySnackbar(msg, context);
      Navigator.of(context).pop();
    }

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: rolename,
                decoration: const InputDecoration(labelText: '身份名称'),
              ),
              TextField(
                decoration: const InputDecoration(labelText: '身份排序'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                controller: rolesort,
              ),
              SwitchListTile(
                title: const Text('超级管理员'),
                value: _isSuperAdmin,
                onChanged: (bool value){
                  setState(() {
                    _isSuperAdmin = value;
                  });
                },
              ),
              const SizedBox(child: Text('允许访问的页面：'),),
              ...generateMenu(menu),
              Row(
                children: [
                  TextButton(
                    onPressed: ()=> Navigator.of(context).pop(),
                    child: const Text('退出'),
                  ),
                  TextButton(
                    onPressed: createCh,
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