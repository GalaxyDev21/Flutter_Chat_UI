import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:organizer/common/navigator_key.dart';
import 'package:organizer/common/route.dart';
import 'package:organizer/views/chat/chat_list/chat_list.dart';

class ChatListRoute extends MyRoute {
    static const String _path = '/chatList';
    static String buildPath() => _path;

    @override
    String get path => _path;

    @override
    GlobalKey<NavigatorState> navigatorKey = MyNavigatorKeys.chatKey;

    @override
    final bool clearStack = false;

    @override
    final TransitionType transition = TransitionType.native;

    @override
    Widget handlerFunc(BuildContext context, Map<String, dynamic> params) => ChatList();
}