import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('常驻侧边栏示例'),
      ),
      body: Row(
        children: [
          MouseRegion(
            child: SizedBox(
            width: 200,
            child: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text(
                      '常驻侧边栏',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('首页'),
                    onTap: () {
                      // 处理点击首页时的操作
                    },
                  ),
                  // 添加二级侧边栏
                  ExpansionTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('设置'),
                    children: [
                      ListTile(
                        title: const Text('子项1'),
                        onTap: () {
                          // 处理点击子项1时的操作
                        },
                      ),
                      ListTile(
                        title: const Text('子项2'),
                        onTap: () {
                          // 处理点击子项2时的操作
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 主内容区域
          
          ),
          // 常驻侧边栏
          const Expanded(
            child: Center(
              child: Text('主页内容'),
            ),
          ),
        ],
      ),
    );
  }
}
