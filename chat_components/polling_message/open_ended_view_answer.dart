
import 'package:flutter/material.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/pojo/polling_answer.dart';
import 'package:organizer/views/chat/chat_components/bubble.dart';
import 'package:organizer/views/chat/chat_components/chat_message/chat_message_header.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet.dart';
import 'package:organizer/views/components/oval_avatar.dart';

class OpenEndedViewAnswer extends MyFullscreenBottomSheet {

    OpenEndedViewAnswer({
        @required this.answers
    });

    final List<PollingAnswer> answers;

    @override
    State<OpenEndedViewAnswer> createState() => OpenEndedViewAnswerState();
}

class OpenEndedViewAnswerState extends MyFullscreenBottomSheetState<OpenEndedViewAnswer> {

    final List<Message> _messages = <Message>[];
    final ScrollController scrollController = ScrollController();

    @override
    void initState() {
        super.initState();
        mainTitle = widget.answers.isEmpty || widget.answers.length == 1
            ? '${widget.answers.length} ${allTranslations.text('chat_polling_message_open_ended_answer')}'
            : '${widget.answers.length} ${allTranslations.text('chat_polling_message_open_ended_answers')}';
        _messages.addAll(
            widget.answers.map((PollingAnswer answer) => answer.toOpenEndedMessage()).toList()
        );
    }

    Widget _buildItem(int index) {
        final Message message = _messages[index];
        return Container(
            margin: const EdgeInsets.only(left: 12, top: 12 , right: 12, bottom: 0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    MyOvalAvatar.ofUser(message.from, iconRadius: 20),
                    Container(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                ChatMessageHeader(message),
                                ClipRect(
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(2, 2, 4, 4),
                                        child: Bubble(
                                            message: message,
                                            index: null,
                                            builderHandler: null,
                                        ),
                                    ),
                                )
                            ],
                        )
                    )
                ],
            )
        );
    }

    @override
    Widget mainWidget() {
        return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
                return _buildItem(index);
            },
            itemCount: _messages.length,
            padding: const EdgeInsets.symmetric(vertical: 12),
        );
    }
}