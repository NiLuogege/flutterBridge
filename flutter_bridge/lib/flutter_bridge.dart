import 'dart:async';
import 'dart:ffi';

import 'package:flutter/services.dart';

import 'messages.dart';

typedef MethodHandler = String Function(Map<String, dynamic> params);
typedef MethodHandlerNoReturn = void Function(Map<String, dynamic> params);

class FlutterBridge extends FlutterRouterApi {
  FlutterBridge._();

  static final FlutterBridge _instance = FlutterBridge._();

  static FlutterBridge get instance {
    FlutterRouterApi.setup(_instance);
    return _instance;
  }

  var _methodMap = Map<String, dynamic>();

  /// 注册方法
  void registerHandler(String methodName, MethodHandler methodHandle) {
    _methodMap[methodName] = methodHandle;
  }

  void registerHandlerNoReturn(String methodName, MethodHandlerNoReturn methodHandle) {
    _methodMap[methodName] = methodHandle;
  }

  Future<String> callNative(String methodName, {Map<String, Object> params}) async {
    CallInfo cp = CallInfo();
    cp.methodName = methodName;
    cp.params = params;
    ResultInfo ri = await NativeRouterApi().callNative(cp);
    return ri.result;
  }

  callNativeNoReturn(String methodName, {Map<String, Object> params}) async {
    CallInfo cp = CallInfo();
    cp.methodName = methodName;
    cp.params = params;
    await NativeRouterApi().callNative(cp);
  }

  @override
  ResultInfo callFlutter(CallInfo callInfo) {
    String methodName = callInfo.methodName;
    Map<String, dynamic> params = Map<String, dynamic>.from(callInfo.params);
    dynamic methodHandler = _methodMap[methodName];
    if (methodHandler is MethodHandler) {
      String result = methodHandler(params);
      ResultInfo ri = ResultInfo();
      ri.result = result;
      return ri;
    } else if (methodHandler is MethodHandlerNoReturn) {
      ResultInfo ri = ResultInfo();
      return ri;
    }
  }
}
