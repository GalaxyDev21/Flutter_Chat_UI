import 'package:flutter/material.dart';
import 'package:organizer/controllers/chat/scheduled_message_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/mybot_header.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/mybot_message_builder.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/scheduled_message/scheduled_message_view.dart';
import 'package:organizer/views/chat/chat_components/bubble.dart';
import 'package:organizer/views/chat/chat_components/chat_indexed_list_view.dart';
import 'package:organizer/views/components/bot_avatar.dart';
import 'package:organizer/views/components/chat_button.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ScheduledMessageBuilder extends MybotMessageBuilder {
    @override
    String get type => MybotMessageTypes.scheduled;

    ScheduledMessageBuilder({
        String body,
        Map<String, dynamic> attributes,
        Channel channel,
        DateTime dateCreated,
        int index
    }) : super(body: body, attributes: attributes, channel: channel, dateCreated: dateCreated, index:index) {
        message = Message(
            from: 'system',
            body: body,
            attributes: attributes
        );
    }
    ChatIndexedScrollController chatIndexedScrollController ;
    Message message;
    String get documentId => attributes['documentId'];
    String get visibleTo => attributes['visibleTo'][0];
    
    @override
    Widget builder(BuildContext context, {int totalMessageCount}) {
        chatIndexedScrollController = Provider.of<ChatIndexedScrollController>(context, listen:false);
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
                                                index: null,
                                                builderHandler: null,
                                            ),
                                        ),
                                    )
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: MyChatButton(
                                        text: allTranslations.text('chat_action_view_message'),
                                        onPressed: () async {
                                            
                                            final Tuple2<int, int> scheduledMessageIndexRange = await ScheduledMessageController().getScheduledMessageIndexRange(channel.info.sid, documentId, index);
                                            if (scheduledMessageIndexRange != null) {
                                                print(scheduledMessageIndexRange);
                                                chatIndexedScrollController.jumpToIndex(scheduledMessageIndexRange.item2);
                                                return;
                                            }
                                            else {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute<bool>(
                                                        builder: (BuildContext context) => ScheduledMessageView(
                                                            channel: channel,
                                                            documentId: documentId
                                                        )
                                                    ),
                                                );
                                            }
                                        },
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