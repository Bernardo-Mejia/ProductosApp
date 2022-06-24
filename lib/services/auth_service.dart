import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier{
  final String _baseUrl = 'identitytoolkit.googleapis.com';
  final String _firebaseToken = 'AIzaSyCaUhpiXpHkFwKVGnPKvmh4HfM57_jVfR4';

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
      return null;
    }else{
      return decodeResp['error']['message'];
    }

  }
}