import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/components/user_name_view.dart';

class ScheduledMessageDetailsChatHeader extends StatelessWidget {

    const ScheduledMessageDetailsChatHeader(
        this.channel,
        this.message
    );

    final Channel channel;
    final ScheduledMessage message;

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
                children: <Widget>[
                    if (channel.isOutsidePublisher)
                        Text(
                            channel.name,
                            style: TextStyle(
                                color: globals.Colors.orange,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600
                            )
                        )
                    else
                        UserNameView(
                            message.from,
                            textStyle: TextStyle(
                                color: globals.Colors.orange,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600
                            )
                        ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(2.0),
                            child: Container(
                                width: 58,
                                height: 16,
                                color: globals.Colors.lightGray,
                                child: Center(
                                    child: Text(
                                        allTranslations.text('chat_scheduled'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: globals.Colors.white,
                                            fontSize: 10.0,
                                        )
                                    )
                                )
                            ),
                        ),
                    ),
                    Expanded(
                        child: Text(
                            DateFormat('hh:mm a')
                                .format(DateTime.parse(message.scheduledTime).toLocal()),
                            style: TextStyle(
                                color: globals.Colors.lightGray,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400
                            ),
                        ),
                    )
                ],
            )
        );
    }
}
