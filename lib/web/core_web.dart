import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:core/domain/owner.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import '../core.dart';
import 'events.dart';

class WebCorePlugin extends PluginBase {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel('plugins.flutter.io/lid',
        const StandardMethodCodec(), registrar.messenger);
    final instance = WebCorePlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  @override
  Future<String> generateId(int length) async {
    final w = Worker('worker.js');
    w.postMessage(jsonEncode(GenIdEvent(length: length)));

    var cId = Completer<String>();
    w.onMessage.listen((event) {
      cId.complete(event.data as String);
      w.terminate();
    });
    return await cId.future;
  }

  @override
  Future<String> generateOwner(String id, String name) async {
    final w = Worker('worker.js');
    w.postMessage(jsonEncode(GenOwnerEvent(id: id, name: name)));

    var c = Completer<String>();
    w.onMessage.listen((event) {
      c.complete(event.data as String);
      w.terminate();
    });
    return await c.future;
  }
}
