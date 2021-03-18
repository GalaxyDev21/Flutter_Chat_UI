import 'package:flutter/material.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/handlers/chat_message_builder_handler.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/components/oval_avatar.dart';

class ChatMessageAvatar extends StatelessWidget {
    
    const ChatMessageAvatar({
        @required this.channel,
        @required this.message,
        @required this.hasChatMessageAvatar,
        @required this.index,
        @required this.builderHandler
    });

    final Channel channel;
    final Message message;
    final bool hasChatMessageAvatar;
    final int index;
    final ChatMessageBuilderHandler builderHandler;

    @override
    Widget build(BuildContext context) {
        if (hasChatMessageAvatar)
            return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: (message.from == 'outsidePublisher')
                    ? MyOvalAvatar.fromChannel(channel, iconRadius: 20)
                    : MyOvalAvatar.ofUser(
                        message.from,
                        iconRadius: 20,
                        onTap: () => builderHandler.onUser(index)
                    ),
                    
            );
        else
            return const Padding(
                padding: EdgeInsets.only(right: 52),
            );
    }
}
