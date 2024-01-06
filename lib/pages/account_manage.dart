import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  AP createState() => AP();
}

class AP extends State<AccountPage> with AutomaticKeepAliveClientMixin {
  final _pwdctrl = TextEditingController();
  final _pwdconfirmcrtl = TextEditingController();
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('账号管理'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: '修改密码'),
              controller: _pwdctrl,
              obscureText: true,
            ),
            TextField(
              decoration: const InputDecoration(labelText: '再次确认密码'),
              controller: _pwdconfirmcrtl,
              obscureText: true,
            )
          ],
        ),
      ),
    );
  }
}