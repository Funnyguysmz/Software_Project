// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:database_work/pages/settings_pages/menu_methods.dart';
import 'package:flutter/material.dart';
import 'package:database_work/main.dart';

final methods = menu_method();

// 菜单管理页面的内容
class MenuManagePage extends StatefulWidget {
  const MenuManagePage({super.key});

  @override
  MMP createState() => MMP();
}

class MMP extends State<MenuManagePage> with AutomaticKeepAliveClientMixin{
  List<Map<String, dynamic>> menus = [];  //存放生成的列表内容

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Future<void> ffetchMenu() async {
      final Map<String,dynamic> data = await methods.fetchMenus();
      menus = List<Map<String, dynamic>>.from(data['data']);
    }

    void deleteMenu(String identity) async {
      await methods.deleteMenu(context, identity);
      await ffetchMenu();
      setState(() {

      });
    }

    void edit(String identity) async {
      await methods.editMenu(context, identity);
      await ffetchMenu();
      setState(() {
        
      });
    }

    Future<void> _fetchMenu(int opt) async {
      final Map<String,dynamic> data = await methods.fetchMenus();
      menus = List<Map<String, dynamic>>.from(data['data']);
      await Future.delayed(const Duration(milliseconds: 100));
      if (!context.mounted) return;

      if(data['code'] == 200) {
        setState(() {
          
        });
      }
      if(opt == 1) {
        mySnackbar(data['msg'], context);
      }
    }

    Future<void> createSub(String ide,String pat) async {
      await methods.createSubMenu(context, ide, pat);
    }

    List<DataRow> generateMenu([List<dynamic>? menuData]) {
      menuData ??= menus;
      List<DataRow> menuList = [];
      for (var menu in menuData) {
        List<DataCell> cells = [
          DataCell(Text(menu['name'])),
          DataCell(Text(menu['sort'].toString())),
          DataCell(Text(menu['path'])),
          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await createSub(menu['identity'],menu['path']);
                  await _fetchMenu(0);
                  setState(() {
                    generateMenu();
                  });
                },
                tooltip: '新增子集',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  edit(menu['identity']);
                },
                tooltip: '编辑',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  deleteMenu(menu['identity']);
                },
                tooltip: '删除',
              ),
            ],
          )),
        ];
        menuList.add(DataRow(cells: cells));
        if (menu['sub_menus'].isNotEmpty) {
          menuList.addAll(generateMenu(menu['sub_menus']));
        }
      }
      return menuList;
    }

    void createTop() async {
      await methods.createTopMenu(context);
      await _fetchMenu(0);
      setState(() {
        generateMenu();
      });
    }
    
    return Center(
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: createTop,
                child: const Text('新增顶层菜单'),
              ),
              const Expanded(child: SizedBox()),
              const SizedBox(width: 20,),
              ElevatedButton(
                onPressed: () => {_fetchMenu(1)},//这里调用fetchmenu
                child: const Text('获取数据'),
              ),
            ],
          ),
          Expanded( 
            child: SingleChildScrollView(
              child: DataTable(
                columns: List.generate(
                  ['菜单名称','菜单排序','路径','操作'].length,
                  (index) => DataColumn(
                    label: Text(['菜单名称','菜单排序','路径','操作'][index]),
                  ),
                ),
                rows: generateMenu(menus),
              ),
            ),
          ), 
        ],
      ),
    );

  }
}
