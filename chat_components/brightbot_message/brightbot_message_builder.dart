import 'package:flutter/material.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/handlers/chat_message_builder_handler.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/bot_chat_message_builder.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/deleted_message_builder.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/message_reminder_builder.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/scheduled_message_builder.dart';
import 'package:organizer/views/chat/chat_components/prayer_reminder_message/prayer_reminder_collect_message_builder.dart';
import 'package:organizer/views/chat/chat_components/prayer_reminder_message/prayer_reminder_recall_message_builder.dart';
import 'package:organizer/views/chat/chat_components/prayer_reminder_message/prayer_reminder_remind_message_builder.dart';
import 'package:organizer/views/chat/chat_components/prayer_reminder_message/prayer_reminder_set_message_builder.dart';

abstract class MybotMessageType {
    String get type;
}

abstract class MybotMessageBuilder implements MybotMessageType {
    Map<String, dynamic> attributes;
    String body;
    Channel channel;
    DateTime dateCreated;
    ChatMessageBuilderHandler builderHandler;
    int index;
    bool isHighlight;
    MybotMessageBuilder({
        @required this.attributes,
        @required this.body,
        @required this.channel,
        @required this.dateCreated,
        this.index,
        this.builderHandler,
        this.isHighlight = false
    });
    
    Widget builder(BuildContext context);
    
    factory MybotMessageBuilder.fromAttributes({
        @required Map<String, dynamic> attributes,
        @required String body,
        @required Channel channel,
        @required DateTime dateCreated, 
        String messageSid,
        int index,
        @required ChatMessageBuilderHandler builderHandler,
        bool isHighlight,
        
    }) {
        switch (attributes['botMessageType']) {
            case MybotMessageTypes.text:
                return BotChatMessageBuilder(attributes: attributes, body: body, channel: channel, dateCreated: dateCreated, index: index, builderHandler: builderHandler);
            case MybotMessageTypes.scheduled:
                return ScheduledMessageBuilder(attributes: attributes, body: body, channel: channel, dateCreated: dateCreated, index: index);
                break;
            case MybotMessageTypes.deleted:
                return DeletedMessageBuilder(attributes: attributes, body: body, dateCreated: dateCreated);
                break;
            case MybotMessageTypes.prayerReminderSet:
                return PrayerReminderSetMessageBuilder(attributes: attributes, body: body,dateCreated: dateCreated, messageSid: messageSid);
                break;  
            case MybotMessageTypes.prayerReminderCollect:
                return PrayerReminderCollectMessageBuilder(attributes: attributes, body: body, dateCreated: dateCreated, messageSid: messageSid, index: index, builderHandler: builderHandler, isHighlight: isHighlight );
                break;
            case MybotMessageTypes.prayerReminderRecall:
                return PrayerReminderRecallMessageBuilder(attributes: attributes, body: body, dateCreated: dateCreated, messageSid: messageSid, index: index, builderHandler: builderHandler, isHighlight: isHighlight );
                break; 
            case MybotMessageTypes.prayerReminderPray:
                return PrayerReminderPrayMessageBuilder(channelSid:channel.info.sid,attributes: attributes, body: body, dateCreated: dateCreated, messageSid: messageSid, index: index, builderHandler: builderHandler, isHighlight: isHighlight);
                break;
            case MybotMessageTypes.prayComplete:
                return PrayerReminderPrayMessageBuilder(prayComplete: true, channelSid:channel.info.sid,attributes: attributes, body: body, dateCreated: dateCreated, messageSid: messageSid, index: index, builderHandler: builderHandler, isHighlight: isHighlight);
                break;
            case MybotMessageTypes.collectionComplete: 
                return PrayerReminderCollectMessageBuilder(attributes: attributes, body: body, dateCreated: dateCreated, messageSid: messageSid, collectionComplete: true, index: index, builderHandler: builderHandler, isHighlight: isHighlight);
                break;
            case MybotMessageTypes.recallComplete: 
                return PrayerReminderRecallMessageBuilder(attributes: attributes, body: body, dateCreated: dateCreated, messageSid: messageSid, recallComplete: true, index: index, builderHandler: builderHandler, isHighlight: isHighlight);
                break;
            case MybotMessageTypes.reminderStopped: 
                return PrayerReminderSetMessageBuilder(attributes: attributes, body: body, dateCreated: dateCreated, messageSid: messageSid, reminderStopped: true);
                break;
            case MybotMessageTypes.messageReminderReady:
                return MessageReminderBuilder(attributes: attributes, body: body, dateCreated: dateCreated, index: index, builderHandler: builderHandler);
                break;
            case MybotMessageTypes.messageReminderSent:
                return MessageReminderBuilder(attributes: attributes, body: body, dateCreated: dateCreated, index: index, builderHandler: builderHandler);
                break;
            case MybotMessageTypes.messageReminderPr:
                return MessageReminderBuilder(attributes: attributes, body: body, dateCreated: dateCreated, index: index, builderHandler: builderHandler);
                break;
            case MybotMessageTypes.messageReminderDeleted:
                return MessageReminderBuilder(attributes: attributes, body: body, dateCreated: dateCreated, index: index, builderHandler: builderHandler);
                break;
            default:
                return null;
        }
    }
}