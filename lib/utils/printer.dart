import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lotorb/models/saleDetails.model.dart';
import 'package:lotorb/utils/helpers.dart';

class PrinterUtil{
  // Platform created so we can call Printer Method from Native Android Code.
  static const platform = const MethodChannel('com.lotorb.print/printer');

  static Future<bool> printTicket() async {
    try {
      
	  String fullTicket = "Ticket Design"
      print(fullTicket);
      await platform.invokeMethod('printer',{"bets":fullTicket});
      return true;

    } on PlatformException catch (e) {
      debugPrint("Printer Not found.");
      return false;
    }
  }
}