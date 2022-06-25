import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:productos_app/models/models.dart';

class ProductsService extends ChangeNotifier{

  final String _baseUrl = 'flutter-app-a5899-default-rtdb.firebaseio.com';
  final List<Product> products = [];

  late Product? selectedProduct;

  final storage = new FlutterSecureStorage();

  // *Almacenar la imagen seleccionada
  File? newPictureFile;

  bool isLoading = true;
  bool isSaving = false;

  // *Llamar la petición
  ProductsService(){
    this.loadProducts();
  }

  // *Petición fetch
  Future<List<Product>> loadProducts() async {

    this.isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, 'products.json', {
      'auth': await storage.read(key: 'token') ?? ''
    });
    final resp = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode(resp.body);

    // print(productsMap);
    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      this.products.add(tempProduct);
    });

    this.isLoading = false;
    notifyListeners();

    // print(this.products[0].name);
    return this.products;

  }
  // *Método para el CRUD del producto
  Future saveOrCreateProduct(Product product) async{
    isSaving = true;
    notifyListeners();

    if(product.id == null){ // *Validar si no existe el producto
      await this.createProduct(product);
    }else{
      // *Actualización de producto
      await this.updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String>updateProduct(Product product) async{
    final url = Uri.https(_baseUrl, 'products/${product.id}.json', {
      'auth': await storage.read(key: 'token') ?? ''
    });

    final resp = await http.put(url, body: product.toJson());
    final decodingData = resp.body;

    // print(decodingData);

    // TODO: Actualizar el listado de productos
    final index = this.products.indexWhere((element) => element.id == product.id);
    this.products[index] = product;


    return product.id!;
  }

    Future<String>createProduct(Product product) async{
    final url = Uri.https(_baseUrl, 'products.json', {
      'auth': await storage.read(key: 'token') ?? ''
    });
    
    final resp = await http.post(url, body: product.toJson());
    final decodingData = json.decode(resp.body);

    product.id = decodingData['name'];
    this.products.add(product);

    return product.id!;
  }

  void updateSelectedProductImage(String path){
    //! this.selectedProduct.picture = path;
    this.selectedProduct!.picture = path;
    this.newPictureFile = File.fromUri(Uri(path: path));

    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if(this.newPictureFile == null) return null;

    this.isSaving = true;
    notifyListeners();

    final url = Uri.parse('https://api.cloudinary.com/v1_1/dkeyt4dzo/image/upload?upload_preset=oqksibxj');

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', newPictureFile!.path);

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);
    // print(resp.body);

    if(resp.statusCode != 200 && resp.statusCode != 201){
      print('Ocurrió un error');
      print(resp.body);
      return null;
    }

    this.newPictureFile = null;

    final decodeData = json.decode(resp.body);
    return decodeData['secure_url'];
  }

}