// ignore_for_file: non_constant_identifier_names, avoid_types_as_parameter_names
import 'package:flutter/material.dart';
import 'Login.dart';
import 'HomePage.dart';

const String baseUrl = 'http://47.115.227.51:9090';

void mySnackbar(String msg,BuildContext context,[int ms = 500]) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: Duration(milliseconds: ms),
      behavior: SnackBarBehavior.floating,
      content: Text(msg),
      action: SnackBarAction(
        label: 'Okay',
        onPressed: () {
          
        },
      ),
    ),
  );
}

void main() {
  runApp(
    const MyWeb(),
  );
}


class MyWeb extends StatelessWidget{
  const MyWeb({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Login(goSignin: (login_msg){},),
      // home: Login(),
      routes: {
        '/HomePage':(context) => const HomePage(),
      },
    );
  }
}
