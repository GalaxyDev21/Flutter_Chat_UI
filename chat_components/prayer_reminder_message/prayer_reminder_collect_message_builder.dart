import 'package:flutter/material.dart';
import 'package:organizer/controllers/chat/prayer_reminder_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/chat/handlers/chat_message_builder_handler.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/models/chat/prayer_reminder_model.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/mybot_message_builder.dart';
import 'package:organizer/views/chat/chat_components/prayer_reminder_message/prayer_reminder_collect.dart';
import 'package:provider/provider.dart';
 
class PrayerReminderCollectMessageBuilder extends MybotMessageBuilder {
    @override
    String get type => MybotMessageTypes.prayerReminderCollect;
    String channelSid;
    String messageSid;
    bool collectionComplete;
    final Map<String,dynamic> attributes;
    PrayerReminderCollectMessageBuilder({
        this.attributes,
        this.channelSid,
        String body,
        this.messageSid,
        DateTime dateCreated,
        this.collectionComplete = false,
        int index,
        @required ChatMessageBuilderHandler builderHandler,
        bool isHighlight
    }) : super(body: body, attributes: attributes, dateCreated: dateCreated, index: index, builderHandler: builderHandler, isHighlight: isHighlight) {
        message = Message(
            from: 'system',
            body: body,
            attributes: attributes,
            sid: messageSid,
            channelSid: channelSid
        );
        channelSid = attributes['channelSid'];
    }
    
    Message message;

    String get visibleTo => attributes['visibleTo'][0];
    
    @override
    Widget builder(BuildContext context, {int totalMessageCount,dynamic listScrollController}) {
        if (attributes['prayTime'] == null)
            collectionComplete = true;
        Widget child = PrayerReminderCollect(
                channelSid: channelSid,
                message: message,
                dateCreated: dateCreated,
                collectionComplete:collectionComplete,
                index: index,
                builderHandler: builderHandler,
                isHighlight: isHighlight,
            );
        if (collectionComplete) 
            return child;
        return StreamProvider<CollectorAnswers>(
            create: (BuildContext context ) => PrayerReminderController.answerSnapshot(channelSid, UserController.currentUser.uid, attributes['prId']),
            child: child,
            initialData: CollectorAnswers([]),
        );
    }
}