import 'package:flutter/cupertino.dart' as lifecycle_event_handler;
import 'package:flutter/foundation.dart';

class LifecycleEventHandler
    extends lifecycle_event_handler.WidgetsBindingObserver {
  final AsyncCallback? resumeCallBack;
  final AsyncCallback? suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(
      lifecycle_event_handler.AppLifecycleState state) async {
    switch (state) {
      case lifecycle_event_handler.AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack!();
        }
        break;
      case lifecycle_event_handler.AppLifecycleState.inactive:
      case lifecycle_event_handler.AppLifecycleState.paused:
      case lifecycle_event_handler.AppLifecycleState.detached:
        if (suspendingCallBack != null) {
          await suspendingCallBack!();
        }
        break;
    }
  }
}
