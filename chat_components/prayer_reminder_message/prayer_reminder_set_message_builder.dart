import 'package:flutter/material.dart';
import 'package:organizer/controllers/chat/prayer_reminder_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/mybot_header.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/mybot_message_builder.dart';
import 'package:organizer/views/chat/chat_components/bubble.dart';
import 'package:organizer/views/chat/chat_components/chat_indexed_list_view.dart';
import 'package:organizer/views/components/bot_avatar.dart';
import 'package:organizer/views/components/chat_button.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:organizer/views/components/progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:organizer/globals.dart' as globals;


class PrayerReminderSetMessageBuilder extends MybotMessageBuilder {
    @override
    String get type => MybotMessageTypes.prayerReminderSet;
    String channelSid;
    String messageSid;
    final bool reminderStopped; 
    PrayerReminderSetMessageBuilder({
        String body,
        Map<String, dynamic> attributes,
        this.messageSid,
        DateTime dateCreated,
        this.reminderStopped = false,
    }) : super(body: body, attributes: attributes, dateCreated: dateCreated) {
        message = Message(
            from: 'system',
            body: body,
            attributes: attributes
        );
        channelSid = attributes['channelSid'];
    }
    
    Message message;
    String get visibleTo => attributes['visibleTo'][0];
    
    @override
    Widget builder(BuildContext context, {int totalMessageCount,dynamic listScrollController}) {
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
                                            ),
                                        ),
                                    )
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: AbsorbPointer(
                                        absorbing: reminderStopped ,
                                        child: MyChatButton(
                                            text: !reminderStopped ?
                                                allTranslations.text('chat_prayer_points_stop_reminder'):
                                                allTranslations.text('chat_prayer_points_stopped_reminder'),
                                            color: !reminderStopped ? 
                                                globals.Colors.orange:
                                                globals.Colors.lightGray,
                                            onPressed: () async {
                                                // PrayerReminderController.stopPrayerReminderFromSid(channelSid,messageSid);
                                                bool decision = await showCancelAndOkDialog(
                                                    context,
                                                    title:'prayer_reminder_stop',
                                                    content:'prayer_reminder_stop_sure',
                                                    okText: 'prayer_reminder_stop_button');
                                                if(decision){
                                                    showActivityIndicator();
                                                    await PrayerReminderController(channelSid).stopPrayerReminder();
                                                    hideActivityIndicator();
                                                }
                                            },
                                        ) ,
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