import 'package:flutter/material.dart';
import 'package:organizer/controllers/chat/prayer_reminder_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/chat/handlers/chat_message_builder_handler.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/models/chat/prayer_reminder_model.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/mybot_message_builder.dart';
import 'package:organizer/views/chat/chat_components/prayer_reminder_message/prayer_reminder_collect.dart';
import 'package:provider/provider.dart';

class PrayerReminderRecallMessageBuilder extends MybotMessageBuilder {
    @override
    String get type => MybotMessageTypes.prayerReminderRecall;
    String channelSid;
    String messageSid;
    final bool recallComplete;
    PrayerReminderRecallMessageBuilder({
        this.channelSid,
        String body,
        Map<String, dynamic> attributes,
        this.messageSid,
        DateTime dateCreated,
        this.recallComplete = false,
        int index,
        @required ChatMessageBuilderHandler builderHandler,
        bool isHighlight
    }) : super(body: body, attributes: attributes, dateCreated: dateCreated, index: index, builderHandler: builderHandler, isHighlight: isHighlight) {
        message = Message(
            from: 'system',
            body: body,
            attributes: attributes
        );
        channelSid = attributes['channelSid'];
    }
    
    Message message;
    
    List<String> get visibleTo => List<String>.from(attributes['visibleTo']);
    
    @override
    Widget builder(BuildContext context, {int totalMessageCount,dynamic listScrollController}) {
        final Widget recallWidget = PrayerReminderCollect(
            channelSid: channelSid,
            message: message,
            dateCreated: dateCreated,
            collectionComplete:recallComplete,
            index: index,
            builderHandler: builderHandler,
            isHighlight: isHighlight,
            isRecall: true,
        );
        if (visibleTo.contains(UserController.currentUser.uid))
            return !recallComplete ?
                MultiProvider(
                    providers: [
                        StreamProvider<CollectorAnswers>(
                            create: (BuildContext context ) => PrayerReminderController.answerSnapshot(channelSid, UserController.currentUser.uid, attributes['prId']),
                            initialData: CollectorAnswers([]),
                        ),
                        StreamProvider<MembersAnswered>(
                            create: (BuildContext context) => PrayerReminderController.membersAnsweredSnapshot(channelSid, attributes['prId']),
                            initialData: MembersAnswered([]), 
                        )
                    ],
                    child: recallWidget
                )
                : recallWidget;
        return Container();
    }
}