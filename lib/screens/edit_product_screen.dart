import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:toko_online/providers/product.dart';
import 'package:toko_online/providers/product_provider.dart';
import 'package:toko_online/providers/user_provider.dart';
import 'package:toko_online/shared/theme.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "edit-product-screen";
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: "",
    description: "",
    price: 0,
    imageUrl: "",
    sellerName: "",
  );
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    final productId = ModalRoute.of(context).settings.arguments as String;
    if (productId != null) {
      _editedProduct = Provider.of<ProductProvider>(context, listen: false)
          .findById(productId);
      _imageUrlController.text = _editedProduct.imageUrl;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      // Edit Data
      await Provider.of<ProductProvider>(context, listen: false)
          .updateItem(_editedProduct.id, _editedProduct);
    } else {
      // Tambah Data Baru
      try {
        final name = Provider.of<UserProvider>(context, listen: false).name;
        await Provider.of<ProductProvider>(context, listen: false)
            .addItem(_editedProduct, name);
      } catch (e) {
        await showDialog<Null>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("An Error Occured"),
            content: Text("Something went wrong!"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              ),
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: [
          IconButton(icon: Icon(Icons.save_alt), onPressed: _saveForm),
        ],
      ),
      body: _isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: accentColor,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _editedProduct.title,
                        decoration: InputDecoration(
                          labelText: "Nama Produk",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value.isEmpty) return "Field tidak boleh kosong";
                          return null;
                        },
                        onSaved: (newValue) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: newValue,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            sellerName: _editedProduct.sellerName,
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: _editedProduct.price.toString(),
                        decoration: InputDecoration(
                          labelText: "Harga",
                          prefixText: "IDR ",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) return "Field tidak boleh kosong";
                          if (int.tryParse(value) == null)
                            return "Input dengan angka yang valid";
                          if (int.parse(value) <= 0)
                            return "Harga harus lebih dari 0";
                          return null;
                        },
                        onSaved: (newValue) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: int.parse(newValue),
                            imageUrl: _editedProduct.imageUrl,
                            sellerName: _editedProduct.sellerName,
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: _editedProduct.description,
                        decoration: InputDecoration(
                          labelText: "Deskripsi Produk",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        validator: (value) {
                          if (value.isEmpty) return "Field tidak boleh kosong";
                          if (value.length < 30)
                            return "Deskripsi setidaknya memiliki 30 karakter atau lebih";
                          return null;
                        },
                        onSaved: (newValue) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: _editedProduct.title,
                            description: newValue,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            sellerName: _editedProduct.sellerName,
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(top: 8, right: 8),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Center(child: Text("Image Preview"))
                                : Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _imageUrlController,
                              decoration: InputDecoration(
                                labelText: "URL Gambar",
                                helperText:
                                    "Tekan Done Button untuk melihat preview",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              onEditingComplete: () {
                                setState(() {});
                              },
                              validator: (value) {
                                if (value.isEmpty)
                                  return "Field tidak boleh kosong";
                                if (!value.startsWith("http") &&
                                    !value.startsWith("https"))
                                  return "Pastikan url valid";
                                return null;
                              },
                              onSaved: (newValue) {
                                _editedProduct = Product(
                                  id: _editedProduct.id,
                                  isFavorite: _editedProduct.isFavorite,
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  price: _editedProduct.price,
                                  imageUrl: newValue,
                                  sellerName: _editedProduct.sellerName,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
