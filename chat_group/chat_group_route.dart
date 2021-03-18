import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:organizer/common/navigator_key.dart';
import 'package:organizer/common/route.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/member_model.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/chat/chat_group/chat_group.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ChatGroupRoute extends MyRoute {
    static const String _path = '/chatGroup/:channelSid';
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
  
    @override
    Widget handlerFunc(BuildContext context, Map<String, dynamic> params) {
        bool isOutsidePublisher = false;
        if (Provider.of<CurrentUserController>(context, listen: false).userInfo != null && Provider.of<CurrentUserController>(context, listen: false).userInfo.outsidePublisherOf != null)
            isOutsidePublisher = Provider.of<CurrentUserController>(context, listen: false).userInfo.outsidePublisherOf.contains(params['channelSid'][0]);
        if (isOutsidePublisher)
            return MultiProvider(
                providers: [
                    StreamProvider<List<Message>>(
                        create: (_) => Message.watchOutsidePublisherMessages(params['channelSid'][0]),
                        initialData: const <Message>[],
                    ),
                    Provider<List<Member>>(
                        create: (_) => const <Member>[],
                    ),
                    Provider<String>.value(value: null)
                ],
                child: ChatGroup(
                    channelSid: params['channelSid'][0]
                )
            );
        return MultiProvider(
            providers: <SingleChildWidget>[
                StreamProvider<List<Message>>.value( 
                    value: Message.watchMessages(params['channelSid'][0]) 
                ),
                StreamProvider<List<Member>>.value(
                    value: Member.watchMembers(params['channelSid'][0])
                ),
                StreamProvider<Channel>.value(
                    value: UserController.watchChannel(params['channelSid'][0])
                ),
                Provider<String>.value(value: null)
            ],
            child: ChatGroup(
                channelSid: params['channelSid'][0]
            ),
        ); 
    }
}