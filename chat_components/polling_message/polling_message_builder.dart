import 'package:flutter/material.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/handlers/chat_message_builder_handler.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/chat/chat_components/polling_message/multiple_choice_multi_builder.dart';
import 'package:organizer/views/chat/chat_components/polling_message/multiple_choice_one_builder.dart';
import 'package:organizer/views/chat/chat_components/polling_message/open_ended_builder.dart';

abstract class PollingMessageType {
    String get type;
}

abstract class PollingMessageBuilder implements PollingMessageType {
    
    final Channel channel;
    final Message message;
    final int totalMessageCount;
    final bool hasChatMessageAvatar;
    final bool isLast;
    final int index;
    final int readCount;
    final ChatMessageBuilderHandler builderHandler;
    final bool isHighlight;

    PollingMessageBuilder({
        @required this.channel,
        @required this.message,
        this.totalMessageCount,
        this.hasChatMessageAvatar = true,
        this.isLast = true,
        this.readCount = 0,
        @required this.index,
        @required this.builderHandler,
        this.isHighlight = false
    });
    
    String get channelSid => message.attributes['channelSid'];
    String get pollingId => message.attributes['pollingId'];
    
    Widget builder(BuildContext context);
    
    factory PollingMessageBuilder.fromMessage({
        @required final Channel channel,
        @required final Message message,
        final int totalMessageCount,
        final bool hasChatMessageAvatar = true,
        final bool isLast = true,
        final int readCount = 0,
        @required final int index,
        @required final ChatMessageBuilderHandler builderHandler,
        final bool isHighlight,
    }) {
        switch (message.attributes['pollingType']) {
            case PollingMessageTypes.multipleChoiceOne:
                return MultipleChoiceOneBuilder(
                    channel: channel,
                    message: message,
                    totalMessageCount: totalMessageCount,
                    hasChatMessageAvatar: hasChatMessageAvatar,
                    isLast: isLast,
                    readCount: readCount,
                    index: index,
                    builderHandler: builderHandler,
                    isHighlight: isHighlight
                );
                break;
            case PollingMessageTypes.multipleChoiceMulti:
                return MultipleChoiceMultiBuilder(
                    channel: channel,
                    message: message,
                    totalMessageCount: totalMessageCount,
                    hasChatMessageAvatar: hasChatMessageAvatar,
                    isLast: isLast,
                    readCount: readCount,
                    index: index,
                    builderHandler: builderHandler,
                    isHighlight: isHighlight
                );
                break;
            case PollingMessageTypes.openEnded:
                return OpenEndedBuilder(
                    channel: channel,
                    message: message,
                    totalMessageCount: totalMessageCount,
                    hasChatMessageAvatar: hasChatMessageAvatar,
                    isLast: isLast,
                    readCount: readCount,
                    index: index,
                    builderHandler: builderHandler,
                    isHighlight: isHighlight
                );
                break;
            default:
                return null;
        }
    }
}