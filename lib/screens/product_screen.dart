import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/blocs/product_bloc.dart';
import 'package:gerente_loja/validators/product_validator.dart';
import 'package:gerente_loja/widgets/images_widget.dart';
import 'package:gerente_loja/widgets/product_size.dart';

class ProductScreen extends StatefulWidget {
  final String categoryId;
  final DocumentSnapshot product;

  ProductScreen({this.categoryId, this.product});

  @override
  _ProductScreenState createState() => _ProductScreenState(categoryId, product);
}

class _ProductScreenState extends State<ProductScreen> with ProductValidator {
  final ProductBloc _productBloc;

  _ProductScreenState(String categoryId, DocumentSnapshot product)
      : _productBloc = ProductBloc(categoryId: categoryId, product: product);

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    InputDecoration _buildDecoration(String label) {
      return InputDecoration(
          labelText: label, labelStyle: TextStyle(color: Colors.grey));
    }

    final _fieldStyle = TextStyle(color: Colors.white, fontSize: 16);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        elevation: 0,
        title: StreamBuilder<bool>(
            initialData: false,
            stream: _productBloc.outCreated,
            builder: (context, snapshot) {
              return Text(snapshot.data ? "Editar Produto" : "Criar Produto");
            }),
        actions: <Widget>[
          StreamBuilder<bool>(
            stream: _productBloc.outCreated,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data)
                return StreamBuilder<bool>(
                    stream: _productBloc.outLoading,
                    initialData: false,
                    builder: (context, snapshot) {
                      return IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: snapshot.data
                            ? null
                            : () {
                                _productBloc.deleteProduct();
                                Navigator.of(context).pop();
                              },
                      );
                    });
              else
                return Container();
            },
          ),
          StreamBuilder<bool>(
              stream: _productBloc.outLoading,
              initialData: false,
              builder: (context, snapshot) {
                return IconButton(
                  icon: Icon(Icons.save),
                  onPressed: snapshot.data ? null : saveProduct,
                );
              })
        ],
      ),
      body: Stack(
        children: <Widget>[
          Form(
            key: _formKey,
            child: StreamBuilder<Map>(
                stream: _productBloc.outData,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  } else {
                    return ListView(
                      padding: EdgeInsets.all(16),
                      children: <Widget>[
                        Text("Imagens",
                            style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ImagesWidget(
                          context: context,
                          initialValue: snapshot.data["images"],
                          onSaved: _productBloc.saveImages,
                          validator: validateImages,
                        ),
                        TextFormField(
                          initialValue: snapshot.data["title"],
                          style: _fieldStyle,
                          decoration: _buildDecoration("Titulo"),
                          onSaved: _productBloc.saveTitle,
                          validator: validateTitle,
                        ),
                        TextFormField(
                          initialValue: snapshot.data["description"],
                          style: _fieldStyle,
                          maxLines: 6,
                          decoration: _buildDecoration("Descricao"),
                          onSaved: _productBloc.saveDescription,
                          validator: validateDescription,
                        ),
                        TextFormField(
                          initialValue:
                              snapshot.data["price"]?.toStringAsFixed(2),
                          style: _fieldStyle,
                          decoration: _buildDecoration("Preco"),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          onSaved: _productBloc.savePrice,
                          validator: validatePrice,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Tamanhos",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        ProductSize(
                          context: context,
                          initialValue: snapshot.data["sizes"],
                          onSaved: _productBloc.saveSizes,
                          validator: (s) {
                            if (s.isEmpty)
                              return "Deve ter pelo menos um tamanho";
                          },
                        ),
                      ],
                    );
                  }
                }),
          ),
          StreamBuilder<bool>(
              stream: _productBloc.outLoading,
              initialData: false,
              builder: (context, snapshot) {
                return IgnorePointer(
                  ignoring: !snapshot.data,
                  child: Container(
                    color: snapshot.data ? Colors.black54 : Colors.transparent,
                  ),
                );
              }),
        ],
      ),
    );
  }

  void saveProduct() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          "Salvando produto...",
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(minutes: 1),
        backgroundColor: Colors.pinkAccent,
      ));

      bool success = await _productBloc.saveProduct();

      _scaffoldKey.currentState.removeCurrentSnackBar();

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          success ? "Produto salvo!" : "Erro ao salvar produto!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
      ));
    }
  }
}
