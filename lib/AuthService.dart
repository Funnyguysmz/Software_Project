// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:database_work/StoreToken.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class AuthService{
  static dynamic token_msg;

  Future<String?> login(Map<String, dynamic> msg) async{

    final url = Uri.parse('$baseUrl/login/password');

    try{
      var response = await http.post(url, body: jsonEncode({
        'username': msg['username'],
        'password': msg['password'],
      }), headers: {'Content-Type': 'application/json'});
      
      final Map<String,dynamic> data = jsonDecode(response.body);

      // print(data);

      if(data['code'] == 200){
        final String token = data['data']['token'];
        token_msg = data['msg'];

        saveToken(token);
        return "OK";
      }
      else{
        token_msg = data['msg'];
        return "1";
      }
    }catch(e){
      token_msg = "Unknown Error";
      return "-1";
    }
  }

  dynamic GetMsg(){
    return token_msg;
  }
}