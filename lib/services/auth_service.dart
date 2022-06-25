import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier{
  final String _baseUrl = 'identitytoolkit.googleapis.com';
  final String _firebaseToken = 'AIzaSyCaUhpiXpHkFwKVGnPKvmh4HfM57_jVfR4';
  // *TOKEN
  final storage = new FlutterSecureStorage();

  Future<String?> createUser(String email, String password) async{
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password
    };

    final url = Uri.https(_baseUrl, '/v1/accounts:signUp', {
      'key': _firebaseToken
    });

    final resp = await http.post(url, body: json.encode(authData));
    final Map<String, dynamic> decodeResp = json.decode(resp.body);

    // print(decodeRest);
    if(decodeResp.containsKey('idToken')){
      // TODO: Hay que guardar el token en un lugar seguro
      await storage.write(key: 'token', value: decodeResp['idToken']);
      // * decodeResp['idToken']
      return null;
    }else{
      return decodeResp['error']['message'];
    }

  }

  Future<String?> login(String email, String password) async{
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password
    };

    final url = Uri.https(_baseUrl, '/v1/accounts:signInWithPassword', {
      'key': _firebaseToken
    });

    final resp = await http.post(url, body: json.encode(authData));
    final Map<String, dynamic> decodeResp = json.decode(resp.body);

    if(decodeResp.containsKey('idToken')){
      // TODO: Hay que guardar el token en un lugar seguro
      // * decodeResp['idToken']
      await storage.write(key: 'token', value: decodeResp['idToken']);
      return null;
    }else{
      return decodeResp['error']['message'];
    }
  }

  Future logout() async{
    await storage.delete(key: 'token');
    return;
  }

  //* Verificar TOKEN
  Future<String> readToken() async{
    return await storage.read(key: 'token') ?? '';
  }

}