import 'package:flutter/material.dart';
import 'settings_pages/admin_manage.dart';
import 'settings_pages/role_manage.dart';
import 'settings_pages/menu_manage.dart';

// 定义设置页面
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  // 定义一个 TabController 实例，用于控制 TabBar 和 TabBarView
  late TabController _tabController;

  final List<Widget> _pages = [
  const role_manage(),
  const AdminManagePage(),
  const MenuManagePage(),
];

  // 定义一个 List<String> 实例，用于存储三个选项的标题
  final List<String> _titles = ['身份管理', '管理员管理', '菜单管理'];
  // final List<String> statement = ['此项用于新建身份，例如：工程师、超级管理员、后台维护', '管理员管理', '菜单管理'];

  @override
  void initState() {
    super.initState();
    // 初始化 TabController 实例，指定 length 为 3
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // 释放 TabController 实例
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 使用 TabBar 组件作为 appBar 的 bottom 属性，指定 controller 为 _tabController
        automaticallyImplyLeading: false,
        title: TabBar(
          controller: _tabController,
          // 使用 List.generate 方法根据 _titles 生成三个 Tab 组件
          tabs: List.generate(
            _titles.length,
            (index) => Tab(text: _titles[index]),
          ),
        ),
      ),
      // 使用 TabBarView 组件作为 body 属性，指定 controller 为 _tabController
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        // 使用 List.generate 方法根据 _titles 生成三个 Text 组件，显示对应的标题
        children: List.generate(
          _titles.length,
          (index) => Center(child: _pages[index]),
        ),
      ),
    );
  }
}
