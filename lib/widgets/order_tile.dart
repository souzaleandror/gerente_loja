import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'order_header.dart';

class OrderTile extends StatelessWidget {
  final DocumentSnapshot order;

  OrderTile(this.order);

  final states = [
    "",
    "Em preparacao",
    "Em Transporte",
    "Aguardando Entrega",
    "Entregue"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        key: Key(order.documentID),
        child: ExpansionTile(
          initiallyExpanded: order.data["status"] != 4,
          title: Text(
            "# ${order.documentID.substring(order.documentID.length - 7, order.documentID.length)} - ${states[order.data["status"]]}",
            style: TextStyle(
                color: order.data["status"] != 4
                    ? Colors.grey[850]
                    : Colors.green),
          ),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  OrderHeader(order),
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      children: order.data["products"].map<Widget>((p) {
                        return ListTile(
                          title: Text(p["product"]["title"] + " " + p["size"]),
                          subtitle: Text(p["category"] + " " + p["pid"]),
                          trailing: Text(
                            p["quantity"].toString(),
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                      }).toList()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        textColor: Colors.red,
                        child: Text("Excluir"),
                        onPressed: () {
                          Firestore.instance
                              .collection("users")
                              .document(order["clientId"])
                              .collection("orders")
                              .document(order.documentID)
                              .delete();
                          order.reference.delete();
                        },
                      ),
                      FlatButton(
                        onPressed: order.data["status"] > 1
                            ? () {
                                order.reference.updateData(
                                    {"status": order.data["status"] - 1});
                              }
                            : null,
                        textColor: Colors.grey[850],
                        child: Text("Regredir"),
                      ),
                      FlatButton(
                        textColor: Colors.green,
                        child: Text("Avancar"),
                        onPressed: order.data["status"] < 4
                            ? () {
                                order.reference.updateData(
                                    {"status": order.data["status"] + 1});
                              }
                            : null,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
