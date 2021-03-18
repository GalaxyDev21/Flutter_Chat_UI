import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:organizer/views/components/future_builder.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebView extends StatefulWidget {
    CustomWebView({this.initialUrl});
    @override
    _CustomWebViewState createState() => _CustomWebViewState();
    
    String initialUrl;
}

class _CustomWebViewState extends State<CustomWebView> {
    WebViewController _controller;
    
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
            ),
            body: SafeArea(
                child: WebView(
                    initialUrl: widget.initialUrl,
                    onWebViewCreated: (WebViewController webViewController) {
                        _controller = webViewController;
                    },
                    javascriptMode: JavascriptMode.unrestricted,
                )
            ),
        );
    }
}

class CustomWebView2 extends StatefulWidget {
  CustomWebView2({this.initialUrl});
  @override
  _CustomWebViewState2 createState() => _CustomWebViewState2();

  String initialUrl;
}

class _CustomWebViewState2 extends State<CustomWebView2> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
          child: WebView(
            initialUrl: widget.initialUrl,
            javascriptMode: JavascriptMode.unrestricted,
            gestureRecognizers: [
              Factory(() => PlatformViewVerticalGestureRecognizer()),
            ].toSet(),
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
          )
      ),
    );
  }
}

///https://stackoverflow.com/questions/57069716/scrolling-priority-when-combining-horizontal-scrolling-with-webview/57150906#57150906
class PlatformViewVerticalGestureRecognizer
    extends VerticalDragGestureRecognizer {
  PlatformViewVerticalGestureRecognizer({PointerDeviceKind kind})
      : super(kind: kind);

  Offset _dragDistance = Offset.zero;

  @override
  void addPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
  }

  @override
  void handleEvent(PointerEvent event) {
    _dragDistance = _dragDistance + event.delta;
    if (event is PointerMoveEvent) {
      final double dy = _dragDistance.dy.abs();
      final double dx = _dragDistance.dx.abs();

      if (dy > dx && dy > kTouchSlop) {
        // vertical drag - accept
        resolve(GestureDisposition.accepted);
        _dragDistance = Offset.zero;
      } else if (dx > kTouchSlop && dx > dy) {
        // horizontal drag - stop tracking
        stopTrackingPointer(event.pointer);
        _dragDistance = Offset.zero;
      }
    }
  }

  @override
  String get debugDescription => 'horizontal drag (platform view)';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}