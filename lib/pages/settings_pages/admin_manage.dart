import 'package:database_work/StoreToken.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:database_work/main.dart';
import 'new_user.dart';

List<Map<String, dynamic>> admins = [];  //存放生成的列表内容

class AdminManagePage extends StatefulWidget {
  const AdminManagePage({super.key});

  @override
  Admin_manager createState() => Admin_manager();
}

class Admin_manager extends State<AdminManagePage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int max_page = 0;
  int now_page = 1;
  int rowsPerPage = 5;
  int bef_max = 0;
  int bef_now = 0;
  List<int> pageSizes = [5, 10, 20, 50];
  final TextEditingController searchCtrl = TextEditingController();
  
  // 各类方法
  Future<void> getRoles() async {
    String token = await getToken();
    final dio = Dio();
    var response = await dio.get('$baseUrl/set/role/list',
      options: Options(headers: {'AccessToken': token},),
    );

    final Map<String,dynamic> gotRoles = response.data;

    // 给roles赋值
    roles = gotRoles['data']['list'].map((item) => {'name': item['name'], 'identity': item['identity']}).toList();
  }

  void searchUser() async {
    final dio = Dio();
    bef_max = max_page;
    bef_now = now_page;
    now_page = 1;
    max_page = 0;
    String token = await getToken();
    var response = await dio.get(
        '$baseUrl/set/user/list',
        options: Options(headers: {'AccessToken': token}),
        queryParameters: {'page':now_page,'size':rowsPerPage,'keyword':searchCtrl.text},
      );

      final Map<String,dynamic> ret = response.data;

      if(ret['code'] == 200) {
        max_page = (ret['data']['count']/rowsPerPage).ceil();
        setState(() {
          admins = List<Map<String,dynamic>>.from(ret['data']['list']);
        });
        setState(() {
          
        });
      }
  }

  // 拉取数据方法
    Future<void> _fetchUser(int opt) async {
      const url = '$baseUrl/set/user/list';
      String token = await getToken();

      final dio = Dio();
      var response = await dio.get(
        url,
        options: Options(headers: {'AccessToken': token}),
        queryParameters: {'page':now_page,'size':rowsPerPage},
      );

      final Map<String,dynamic> ret = response.data;

      if(ret['code'] == 200) {
        max_page = (ret['data']['count']/rowsPerPage).ceil();
        bef_max = max_page;
        setState(() {
          admins = List<Map<String,dynamic>>.from(ret['data']['list']);
        });
        setState(() {
          
        });
      }
      await Future.delayed(const Duration(milliseconds: 100));
      if (!context.mounted) return;
      if(opt == 0) {
        mySnackbar(ret['msg'], context);
      }
    }

    // 编辑用户方法
    void _editUser(int index) async {
      getRoles();
      await Future.delayed(const Duration(milliseconds: 100));
      if(!context.mounted) return;
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return EditUser(index:index);
        },
      );
      await _fetchUser(1);
    }

    // 删除用户方法
    void _deleteUser(int index) async {
      String token = await getToken();
      final dio = Dio();
      var response = await dio.delete(
        '$baseUrl/set/user/delete',
        options: Options(headers: {'AccessToken': token}),
        queryParameters: {'identity':admins[index]['identity']}
      );

      await _fetchUser(1);
      await Future.delayed(const Duration(milliseconds: 100));
      if (!context.mounted) return;
      mySnackbar(response.data['msg'], context);

    }

    // 创建用户方法
    void _createUser() async {
      getRoles();
      await Future.delayed(const Duration(milliseconds: 100));
      if(!context.mounted) return;
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const NewUser();
        },
      );
      await _fetchUser(1);
    }

  //

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    @override
    void initState() {
      super.initState();
    }

    return Center(
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: _createUser,
                child: const Text('创建用户'),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    if(searchCtrl.text.isEmpty) {
                      now_page = bef_now;
                      max_page = bef_max;
                      _fetchUser(1);
                      setState(() {
                      });
                    } else {
                      searchUser();
                    }
                  },
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    labelText: '搜索用户',
                    suffixIcon: IconButton(
                      onPressed: ()=>{} ,
                      icon: const Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => {_fetchUser(0)},
                child: const Text('获取数据'),
              )
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
                  await _fetchUser(1);
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
                  await _fetchUser(1);
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
                  await _fetchUser(1);
                  setState(() {});
                } : null,
              ),
            ],
          ),
          Expanded(child: 
            SingleChildScrollView(
              child: DataTable(
                columns: List.generate(
                  ['用户名','用户身份','手机号','创建时间','更新时间','操作'].length,
                  (index) => DataColumn(
                    label: Text(['用户名','用户身份','手机号','创建时间','更新时间','操作'][index]),
                  ),
                ),
                rows: List.generate(
                  admins.length,
                  (index) => DataRow(
                    cells: List.generate(
                      ['username', 'role_name', 'phone', 'created_at', 'updated_at', 'action'].length,
                      (i) {
                        if(['username', 'role_name', 'phone', 'created_at', 'updated_at', 'action'][i] == 'action') {
                          return DataCell(
                            Row(
                              children: [
                                // 使用 IconButton 组件来创建编辑按钮，指定 onPressed 为 _editRole
                                IconButton(
                                  onPressed: () => _editUser(index),
                                  icon: const Icon(Icons.edit),
                                ),
                                // 使用 IconButton 组件来创建删除按钮，指定 onPressed 为 _deleteRole
                                IconButton(
                                  onPressed: () => _deleteUser(index),
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          );
                        }
                        return DataCell(
                          Text(admins[index][['username', 'role_name', 'phone', 'created_at', 'updated_at', 'action'][i]].toString()),
                        );
                      }
                    )
                  )
                ),
              ),
            )
          )
        ],
      ),
    );
  }
}