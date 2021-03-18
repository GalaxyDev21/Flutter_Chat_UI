import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/handlers/chat_message_builder_handler.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/models/chat/polling_message_model.dart';
import 'package:organizer/pojo/polling_answer.dart';
import 'package:organizer/pojo/polling_question.dart';
import 'package:organizer/views/chat/chat_components/bubble.dart';
import 'package:organizer/views/chat/chat_components/chat_message/chat_message_header.dart';
import 'package:organizer/views/chat/chat_components/chat_message_avatar.dart';
import 'package:organizer/views/chat/chat_components/polling_message/polling_message_builder.dart';
import 'package:provider/provider.dart';

class MultipleChoiceOneBuilder extends PollingMessageBuilder {
    @override
    String get type => PollingMessageTypes.multipleChoiceOne;

    MultipleChoiceOneBuilder({
        Channel channel,
        Message message,
        int totalMessageCount,
        bool hasChatMessageAvatar,
        bool isLast,
        int index,
        int readCount,
        ChatMessageBuilderHandler builderHandler,
        bool isHighlight
    }) : super(
        channel: channel,
        message: message,
        totalMessageCount: totalMessageCount,
        hasChatMessageAvatar: hasChatMessageAvatar,
        isLast: isLast,
        readCount: readCount,
        index: index,
        builderHandler: builderHandler,
        isHighlight: isHighlight,
    );
    
    @override
    Widget builder(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    ChatMessageAvatar(
                        channel: channel,
                        message: message,
                        hasChatMessageAvatar: hasChatMessageAvatar,
                        index: index,
                        builderHandler: builderHandler
                    ),
                    Expanded(
                        child: MultiProvider(
                            providers: [
                                StreamProvider<PollingQuestion>(
                                    create: (_) => PollingMessageModel(channelSid: channelSid).watchPollingQeustion(pollingId),
                                    initialData: PollingQuestion(
                                        isStopped: false,
                                        type: 'open-ended',
                                        question: 'Loading ...',
                                    ),
                                ),
                                StreamProvider<List<PollingAnswer>>(
                                    create: (_) => PollingMessageModel(channelSid: channelSid).watchPollingAnswers(pollingId),
                                    initialData: const <PollingAnswer>[],
                                )
                            ],
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                    if (hasChatMessageAvatar)
                                        ChatMessageHeader(message, channel: channel),
                                    ClipRect(
                                        child: Slidable(
                                            actionPane: const SlidableDrawerActionPane(),
                                            child: Padding(
                                                padding: const EdgeInsets.fromLTRB(2, 2, 4, 4),
                                                child: Bubble(
                                                    message: message,
                                                    isLast: isLast,
                                                    readCount: readCount,
                                                    outChannelSid: channel.isOutsidePublisher ? channel.info.sid : null,
                                                    index: index,
                                                    builderHandler: builderHandler,
                                                    isHighlight: isHighlight
                                                ),
                                            ),
                                            actions: <Widget>[
                                                if (!ChatListController.isDeleted(message.attributes)
                                                    && !ChatListController.isHidden(message.attributes)
                                                    && !ChatListController.isBlocked(message.attributes)
                                                    && message.type != MessageTypes.invite)
                                                    IconSlideAction(
                                                        caption: allTranslations.text('chat_reply'),
                                                        color: Colors.transparent,
                                                        icon: Icons.reply,
                                                        foregroundColor: globals.Colors.brownGray,
                                                        onTap: () => builderHandler.onReply(index),
                                                    ),
                                            ]
                                        )
                                    ),
                                ],
                            )
                        )
                    )
                ]
            )
        );
    }
}