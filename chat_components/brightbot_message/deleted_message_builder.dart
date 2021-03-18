import 'package:flutter/material.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/mybot_header.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/mybot_message_builder.dart';
import 'package:organizer/views/chat/chat_components/bubble.dart';
import 'package:organizer/views/chat/chat_components/chat_indexed_list_view.dart';
import 'package:organizer/views/components/bot_avatar.dart';

class DeletedMessageBuilder extends MybotMessageBuilder {
    @override
    String get type => MybotMessageTypes.deleted;

    DeletedMessageBuilder({
        String body,
        Map<String, dynamic> attributes,
        DateTime dateCreated
    }) : super(body: body, attributes: attributes, dateCreated: dateCreated) {
        message = Message(
            from: 'system',
            body: body,
            attributes: attributes
        );
    }
    
    Message message;
    String get visibleTo => attributes['visibleTo'][0];
    
    @override
    Widget builder(BuildContext context, {ChatIndexedScrollController listScrollController, int totalMessageCount}) {
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
                                                builderHandler: null,
                                                index: null,
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