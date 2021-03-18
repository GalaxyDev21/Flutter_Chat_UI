import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:organizer/common/navigator_key.dart';
import 'package:organizer/common/route.dart';
import 'package:organizer/models/chat/member_model.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/chat/chat_self/chat_self.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ChatSelfRoute extends MyRoute {
    static const String _path = '/chatSelf/:channelSid';
    static String buildPath(String channelSid) => _path.replaceFirst(':channelSid', channelSid);

    @override
    String get path => _path;

    @override
    GlobalKey<NavigatorState> navigatorKey = MyNavigatorKeys.chatKey;
    
    @override
    final bool clearStack = false;

    @override
    final TransitionType transition = TransitionType.native;

    @override
    Widget handlerFunc(BuildContext context, Map<String, dynamic> params) =>
        MultiProvider(
            providers: <SingleChildWidget>[
                StreamProvider<List<Message>>.value( 
                    value: Message.watchMessages(params['channelSid'][0]) 
                ),
                StreamProvider<List<Member>>.value(
                    value: Member.watchMembers(params['channelSid'][0]) 
                ),
                Provider<String>.value(value: null)
            ],
            child: ChatSelf(
                channelSid: params['channelSid'][0]
            ),
        ); 
}