import 'package:flutter/material.dart';
import 'package:organizer/controllers/chat/message_reminder_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/handlers/chat_message_builder_handler.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/mybot_header.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/mybot_message_builder.dart';
import 'package:organizer/views/chat/chat_components/bubble.dart';
import 'package:organizer/views/chat/insert/set_message_reminder.dart';
import 'package:organizer/views/components/bot_avatar.dart';
import 'package:organizer/views/components/chat_button.dart';

class MessageReminderBuilder extends MybotMessageBuilder {

    @override
    String get type {
        switch(attributes['botMessageType']) {
            case MybotMessageTypes.messageReminderReady:
                return MybotMessageTypes.messageReminderReady;
            case MybotMessageTypes.messageReminderSent:
                return MybotMessageTypes.messageReminderSent;
            case MybotMessageTypes.messageReminderPr:
                return MybotMessageTypes.messageReminderPr;
            case MybotMessageTypes.messageReminderDeleted:
                return MybotMessageTypes.messageReminderDeleted;
            default:
                throw 'error in getting MessageReminder botMessageType';
        }
    }

    MessageReminderBuilder({
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
            attributes: attributes,
            // sid: ,
            // channelSid: 
        );
    }

   final MessageReminderController _messageReminderController = MessageReminderController();
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
                                                index: index,
                                                builderHandler: builderHandler,
                                            ),
                                        ),
                                    )
                                ),
                                if (type == MybotMessageTypes.messageReminderPr)
                                    ... [
                                        Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: MyChatButton(
                                                text:  allTranslations.text('prayer_reminder_view'),
                                                color: globals.Colors.orange,
                                                highlightColor: globals.Colors.lightOrange,
                                                onPressed: () { 
                                                    builderHandler.onTapReply(index, messageSid: attributes['originalMessageSid']);
                                                },
                                            ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: MyChatButton(
                                                text:  allTranslations.text('prayer_reminder_snooze'),
                                                color: globals.Colors.orange,
                                                highlightColor: globals.Colors.lightOrange,
                                                onPressed: () { 
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute<void>(
                                                            builder: (BuildContext context) =>
                                                                SetMessageReminder(
                                                                    message: Message(sid:attributes['originalMessageSid'],
                                                                    channelSid:attributes['channelSid']
                                                                )
                                                            )
                                                        )
                                                    );
                                                },
                                            ),
                                        )
                                    ] ,
                                if (type != MybotMessageTypes.messageReminderPr)
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: MyChatButton(
                                        text: type == MybotMessageTypes.messageReminderDeleted
                                            ? allTranslations.text('chat_set_reminder_cancelled')
                                            : allTranslations.text('chat_set_reminder_cancel'),
                                        color: type == MybotMessageTypes.messageReminderSent || type == MybotMessageTypes.messageReminderDeleted
                                            ? globals.Colors.lightGray : globals.Colors.orange,
                                        highlightColor: type == MybotMessageTypes.messageReminderSent || type == MybotMessageTypes.messageReminderDeleted
                                            ? globals.Colors.lightGray : globals.Colors.lightOrange,
                                        onPressed: () {
                                            if (type == MybotMessageTypes.messageReminderSent || type == MybotMessageTypes.messageReminderDeleted)
                                                return null;
                                            return _messageReminderController.deleteMsgReminder(documentId);
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