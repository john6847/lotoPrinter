//_warningMessagePrintingBet(BuildContext context, String title, String message) {
//  showDialog(
//    context: context,
//    builder: (BuildContext context) {
//      // return object of type Dialog
//      return AlertDialog(
//        title: new Text(title),
//        content: Container(
//          child: Column(
//              children: bets.map((bet) {
//                return Text(message +" \n"+"Boul: "+bet.bet+" Pri: "+bet.price.toString());
//              }).toList()
//          ),
//        ),
//        actions: <Widget>[
//          // usually buttons at the bottom of the dialog
//          new FlatButton(
//            child: new Text("Wi"),
//            onPressed: () {
//
//
//            },
//          ),
//          new FlatButton(
//            child: new Text("Non"),
//            onPressed: () {
//              Navigator.of(context).pop();
//            },
//          ),
//        ],
//      );
//    },
//  );
//}