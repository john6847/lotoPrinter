import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lotorb/pages/login.page.dart';
import 'package:lotorb/pages/myApp.page.dart';
import 'package:lotorb/state_container.dart';
import 'package:lotorb/utils/auth.dart';

const platform_enterprise = const MethodChannel('com.lotorb.bloked/enterprise');
const platform_pos = const MethodChannel('com.lotorb.bloked/pos');

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  dynamic _user;
  await Auth.getUser().then((user) {
    _user = user;
  });


  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _user == null
          ? LoginPage()
          : MyApp(
              user: _user,
            ),
    ),
  );
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

_receiveConfigurationWebSocket() {
  const channel = BasicMessageChannel<String>('foo', StringCodec());

  // Receive messages from platform and send replies.
  channel.setMessageHandler((String message) async {
    await Auth.storeLastBlockedCombination(message);

    Map<dynamic, dynamic> jsonMessage = jsonDecode(message);
    printWrapped('Received: $jsonMessage');

    if ((jsonMessage['body']['combination']) != null) {
      await Auth.removeBlockedCombinations();
      await Auth.storeBlockedCombinations(jsonMessage['body']['combination']);
    }

    return 'Hi from Flutter';
  });
}
