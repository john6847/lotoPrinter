import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lotorb/services/odooService.dart';
import 'package:lotorb/utils/printer.dart';

import 'package:odoo_api/odoo_api_connector.dart';
import 'dart:core';

String strInput = "";
final textControllerInput = TextEditingController();
final textControllerMoney = TextEditingController();
final textControllerInputTicketID = TextEditingController();
final ScrollController _scrollController = ScrollController();


FocusNode focusNodeInput = new FocusNode();
FocusNode focusNodeMoney = new FocusNode();

class SalePage extends StatefulWidget {
  SalePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SalePageState createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  ScrollController _scrollBetsController;


  bool saleCompleted = true;
  bool printActivated = true;

  @override
  void initState() {
    setState(() {
      _scrollBetsController = new ScrollController();
    });

    super.initState();
  }


  @override
  void dispose() {
    textControllerInput.clear();
    textControllerMoney.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          child: Padding(
        padding: EdgeInsets.only(bottom: 0.0),
      )),
    );
  }






  _sendSale(MapEntry<String, String> shiftActivated) async {
    await Auth.getUser().then((userConfiguration) {

      dynamic configurations = userConfiguration;
      SaleService.sendSale(configurations, bets, total, shiftActivated, context).then((saleId) async {

          setState(() {
            saleCompleted = false;
          });

          print('ID VENTAS: $saleId}');
          if (saleId == null) {
            Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text("Ticket a pa arive kreye."),
            ));
            return;
          }


          OdooResponse saleResponse = await odooSearchRead('vente.ventes', [['id','=',saleId]], []);
          OdooResponse saleDetailsResponse = await odooSearchRead('vente.lignes', [['vente_id','=',saleId]], []);


          if (saleResponse.getResult() != null) {
            PrinterUtil.printTicket().then(
              (printed) {

                setState(() {
                  bets.clear();
                  total = 0;
                });

                Scaffold.of(context).showSnackBar(new SnackBar(
                  content: new Text('Ticket a anrejistre avek siksè.'),
                ));


                setState(() {
                  saleCompleted = true;
                });

              }
            );
          }
        },
      );
    });

    return false;
  }

  _replaySameTicketDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context1) {
        // return object of type Dialog
        return SizedBox.expand(
          // makes widget fullscreen
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: SizedBox.expand(
                    child: Material(
                  child: Container(
                    margin: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Rantre Kòd Tikè a:"),
                        TextField(
                          controller: textControllerInputTicketID,
                          decoration: InputDecoration(hintText: "Kòd Tikè"),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RaisedButton(
                                onPressed: () {

                                  setState(() {
                                    textControllerInputTicketID.clear();
                                    replayMessage = "";
                                    errorOnReplay = true;
                                  });
                                },
                                child: Text("Reyajiste"),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RaisedButton(
                                color: Colors.blueAccent,
                                textColor: Colors.white,
                                child: Text("Rejwe"),
                                onPressed: () {
                                  if (textControllerInputTicketID.text.isEmpty) {
                                    setState(() {
                                      errorOnReplay = true;
                                      replayMessage = "SVP antre yon nimewo tikè";
                                    });
                                  } else if (textControllerInputTicketID.text.isNotEmpty) {
                                    SaleService.replayTicketApi(int.parse(textControllerInputTicketID.text.toString()), context).then((response) {
                                      Helper.printWrapped('Sale: $response');

                                      if (response == null) {
                                        textControllerInputTicketID.clear();
                                        Navigator.pop(context1);
                                        Scaffold.of(context).showSnackBar(new SnackBar(
                                          content: new Text("Nou pa jwenn nimewo tikè sa."),
                                        ));
                                      }

                                      if (response != null) {
                                        setState(() {
                                          bets.clear();
                                          total = response['sale']['prix_total'].toInt();
                                          (response['saleDetails'] as List).forEach((saleDetail) {
                                            SaleDetailsModel newSale = new SaleDetailsModel();
                                            newSale.product = new MapEntry((saleDetail['combination_type_id'].toString()), (saleDetail['display_name']));
                                            newSale.combination = saleDetail['combination'];
                                            newSale.price = saleDetail['prix'].toInt();

                                            bets.add(newSale);
                                          });
                                        });
                                        Navigator.of(context1).pop();
                                        textControllerInputTicketID.clear();
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: Text(
                            "$replayMessage",
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        )
                      ],
                    ),
                  ),
                )),
              ),
              Expanded(
                flex: 1,
                child: SizedBox.expand(
                  child: RaisedButton(
                      color: Colors.blue[900],
                      child: Text(
                        "Femen",
                        style: TextStyle(fontSize: 20),
                      ),
                      textColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          replayMessage = "";
                          textControllerInputTicketID.clear();
                        });
                        Navigator.pop(context1);
                      }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  activateBolet() {
    setState(() {
      boletCombinationPressed = true;
      activatedProduct = CombinationType.BOLET;
    });
  }

  activateLoto3() {
    setState(() {
      loto3CombinationPressed = true;
      activatedProduct = CombinationType.LOTO_3_CHIF;
    });
  }

  activateMaryaj() {
    setState(() {
      maryajCombinationPressed = true;
      activatedProduct = CombinationType.MARYAJ;
    });
  }

  activateLoto4_1() {
    setState(() {
      loto4_1CombinationPressed = true;
      activatedProduct = CombinationType.LOTO_4_CHIF_1;
    });
  }

  activateLoto4_2() {
    setState(() {
      loto4_2CombinationPressed = true;
      activatedProduct = CombinationType.LOTO_4_CHIF_2;
    });
  }

  activateLoto4_3() {
    setState(() {
      loto4_3CombinationPressed = true;
      activatedProduct = CombinationType.LOTO_4_CHIF_3;
    });
  }

  activateLoto5_1() {
    setState(() {
      loto5_1CombinationPressed = true;
      activatedProduct = CombinationType.LOTO_5_CHIF_1;
    });
  }

  activateLoto5_2() {
    setState(() {
      loto5_2CombinationPressed = true;
      activatedProduct = CombinationType.LOTO_5_CHIF_2;
    });
  }

  activateLoto5_3() {
    setState(() {
      loto5_3CombinationPressed = true;
      activatedProduct = CombinationType.LOTO_5_CHIF_3;
    });
  }

  activateLoto7() {
    setState(() {
      loto7CombinationPressed = true;
      activatedProduct = CombinationType.LOTO_7;
    });
  }

}
