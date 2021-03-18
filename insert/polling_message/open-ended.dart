


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:organizer/controllers/chat/polling_message_confirm_button_controller.dart';
import 'package:organizer/controllers/chat/polling_message_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:provider/provider.dart';

class PollingOpenEnded extends StatefulWidget {

    PollingOpenEnded(
        this.pollingMessageController,
        this.openEndedFocusNode
    );

    PollingMessageController pollingMessageController;
    FocusNode openEndedFocusNode;
    
    @override
    _PollingOpenEndedState createState() => _PollingOpenEndedState();
}

class _PollingOpenEndedState extends State<PollingOpenEnded> {
    
    @override
    Widget build(BuildContext context) {
        // super.build(context);
        return SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: TextFormField(
                    focusNode: widget.openEndedFocusNode,
                    controller: widget.pollingMessageController.openEndedQuestionTextController,
                    autocorrect: true,
                    enableSuggestions: true,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                        hintText: allTranslations.text('chat_polling_message_question_hint'),
                        hintStyle: const TextStyle(
                            color: globals.Colors.lightGray
                        ),
                        border: InputBorder.none,
                    ),
                    inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(2048),
                    ],
                    onChanged: (String value) {
                        if (value.isNotEmpty)
                            Provider.of<PollingMessageConfirmButtonController>(context, listen: false).openEndedQuestionFilledWith(true);
                        else
                            Provider.of<PollingMessageConfirmButtonController>(context, listen: false).openEndedQuestionFilledWith(false);
                    },
                    maxLines: null,
                    autofocus: true,
                    cursorColor: Colors.black
                ),
            ),
        );
    }

}