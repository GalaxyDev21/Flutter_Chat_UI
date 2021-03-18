import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/components/user_name_view.dart';

class ChatMessageHeader extends StatelessWidget {
    
    const ChatMessageHeader(this.message, {this.channel});

    final Message message;
    final Channel channel;

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
                children: <Widget>[
                    if (UserController.currentUser.uid == message.from)
                        Text(
                            allTranslations.text('chat_you'),
                            style: TextStyle(
                                color: globals.Colors.black,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600
                            ),
                        )
                    else if (message.from == 'outsidePublisher')
                        Text(
                            channel.name,
                            style: TextStyle(
                                color: globals.Colors.black,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600
                            ),
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
                    const Padding(padding: EdgeInsets.only(right: 6)),
                    if (ChatListController.isScheduledMessage(message))
                        Padding(
                        padding: const EdgeInsets.only(right: 6),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(2.0),
                                child: Container(
                                    width: 58,
                                    height: 16,
                                    color: globals.Colors.lightGray,
                                    child: Center(
                                        child: Text(allTranslations.text('chat_scheduled'),
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
                                .format(message.dateCreated.toLocal()),
                            style: TextStyle(
                                color: globals.Colors.lightGray,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400
                            ),
                        ),
                    )
                ],
            ),
        );
    }
}
