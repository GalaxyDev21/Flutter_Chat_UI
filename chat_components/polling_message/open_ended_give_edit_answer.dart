
import 'package:flutter/material.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/controllers/chat/polling_message_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/pojo/polling_answer.dart';
import 'package:organizer/pojo/polling_question.dart';
import 'package:organizer/services/analytics_service.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:organizer/views/components/progress_indicator.dart';


class OpenEndedGiveEditAnswer extends MyFullscreenBottomSheet {

    OpenEndedGiveEditAnswer({
        @required this.channelSid,
        @required this.question,
        @required this.answer
    });

    final String channelSid;
    final PollingQuestion question;
    // if answer is null, it means User has NOT answered that question
    final PollingAnswer answer;

    @override
    State<OpenEndedGiveEditAnswer> createState() => OpenEndedGiveEditAnswerState();
}

class OpenEndedGiveEditAnswerState extends MyFullscreenBottomSheetState<OpenEndedGiveEditAnswer> {

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    PollingMessageController pollingMessageController;
    TextEditingController textEditingController;
    bool answerIsEmpty = true;

    @override
    void initState() {
        super.initState();
        mainTitle = allTranslations.text('chat_polling_message_open_ended_your_answer');
        pollingMessageController = PollingMessageController(channelSid: widget.channelSid);
        textEditingController = TextEditingController();
        if (widget.answer != null) {
            textEditingController.text = widget.answer.answer;
            answerIsEmpty = false;
        }
    }

    @override
    void dispose() {
        textEditingController.dispose();
        super.dispose();
    }
    
    @override
    Widget actionButton() {
        return Row(
            children: <Widget>[
                if (widget.answer != null)
                    IconButton(
                        icon: Icon(Icons.delete, color: globals.Colors.gray),
                        onPressed: () async {
                            final bool confirmDelete = await showCancelAndOkDialog(
                                context,
                                title: 'chat_polling_message_delete_answer_title',
                                content: 'chat_polling_message_delete_answer_content',
                                okText: 'general_delete'
                            );
                            if (confirmDelete) {
                                try {
                                    showActivityIndicator();
                                    await pollingMessageController.deleteOpenEndedAnswer(
                                        widget.question.id,
                                        widget.answer.id,
                                    );
                                    hideActivityIndicator();
                                    Navigator.of(context).pop();
                                } catch (err) {
                                    hideActivityIndicator();
                                    showOkDialog(
                                        context,
                                        title: 'error',
                                        content: 'error'
                                    );
                                }
                            }
                        },
                    ),
                FlatButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                        widget.answer != null
                            ? allTranslations.text('chat_update')
                            : allTranslations.text('library_confirm'),
                        style: TextStyle(
                            color: answerIsEmpty ? globals.Colors.veryLightGray : globals.Colors.orange,
                            fontWeight: FontWeight.w600
                        )
                    ),
                    onPressed: () async {
                        if (answerIsEmpty)
                            return false;
                        if (_formKey.currentState.validate()) {
                            try {
                                showActivityIndicator();
                                // UPDATE answer
                                if (widget.answer != null) {
                                    await pollingMessageController.updateOpenEndedAnswer(
                                        widget.question.id,
                                        widget.answer.id,
                                        textEditingController.text
                                    );
                                }
                                // NEW answer
                                else {
                                    await pollingMessageController.createOpenEndedAnswer(
                                        widget.question.id,
                                        textEditingController.text
                                    );
                                }
                                final Channel channel = ChatListController().channels.firstWhere(
                                    (Channel channel) => channel.info.sid == widget.channelSid, orElse: () => null);

                                AnalyticsService().sendAmplitudeAnalyticsEvent(
                                    UserController.currentUser.uid,
                                    AmplitudeEvents.sendMessage,
                                    properties: <String, dynamic> {
                                        'recipientChannelSid': widget.channelSid,
                                        'messageType': 'Polling open-ended Answer',
                                        'receiverType': channel.info.attributes['type'],
                                        'isScheduledMsg': false,
                                        'groupAdminStatus': channel.isAdmin()
                                    }
                                );
                                hideActivityIndicator();
                                Navigator.of(context).pop();
                            } catch (err) {
                                hideActivityIndicator();
                                showOkDialog(
                                    context,
                                    title: 'error',
                                    content: 'error'
                                );
                            }
                        }
                    },
                )
            ],
        );
    }

    @override
    Widget mainWidget() {
        return WillPopScope(
            onWillPop: () async {
                bool isPop = true;
                if (!answerIsEmpty) {
                    if (widget.answer != null) {
                        isPop = await showCancelAndOkDialog(
                            context,
                            title: 'chat_polling_message_discard_changes_title',
                            content: 'chat_polling_message_discard_changes_content',
                            okText: 'general_discard'
                        );
                    }
                    else {
                        isPop = await showCancelAndOkDialog(
                            context,
                            title: 'chat_polling_message_discard_answer_title',
                            content: 'chat_polling_message_discard_answer_content',
                            okText: 'general_discard'
                        );
                    }
                }
                return isPop == true;
            },
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                            widget.question.question,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                            ),
                        )
                    ),
                    const Divider(height: 1, color: globals.Colors.veryLightGray),
                    Expanded(
                        child: SingleChildScrollView(
                            child: Form(
                                key: _formKey,
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: TextFormField(
                                        controller: textEditingController,
                                        textCapitalization: TextCapitalization.sentences,
                                        autocorrect: true,
                                        enableSuggestions: true,
                                        decoration: InputDecoration(
                                            hintText: allTranslations.text('chat_polling_message_open_enter_your_answer'),
                                            hintStyle: const TextStyle(
                                                color: globals.Colors.lightGray
                                            ),
                                            border: InputBorder.none,
                                        ),
                                        onChanged: (String value) {
                                            if (value.isEmpty)
                                                setState(() { answerIsEmpty = true; });
                                            else
                                                setState(() { answerIsEmpty = false; });
                                        },
                                        validator: (String value) {
                                            if (value.isEmpty)
                                                return 'Answer should not be empty';
                                            return null;
                                        },
                                        autofocus: widget.answer == null,
                                        maxLines: null,
                                        cursorColor: Colors.black
                                    ),
                                )
                            )
                        )
                    )
                ],
            )
        );
    }
}