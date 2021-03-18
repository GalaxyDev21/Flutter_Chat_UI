
import 'package:flutter/material.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/handlers/chat_message_builder_handler.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/mybot_header.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/mybot_message_builder.dart';
import 'package:organizer/views/chat/chat_components/bubble.dart';
import 'package:organizer/views/components/bot_avatar.dart';

class BotChatMessageBuilder extends MybotMessageBuilder {

    @override
    String get type => attributes['botMessageType'];

    BotChatMessageBuilder({
        String body,
        Map<String, dynamic> attributes,
        Channel channel,
        DateTime dateCreated,
        int index,
        ChatMessageBuilderHandler builderHandler,
    }) : super(
        body: body,
        attributes: attributes,
        channel: channel,
        dateCreated: dateCreated,
        index: index,
        builderHandler: builderHandler
    ) {
        message = Message(
            from: 'system',
            body: body,
            attributes: attributes
        );
    }

    Message message;
    String get documentId => attributes['documentId'];
    String get visibleTo => attributes['visibleTo'][0];
    
    @override
    Widget builder(BuildContext context) {
        if (visibleTo == UserController.currentUser.uid) {
            return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    MyBotAvatar(),
                    Container(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                MybotHeader(dateCreated),
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: ClipRect(
                                        child: Padding(
                                            padding: const EdgeInsets.fromLTRB(2, 2, 4, 4),
                                            child: Bubble(
                                                message: message,
                                                isLast: true,
                                                readCount: 0,
                                                outChannelSid: channel.isOutsidePublisher ? channel.info.sid : null,
                                                index: index,
                                                builderHandler: builderHandler,
                                                isHighlight: isHighlight
                                            ),
                                        ),
                                    )
                                ),
                            ],
                        )
                    )
                ]
            );
        }
        return Container();
    }
}