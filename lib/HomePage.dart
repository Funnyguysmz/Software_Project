// ignore_for_file: constant_identifier_names, camel_case_types, no_leading_underscores_for_local_identifiers
import 'package:database_work/StoreToken.dart';
import 'package:database_work/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'pages/settings.dart';
import 'Login.dart';
import 'animation.dart';
// import 'package:material_symbols_icons/symbols.dart';

late Map<String,String> user_info = {};
String choose_name = '';


class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState()=>_HomePage();
}

class _HomePage extends State<HomePage> with RestorationMixin {
  final RestorableInt _selectedIndex = RestorableInt(0);
  bool draweropen = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget currentPage = const Center(
    child: Text('This is the home page'),
  );

  @override
  String get restorationId => 'HomePage';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedIndex, 'selected_index');
  }

  @override
  void dispose() {
    _selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){

    Future<void> _fetchinfo() async {
      String token = await getToken();

      final dio = Dio();
      var response = await dio.get(
        '$baseUrl/user/info',
        options: Options(headers: {'AccessToken':token}),
      );
      
      user_info = Map<String,String>.from(response.data['data']);
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("管理系统"),
        automaticallyImplyLeading: false,
      ),
      drawer: draweropen ? Drawer(
        child: ListView.builder(
          itemCount: otherMenus.length - 2,
          itemBuilder: (BuildContext context, int index) {
            index += 2;
            var menu = otherMenus[index];
            var subMenus = List<Map<String, dynamic>>.from(menu['sub_menus'] ?? []);
            if (subMenus.isNotEmpty && menu['name'] != '首页' && menu['name'] != '设置') {
              return ExpansionTile(
                title: Text(menu['name']),
                children: subMenus.map((subMenu) {
                  return ListTile(
                    title: Text(subMenu['name']),
                    onTap: () {
                      choose_name = menu['name'];
                      setState(() {
                        currentPage = Center(
                          child: Text('这里是 $choose_name'),
                        );
                      });
                    },
                  );
                }).toList(),
              );
            } else {
              // 如果没有子菜单，创建一个普通的ListTile
              return ListTile(
                title: Text(menu['name']),
                onTap: () {
                  choose_name = menu['name'];
                  setState(() {
                    currentPage = Center(
                      child: Text('这里是 $choose_name'),
                    );
                  });
                },
              );
            }
          },
        ),
      ) : null,
      body: Row(
        children: [
          NavigationRail(
            labelType: NavigationRailLabelType.selected,
            leading: PopupMenuButton<int>(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: OpenContainer(
                    closedBuilder: (BuildContext _,VoidCallback openContainer) {
                      return ListTile(
                        title: const Text('修改密码'),
                        onTap: () async {
                          await _fetchinfo();
                          openContainer();
                        },
                      );
                    },
                    openBuilder: (BuildContext _, VoidCallback __) {
                      return const ChangePassword();
                    },
                  ),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: Text('退出登录'),
                )
              ],
              onSelected: (value) async {
                if(value == 1) {
                } else {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.person),
              tooltip: '账号管理',
            ),
            destinations: const [
              NavigationRailDestination(
                selectedIcon: Icon(Icons.home),
                label: Text('主页'),
                icon: Icon(Icons.home_outlined),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('设置'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.more_horiz),
                label: Text('其他'),
              ),
            ],
            selectedIndex: _selectedIndex.value,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex.value = index;
                switch (index) {
                  case 0:
                    currentPage = const Center(
                      child: Text('This is the home page'),
                    );
                    break;
                  case 1:
                    currentPage = const SettingsPage();
                    break;
                  case 2: 
                    setState(() {
                    });
                    _scaffoldKey.currentState?.openDrawer();
                    draweropen = true;  
                    break;
                  default:
                    break;
                }
              });
            },
          ),
          Expanded(
            child: currentPage,
          ),
        ],
      )
    );
  }
}

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _pwdctrl = TextEditingController();
  final _pwd2crtl = TextEditingController();
  final _oldpwdcrtl = TextEditingController();

  // 提交修改
  Future<void> commitmodify() async {
    if(_pwdctrl.text != _pwd2crtl.text) {
      mySnackbar('两次新密码输入不一致', context, 3000);
      return;
    }
    
    String token = await getToken();
    final dio = Dio();

    var response = await dio.put(
      '$baseUrl/user/password/change',
      options: Options(headers: {'AccessToken':token}),
      data: {'new_password':_pwd2crtl.text,'old_password':_oldpwdcrtl.text},
    );
    await Future.delayed(const Duration(milliseconds: 100));
    if (!context.mounted) return;
    mySnackbar(response.data['msg'], context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('账户管理'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget> [
              Text('用户名: ${user_info['username']}'),
              Text('电话: ${user_info['phone']}'),
              Text('角色: ${user_info['role_name']}'),
              TextField(
                controller: _oldpwdcrtl,
                decoration: const InputDecoration(
                  labelText: '旧密码',
                ),
                obscureText: true,
              ),
              TextField(
                controller: _pwdctrl,
                decoration: const InputDecoration(
                  labelText: '新密码',
                ),
                obscureText: true,
              ),
              TextField(
                controller: _pwd2crtl,
                decoration: const InputDecoration(
                  labelText: '确认新密码',
                ),
                obscureText: true,
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: ()=> Navigator.of(context).pop(),
                    child: const Text('退出'),
                  ),
                  TextButton(
                    onPressed: commitmodify,
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

class OtherPageDemo extends StatefulWidget {
  const OtherPageDemo({super.key});
  
  @override
  OPD createState() => OPD();
}

class OPD extends State<OtherPageDemo> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            Text('这里是 $choose_name ',style: const TextStyle(fontSize: 30),),
          ],
        ),
      ),
    );
  }
}