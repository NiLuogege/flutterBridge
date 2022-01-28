import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';

import 'l.dart';

typedef MethodHandler = dynamic Function(dynamic params);

class FlutterBridge {
  static const String CHANNEL_NAME = "flutterBridge/core";
  MethodChannel _channel = new MethodChannel(CHANNEL_NAME);

  HashMap<String, MethodHandler> _methodMap = HashMap<String, MethodHandler>();

  FlutterBridge._() {
    _channel.setMethodCallHandler(onMethodCall);
  }

  static final FlutterBridge _instance = FlutterBridge._();

  static FlutterBridge get instance {
    return _instance;
  }

  openLog(bool open) {
    L.toggle = open;
    callNative("toggleLog", params: {"toggle": open});
  }

  MethodChannel getChannel() {
    return _channel;
  }

  Future<T> callNative<T>(String methodName,
      {Map<String, Object>? params}) async {
    return await _channel.invokeMethod(methodName, params);
  }

  // 注册方法
  void registerHandler(String methodName, MethodHandler methodHandle) {
    _methodMap[methodName] = methodHandle;
  }

  // 反注册方法
  MethodHandler? unregisterHandler(String methodName) {
    return _methodMap.remove(methodName);
  }

  Future<dynamic> onMethodCall(MethodCall call) async {
    L.log('method=${call.method} arguments=${call.arguments}');
    String methodName = call.method;
    dynamic  params = call.arguments;
    MethodHandler? methodHandler = _methodMap[methodName];
    if (methodHandler != null) {
      return methodHandler(params);
    } else {
      return "methodNotImplemented"; //方法没实现
    }
  }
}