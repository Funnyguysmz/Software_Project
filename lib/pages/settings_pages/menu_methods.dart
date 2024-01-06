// ignore_for_file: camel_case_types

import 'package:database_work/StoreToken.dart';
import 'package:database_work/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

List<Map<String, dynamic>> Menus = [];  //存放生成的列表内容

class menu_method {
  final dio = Dio();

  void getMenus() async {
    String token = await getToken();

    var response = await dio.get(
      '$baseUrl/set/menu/list',
      options: Options(headers: {'AccessToken': token},),
    );

    final Map<String,dynamic> ret = response.data;
    Menus = ret['data'];
  }

  // 新建顶层菜单
  Future<void> createTopMenu(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CD();
      }
    );
  }

  // 新增子集
  Future<void> createSubMenu(BuildContext context,String par_id,String pat) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CSD(pat:pat,ide:par_id);
      }
    );
  }

  // 删除菜单
  Future<void> deleteMenu(BuildContext context, String ide) async {
    String token = await getToken();

    var response = await dio.delete(
      '$baseUrl/dev/menu/delete',
      options: Options(headers: {'AccessToken': token},),
      queryParameters: {'identity':ide},
    );
    await Future.delayed(const Duration(milliseconds: 100));
    if (!context.mounted) return;
    mySnackbar(response.data['msg'], context);

  }

  // 拉取菜单数据
  Future<Map<String,dynamic>> fetchMenus() async {
    String token = await getToken();

    var response = await dio.get(
      '$baseUrl/set/menu/list',
      options: Options(headers: {'AccessToken': token},),
    );

    final Map<String,dynamic> ret = response.data;
    return ret;
  }

  // 编辑菜单
  Future<void> editMenu(BuildContext context,String identity) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CD(ide: identity,);
      }
    );
  }
}

class CD extends StatelessWidget {
  final menuname = TextEditingController();
  final menusort = TextEditingController();
  final menupath = TextEditingController();
  final dio = Dio();
  final String? ide;

  CD({super.key, this.ide});

  @override
  Widget build(BuildContext context) {

    //创建或编辑
    void create_menu() async {
      String token = await getToken();
      if(ide != null) {
        var response = await dio.put(
          '$baseUrl/dev/menu/update',
          options: Options(headers: {'AccessToken': token},),
          data: {'identity':ide,'level':0,'name':menuname.text,'parent_identity':'','path':'/${menupath.text}','sort':int.parse(menusort.text)},
        );

        final Map<String,dynamic> ret = response.data;
        await Future.delayed(const Duration(milliseconds: 100));
        if(!context.mounted) return;
        mySnackbar(ret['msg'], context);
        Navigator.pop(context);
      } else {
        var response = await dio.post(
          '$baseUrl/dev/menu/add',
          options: Options(headers: {'AccessToken': token},),
          data: {'level':0,'name':menuname.text,'parent_identity':'','path':'/${menupath.text}','sort':int.parse(menusort.text)},
        );
        final Map<String,dynamic> ret = response.data;
        await Future.delayed(const Duration(milliseconds: 100));
        if(!context.mounted) return;
        mySnackbar(ret['msg'], context);
        Navigator.pop(context);
      }
    }

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget> [
            TextField(
              controller: menuname,
              decoration: const InputDecoration(labelText: '菜单名称',hintText: '请输入菜单名称'),
            ),
            TextField(
              controller: menusort,
              keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
              decoration: const InputDecoration(labelText: '菜单排序',hintText: '菜单显示的优先级,仅接受一个数字'),
            ),
            TextField(
              controller: menupath,
              decoration: const InputDecoration(labelText: '菜单路径',hintText: '填写一个英文单词,如:setting'),
            ),
            const SizedBox(height: 20,),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('退出'),
                ),
                TextButton(
                  onPressed: create_menu,
                  child: const Text('提交'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CSD extends StatelessWidget {
  final menuname = TextEditingController();
  final menusort = TextEditingController();
  final menupath = TextEditingController();
  final dio = Dio();
  final String? ide;
  final String? pat;

  CSD({super.key, this.ide, this.pat});

  @override
  Widget build(BuildContext context) {

    //创建子集
    void create_menu() async {
      String token = await getToken();
      var response = await dio.post(
        '$baseUrl/dev/menu/add',
        options: Options(headers: {'AccessToken': token},),
        data: {'level':0,'name':menuname.text,'parent_identity':ide,'path':'$pat/${menupath.text}','sort':int.parse(menusort.text)},
      );
      final Map<String,dynamic> ret = response.data;
      await Future.delayed(const Duration(milliseconds: 100));
      if(!context.mounted) return;
      mySnackbar(ret['msg'], context);
      Navigator.pop(context);
    }

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget> [
            TextField(
              controller: menuname,
              decoration: const InputDecoration(labelText: '菜单名称',hintText: '请输入菜单名称'),
            ),
            TextField(
              controller: menusort,
              keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
              decoration: const InputDecoration(labelText: '菜单排序',hintText: '菜单显示的优先级,仅接受一个数字'),
            ),
            TextField(
              controller: menupath,
              decoration: const InputDecoration(labelText: '菜单路径',hintText: '填写一个英文单词,如:setting'),
            ),
            const SizedBox(height: 20,),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('退出'),
                ),
                TextButton(
                  onPressed: create_menu,
                  child: const Text('提交'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}