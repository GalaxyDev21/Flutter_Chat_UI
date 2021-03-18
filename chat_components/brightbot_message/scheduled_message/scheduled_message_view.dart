import 'package:flutter/material.dart';
import 'package:organizer/controllers/chat/scheduled_message_controller.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/scheduled_message/scheduled_message_details.dart';
import 'package:organizer/views/components/future_builder.dart';

class ScheduledMessageView extends StatelessWidget {

    ScheduledMessageView({
        @required this.channel,
        @required this.documentId
    });

    final Channel channel;
    final String documentId;
    final ScheduledMessageController _scheduledMsgController = ScheduledMessageController();
    final List<ScheduledMessage> sortedMessages = <ScheduledMessage>[];

    @override
    Widget build(BuildContext context) {
        return Container(
            color: Colors.white,
            child: MyFutureBuilder<List<ScheduledMessage>>.bounce(
                // private chat is restricted to the use of upload default folder only.
                future: _scheduledMsgController.getScheduledMessages(documentId),
                builder: (BuildContext context, List<ScheduledMessage> messages) {
                    // sort scheduled message with "text" first
                    for (ScheduledMessage scheduledMsg in messages) {
                        if (scheduledMsg.type == 'text')
                            sortedMessages.insert(0, scheduledMsg);
                        else
                            sortedMessages.add(scheduledMsg);
                    }
                    return ScheduledMessageDetails(
                        channel: channel,
                        scheduledMessages: sortedMessages,
                    );
                }
            )
        );
    }
}

