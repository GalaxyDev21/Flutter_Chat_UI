import 'package:flutter/material.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/chat/chat_components/chat_indexed_list_view.dart';
import 'package:organizer/views/chat/chat_components/date_splitter_chat_message.dart';
import 'package:provider/provider.dart';

class DateSplitterOnChatScreen extends StatelessWidget {
    
    const DateSplitterOnChatScreen({
        @required this.messages
    });

    final List<Message> messages;

    @override
    Widget build(BuildContext context) {
        final ChatIndexedScrollController chatIndexedScrollController = Provider.of<ChatIndexedScrollController>(context);
        if (messages != null &&
            messages.isNotEmpty &&
            chatIndexedScrollController.startIndex != 0 &&
            chatIndexedScrollController.endIndex != messages.length
        ) {
            final DateTime dateTime = messages[chatIndexedScrollController.endIndex].dateCreated.toLocal();
            return DateSplitterOnChatMessage(dateTime: dateTime);
        }
        return Container();
    }
}