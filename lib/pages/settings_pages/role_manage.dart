// ignore_for_file: unused_element, no_leading_underscores_for_local_identifiers
import 'package:database_work/StoreToken.dart';
import 'package:database_work/pages/settings_pages/new_character.dart';
import 'package:flutter/material.dart';
import 'package:database_work/main.dart';
import 'package:dio/dio.dart';
List<Map<String, dynamic>> roles = [];

class role_manage extends StatefulWidget{
  const role_manage({super.key});

  @override
  RoleManagePage createState() => RoleManagePage();
}

class RoleManagePage extends State<role_manage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  int max_page = 0;
  int now_page = 1;
  int rowsPerPage = 5;
  int bef_max = 0;
  int bef_now = 0;
  List<int> pageSizes = [5, 10, 20, 50];

  @override
  bool get wantKeepAlive => true;

  
  String baseUrl = 'http://47.115.227.51:9090';
  late TabController _tabController;

  Future<void> getmenu() async {
    String token = await getToken();
    final dio = Dio();
    var response = await dio.get('$baseUrl/set/menu/list',options: Options(headers: {'AccessToken':token}));
    final Map<String,dynamic> gotMenu = response.data;
    menu = gotMenu['data'];
  }

  void _searchRole() async {
    final dio = Dio();
    bef_max = max_page;
    bef_now = now_page;
    now_page = 1;
    max_page = 0;

    String token = await getToken();
    var response = await dio.get('$baseUrl/set/role/list', options: Options(headers: {'AccessToken':token}),queryParameters: {'page':now_page,'size':rowsPerPage,'keyword':_searchController.text},);
    
    final Map<String,dynamic> data = response.data;

    if(data['code'] == 200){
      max_page = (data['data']['count']/rowsPerPage).ceil();
      setState(() {
        roles = List<Map<String, dynamic>>.from(data['data']['list']);
      });
    }
  }

  void _fetchRoles(int opt) async{
    final dio = Dio();

    String token = await getToken();
    var response = await dio.get('$baseUrl/set/role/list', options: Options(headers: {'AccessToken':token}),queryParameters: {'page':now_page,'size':rowsPerPage},);
    
    final Map<String,dynamic> data = response.data;

    if(data['code'] == 200){
      max_page = (data['data']['count']/rowsPerPage).ceil();
      bef_max = max_page;
      setState(() {
        roles = List<Map<String, dynamic>>.from(data['data']['list']);
      });
    }
    await Future.delayed(const Duration(milliseconds: 100));
    if (!context.mounted) return;
    if(opt == 1) {
      mySnackbar(data['msg'], context);
    }
  }

  
  // 获取当前身份详情
  void fetchNowRoles(int index) async {
    final url = '$baseUrl/set/role/detail';

    String token = await getToken();

    final dio = Dio();
    var response = await dio.get(
      url,
      options: Options(
        headers: {'AccessToken':token},
      ),
      queryParameters: {'identity': roles[index]['identity']},
    );

    final Map<String,dynamic> ret = response.data;
    
    if(ret['code'] == 200)
    {
      setState(() {
        roles[index]['is_admin'] = ret['data']['is_admin'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 创建身份的方法
    void _createRole() async {
      await getmenu();
      await Future.delayed(const Duration(milliseconds: 100));
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (BuildContext context){
          return const NewCharacter();
        },
      );
      _fetchRoles(0);
    }

    // 定义一个编辑身份的方法，您可以在这里添加您的后端请求逻辑
    void _editRole(int index) async {
      await getmenu();
      await Future.delayed(const Duration(milliseconds: 100));
      if(!context.mounted) return;
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return EditCharacter(index: index);
        },
      );
      _fetchRoles(0);
    }

    // 删除身份的方法
    void _deleteRole(int index) async {
      final url = '$baseUrl/set/role/delete';

      String token = await getToken();

      final dio = Dio();
      var response = await dio.delete(
        url,
        options: Options(
          headers: {'AccessToken':token},
        ),
        queryParameters: {'identity': roles[index]['identity']},
      );
      final String msg = response.data['msg'];
      _fetchRoles(0);
      await Future.delayed(const Duration(milliseconds: 100));
      if (!context.mounted) return;
      mySnackbar(msg, context);
    }

    // 切换身份是否为超管的方法
    void _toggleSuper(int index, bool value) async{
      String token = await getToken();
      final dio = Dio();
      var nowRole = await dio.get('$baseUrl/user/info',options: Options(headers: {'AccessToken':token}));
      final Map<String,dynamic> info = nowRole.data;
      if(info['data']['username'] == roles[index]['name']||roles[index]['name'] == '超级管理员')
      {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!context.mounted) return;
        mySnackbar('请勿修改自己或者超级管理员权限', context);
        return;
      }

      var response = await dio.put('$baseUrl/set/role/update/admin',
      options: Options(headers: {'AccessToken':token},),
      data: {'identity':roles[index]['identity'],'is_admin':value ? 1 : 0},);

      final Map<String,dynamic> data = response.data;

      await Future.delayed(const Duration(milliseconds: 100));
      if (!context.mounted) return;
      mySnackbar(data['msg'], context);

      if(data['code'] == 200) {
        fetchNowRoles(index);
      }
    }


    @override
    void initState(){
      super.initState();
      _tabController = TabController(length: 3,vsync: this);
      _fetchRoles(0);
    }

    @override
    void dispose(){
      _tabController.dispose();
    }

    return Center(
      child: Column( 
        children: [
          // 使用 Row 组件来布局创建身份按钮和搜索栏
          Row(
            children: [
              // 使用 ElevatedButton 组件来创建创建身份按钮，指定 onPressed 为 _createRole
              // Flexible(),
              ElevatedButton(
                onPressed: _createRole,
                child: const Text('创建身份'),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    if(_searchController.text.isEmpty) {
                      now_page = bef_now;
                      max_page = bef_max;
                      _fetchRoles(0);
                      setState(() {
                      });
                    } else {
                      _searchRole();
                    }
                  },
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: '搜索身份',
                    suffixIcon: IconButton(
                      onPressed: _searchRole,
                      icon: const Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => {_fetchRoles(0)},
                child: const Text('获取数据'),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              const Text('每页显示的行数：'),
              DropdownButton<int>(
                value: rowsPerPage,
                onChanged: (int? newValue) async {
                  rowsPerPage = newValue!;
                  now_page = 1;
                  max_page = 0;
                  bef_max = max_page;
                  bef_now = now_page;
                  _fetchRoles(1);
                  setState(() {
                  });
                },
                items: pageSizes.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value'),
                  );
                }).toList(),
              ),
              const Expanded(child: SizedBox()),
              IconButton(
                icon: const Icon(Icons.navigate_before_outlined),
                onPressed: now_page > 1 ? () async {
                  now_page -= 1;
                  bef_now = now_page;
                  _fetchRoles(1);
                  setState(() {});
                } : null,
              ),
              const SizedBox(width: 10,),
              Text('当前页数: $now_page '),
              const SizedBox(width: 10,),
              IconButton(
                icon: const Icon(Icons.navigate_next_outlined),
                onPressed: now_page < max_page ? () async {
                  now_page += 1;
                  bef_now = now_page;
                  _fetchRoles(1);
                  setState(() {});
                } : null,
              ),
            ],
          ),
          // 使用 DataTable 组件来创建表格，指定 columns 和 rows 属性
          Expanded(child: 
            SingleChildScrollView(
              child: DataTable(
            // 使用 List.generate 方法根据表头的标题生成六个 DataColumn 组件
                columns: List.generate(
                  ['身份名称', '身份排序', '是否是超管', '创建时间', '更新时间', '操作'].length,
                  (index) => DataColumn(
                    label: Text(['身份名称', '身份排序', '是否是超管', '创建时间', '更新时间', '操作'][index]),
                  ),
                ),
                // 使用 List.generate 方法根据身份的数据生成多个 DataRow 组件
                rows: List.generate(
                  roles.length,
                  (index) => DataRow(
                    // 使用 List.generate 方法根据身份的属性生成六个 DataCell 组件
                    cells: List.generate(
                      ['name', 'sort', 'is_admin', 'created_at', 'updated_at', 'action'].length,
                      (i) {
                        // 如果是操作列，返回一个包含两个 IconButton 的 DataCell
                        if (['name', 'sort', 'is_admin', 'created_at', 'updated_at', 'action'][i] ==
                            'action') {
                          return DataCell(
                            Row(
                              children: [
                                // 使用 IconButton 组件来创建编辑按钮，指定 onPressed 为 _editRole
                                IconButton(
                                  onPressed: () => _editRole(index),
                                  icon: const Icon(Icons.edit),
                                ),
                                // 使用 IconButton 组件来创建删除按钮，指定 onPressed 为 _deleteRole
                                IconButton(
                                  onPressed: () => _deleteRole(index),
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          );
                        }
                        if (['name', 'sort', 'is_admin', 'created_at', 'updated_at', 'action'][i] ==
                            'is_admin') {
                          return DataCell(
                            Switch(
                              value: roles[index]['is_admin'] == 1, 
                              onChanged: (value) => _toggleSuper(index, value),
                            ),
                          );
                        }
                        return DataCell(
                          Text(roles[index][['name', 'sort', 'is_admin', 'created_at', 'updated_at', 'action'][i]].toString()),
                        );
                      },
                    ),
                  ),
                ),
              ),
            )
          )
        ],
      ),
    );
  }
}
