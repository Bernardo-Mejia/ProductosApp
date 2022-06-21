import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:productos_app/models/models.dart';
import 'package:http/http.dart' as http;

class ProductsService extends ChangeNotifier{

  final String _baseUrl = 'flutter-app-a5899-default-rtdb.firebaseio.com';
  final List<Product> products = [];

  late Product? selectedProduct;
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

    final url = Uri.https(_baseUrl, 'products.json');
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
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    final resp = await http.put(url, body: product.toJson());
    final decodingData = resp.body;

    // print(decodingData);

    // TODO: Actualizar el listado de productos
    final index = this.products.indexWhere((element) => element.id == product.id);
    this.products[index] = product;


    return product.id!;
  }

    Future<String>createProduct(Product product) async{
    final url = Uri.https(_baseUrl, 'products.json');
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

}