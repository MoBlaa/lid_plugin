import 'package:core/domain/crypto/module.dart';
import 'package:core/domain/owner.dart';
import 'package:flutter/services.dart';

/// Base class for implementation of all modules by a flutter plugin for different platforms.
/// This is originates to the problem that generating RSA keys in the browser takes very long.
abstract class PluginBase {
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'generateId':
        return await this.generateId(call.arguments['length']);
      case 'generateOwner':
        return await this
            .generateOwner(call.arguments['id'], call.arguments['name']);
      default:
        throw UnimplementedError(
            "Method '${call.method}' not supported for CorePlugin");
    }
  }

  Future<String> generateId(int length) async {
    throw UnimplementedError(
        "Method 'generateId' not implemented for this platform");
  }

  Future<String> generateOwner(String id, String name) async {
    throw UnimplementedError(
        "'Method 'generateOwner' not implemented for this platform");
  }
}

const MethodChannel _channel = MethodChannel('plugins.flutter.io/lid');

class CorePlugin implements CryptoModule {
  @override
  Future<String> generateId(int length) async {
    assert(length > 0);
    final result =
        await _channel.invokeMethod<String>('generateId', {'length': length});
    return result;
  }

  @override
  Future<Owner> generateOwner(String id, String name) async {
    assert(name != null && id != null);
    final result = await _channel
        .invokeMethod<String>('generateOwner', {'id': id, 'name': name});
    return Owner.fromString(result);
  }
}
