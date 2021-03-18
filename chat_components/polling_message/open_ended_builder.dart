import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/handlers/chat_message_builder_handler.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/models/chat/polling_message_model.dart';
import 'package:organizer/pojo/polling_answer.dart';
import 'package:organizer/pojo/polling_question.dart';
import 'package:organizer/views/chat/chat_components/bubble.dart';
import 'package:organizer/views/chat/chat_components/chat_message/chat_message_header.dart';
import 'package:organizer/views/chat/chat_components/chat_message_avatar.dart';
import 'package:organizer/views/chat/chat_components/polling_message/open_ended_give_edit_answer.dart';
import 'package:organizer/views/chat/chat_components/polling_message/open_ended_view_answer.dart';
import 'package:organizer/views/chat/chat_components/polling_message/polling_message_builder.dart';
import 'package:organizer/views/components/chat_button.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:provider/provider.dart';

class OpenEndedBuilder extends PollingMessageBuilder {
    @override
    String get type => PollingMessageTypes.openEnded;

    OpenEndedBuilder({
        Channel channel,
        Message message,
        int totalMessageCount,
        bool hasChatMessageAvatar,
        bool isLast,
        int index,
        int readCount,
        ChatMessageBuilderHandler builderHandler,
        bool isHighlight
    }) : super(
        channel: channel,
        message: message,
        totalMessageCount: totalMessageCount,
        hasChatMessageAvatar: hasChatMessageAvatar,
        isLast: isLast,
        readCount: readCount,
        index: index,
        builderHandler: builderHandler,
        isHighlight: isHighlight,
    );

    @override
    Widget builder(BuildContext context) {
        return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                ChatMessageAvatar(
                    channel: channel,
                    message: message,
                    hasChatMessageAvatar: hasChatMessageAvatar,
                    index: index,
                    builderHandler: builderHandler
                ),
                Expanded(
                    child: MultiProvider(
                        providers: [
                            StreamProvider<PollingQuestion>(
                                create: (_) => PollingMessageModel(channelSid: channelSid).watchPollingQeustion(pollingId),
                                initialData: PollingQuestion(
                                    isStopped: false,
                                    type: 'open-ended',
                                    question: 'Loading ...',
                                ),
                            ),
                            StreamProvider<List<PollingAnswer>>(
                                create: (_) => PollingMessageModel(channelSid: channelSid).watchPollingAnswers(pollingId),
                                initialData: const <PollingAnswer>[],
                            )
                        ],
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                if (hasChatMessageAvatar)
                                    ChatMessageHeader(message, channel: channel),
                                ClipRect(
                                    child: Slidable(
                                        actionPane: const SlidableDrawerActionPane(),
                                        child: Padding(
                                            padding: const EdgeInsets.fromLTRB(2, 2, 4, 4),
                                            child: Column(
                                                children: <Widget>[
                                                    Bubble(
                                                        message: message,
                                                        isLast: isLast,
                                                        readCount: readCount,
                                                        outChannelSid: channel.isOutsidePublisher ? channel.info.sid : null,
                                                        index: index,
                                                        builderHandler: builderHandler,
                                                        isHighlight: isHighlight
                                                    ),
                                                    ViewAnswersButton(isOutsidePublisher: channel.isOutsidePublisher),
                                                    GiveOrEditAnswersButton(channelSid: channelSid, isOutsidePublisher: channel.isOutsidePublisher)
                                                ],
                                            )
                                        ),
                                        actions: <Widget>[
                                            if (!ChatListController.isDeleted(message.attributes)
                                                && !ChatListController.isHidden(message.attributes)
                                                && !ChatListController.isBlocked(message.attributes)
                                                && message.type != MessageTypes.invite)
                                                IconSlideAction(
                                                    caption: allTranslations.text('chat_reply'),
                                                    color: Colors.transparent,
                                                    icon: Icons.reply,
                                                    foregroundColor: globals.Colors.brownGray,
                                                    onTap: () => builderHandler.onReply(index),
                                                ),
                                        ]
                                    )
                                ),
                            ]
                        )
                    )
                )
            ]
        );
    }
}

class ViewAnswersButton extends StatelessWidget {
    final bool isOutsidePublisher;
    ViewAnswersButton({this.isOutsidePublisher});
    
    @override
    Widget build(BuildContext context) {
        final List<PollingAnswer> _answers = Provider.of<List<PollingAnswer>>(context);
        return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: MyChatButton(
                text: '${allTranslations.text('chat_polling_message_open_ended_view_answers')} (${isOutsidePublisher ? '?' : _answers.length})',
                color: isOutsidePublisher ? globals.Colors.lightGray : globals.Colors.orange,
                highlightColor: isOutsidePublisher ? globals.Colors.lightGray : globals.Colors.lightOrange,
                onPressed: isOutsidePublisher ? null : () async {
                    showMyModalBottomSheet<void>(
                        context: context,
                        child: OpenEndedViewAnswer(
                            answers: _answers
                        ),
                        fullScreen: true
                    );
                },
            )
        );
    }
}

class GiveOrEditAnswersButton extends StatelessWidget {

    GiveOrEditAnswersButton({
        @required this.channelSid,
        this.isOutsidePublisher
    });

    final String channelSid;
    final bool isOutsidePublisher;
    PollingAnswer answeredAnswer;
    bool hasAnswered = false;

    @override
    Widget build(BuildContext context) {
        final PollingQuestion _question = Provider.of<PollingQuestion>(context);
        final List<PollingAnswer> _answers = Provider.of<List<PollingAnswer>>(context);
        for (PollingAnswer answer in _answers) {
            if (answer.voters.contains(UserController.currentUser.uid)) {
                answeredAnswer = answer;
                hasAnswered = true;
                break;
            }
        }
        return MyChatButton(
            text: hasAnswered
                ? allTranslations.text('chat_polling_message_open_ended_edit_answer')
                : allTranslations.text('chat_polling_message_open_ended_give_answer'),
            color: _question.isStopped || isOutsidePublisher ? globals.Colors.lightGray : globals.Colors.orange,
            highlightColor: _question.isStopped || isOutsidePublisher ? globals.Colors.lightGray : globals.Colors.orange,
            onPressed: isOutsidePublisher ? null : () async {
                if (_question.isStopped)
                    return;
                return showMyModalBottomSheet<void>(
                    context: context,
                    child: OpenEndedGiveEditAnswer(
                        channelSid: channelSid,
                        question: _question,
                        answer: answeredAnswer
                    ),
                    fullScreen: true
                );
            },
        );
    }
}