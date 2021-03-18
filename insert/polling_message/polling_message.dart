
import 'package:flutter/material.dart';
import 'package:organizer/controllers/chat/polling_message_confirm_button_controller.dart';
import 'package:organizer/controllers/chat/polling_message_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/views/chat/insert/polling_message/multiple-choice.dart';
import 'package:organizer/views/chat/insert/polling_message/open-ended.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet_wrapper.dart';
import 'package:organizer/views/components/modal_bottom_sheet_navbar.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:organizer/views/components/progress_indicator.dart';
import 'package:provider/provider.dart';

class PollingMessage extends StatefulWidget {

    PollingMessage({
        @required this.channel,
        this.isScheduledMsg = false
    });

    Channel channel;
    final bool isScheduledMsg;
    @override
    _PollingMessageState createState() => _PollingMessageState();
}


class _PollingMessageState extends State<PollingMessage> with SingleTickerProviderStateMixin {

    PollingMessageController _pollingMessageController;
    final GlobalKey<FormState> _multipleChoiceKey = GlobalKey<FormState>();
    final GlobalKey<FormState> _openEndedformKey = GlobalKey<FormState>();
    final FocusNode multipleChoiceFocusNode = FocusNode();
    final FocusNode openEndedFocusNode = FocusNode();
    bool isQuestionFilled = false, isChoicesFilled = false;
    int tabIndex = 0;

    @override
    void initState() {
        super.initState();
        _pollingMessageController = PollingMessageController(channelSid: widget.channel.info.sid);
    }
    
    @override
    void dispose() {
        multipleChoiceFocusNode.dispose();
        openEndedFocusNode.dispose();
        _pollingMessageController.multipleChoiceQuestionTextController.dispose();
        _pollingMessageController.openEndedQuestionTextController.dispose();
        super.dispose();
    }
    
    Widget navbar() {
        return MyModalSheetNavBar(
            rightButton: <Widget>[
                Consumer<PollingMessageConfirmButtonController>(
                    builder: (_, PollingMessageConfirmButtonController buttonController, Widget child) {
                        return FlatButton(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: (tabIndex == 0)
                                ? Text(
                                    allTranslations.text('library_confirm'),
                                    style: TextStyle(
                                        color: buttonController.multipleChoiceQuestionIsFilled && buttonController.choicesAreMoreThanTwo && buttonController.multipleChoiceFilledTwoOptions
                                            ? globals.Colors.orange
                                            : globals.Colors.veryLightGray,
                                        fontWeight: FontWeight.w600
                                    )
                                )
                                : Text(
                                    allTranslations.text('library_confirm'),
                                    style: TextStyle(
                                        color: buttonController.openEndedQuestionIsFilled
                                            ? globals.Colors.orange
                                            : globals.Colors.veryLightGray,
                                        fontWeight: FontWeight.w600
                                    )
                                ),
                            onPressed: () async {
                                try {
                                    // submit through Mutliple-Choice
                                    bool isStartedPoll = false;
                                    Map<String, dynamic> pollingResponse;
                                    print(widget.isScheduledMsg);

                                    if (tabIndex == 0) {
                                        if (buttonController.multipleChoiceQuestionIsFilled && buttonController.choicesAreMoreThanTwo && buttonController.multipleChoiceFilledTwoOptions) {
                                            showActivityIndicator();
                                            print(widget.isScheduledMsg);
                                            pollingResponse = await _pollingMessageController.createPolling(isMultipleChoice: true, isScheduledMsg: widget.isScheduledMsg);
                                            if (pollingResponse != null)
                                                isStartedPoll = true;
                                        }
                                        else
                                            return false;
                                    }
                                    // submit through Open-ended
                                    else {
                                        if (buttonController.openEndedQuestionIsFilled) {
                                            showActivityIndicator();
                                            pollingResponse = await _pollingMessageController.createPolling(isMultipleChoice: false, isScheduledMsg: widget.isScheduledMsg);
                                            if (pollingResponse != null)
                                                isStartedPoll = true;
                                        }
                                        else
                                            return false;
                                    }
                                    if (isStartedPoll) {
                                        hideActivityIndicator();
                                        if (widget.isScheduledMsg)
                                            Navigator.of(context).pop(pollingResponse);
                                        else 
                                            Navigator.of(context)..pop()..maybePop();
                                    }
                                } catch (err) {
                                    hideActivityIndicator();
                                    showOkDialog(
                                        context,
                                        title: 'error',
                                        content: 'error'
                                    );
                                }
                            }
                        );
                    }
                )
            ]
        );
    }
    
    Widget mainWidget() {
        return MyFullscreenBottomSheetWrapper(
            child: Column(
                children: <Widget>[
                    navbar(),
                    Row(
                        children: <Widget>[
                            DecoratedBox(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 2,
                                            color: (tabIndex == 0) ? globals.Colors.orange : globals.Colors.white
                                        )
                                    )
                                ),
                                child: FlatButton(
                                    onPressed: () {
                                        setState(() { tabIndex = 0; });
                                        FocusScope.of(context).requestFocus(multipleChoiceFocusNode);
                                    },
                                    child: Text(
                                        allTranslations.text('chat_polling_message_multiple_choices'),
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: (tabIndex == 0) ? globals.Colors.orange : globals.Colors.gray
                                        )
                                    )
                                ),
                            ),
                            DecoratedBox(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 2,
                                            color: (tabIndex == 1) ? globals.Colors.orange : globals.Colors.white
                                        )
                                    )
                                ),
                                child: FlatButton(
                                    onPressed: () {
                                        setState(() { tabIndex = 1; });
                                        FocusScope.of(context).requestFocus(openEndedFocusNode);
                                    },
                                    child: Text(
                                        allTranslations.text('chat_polling_message_open_ended'),
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: (tabIndex == 1) ? globals.Colors.orange : globals.Colors.gray
                                        )
                                    )
                                )
                            )
                        ],
                    ),
                    const Divider(height: 1, color: globals.Colors.veryLightGray),
                    Expanded(
                        child: IndexedStack(
                            index: tabIndex,
                            children: <Widget>[
                                Form(
                                    key: _multipleChoiceKey,
                                    child: PollingMultipleChoice(_pollingMessageController, multipleChoiceFocusNode, context)
                                ),
                                Form(
                                    key: _openEndedformKey,
                                    child: PollingOpenEnded(_pollingMessageController, openEndedFocusNode)
                                )
                            ],
                        )
                    )
                ],
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return WillPopScope(
            onWillPop: () async {
                bool isPop = true;
                if (_pollingMessageController.cannotToPopOut) {
                    isPop = await showCancelAndOkDialog(
                        context,
                        title: 'chat_polling_message_discard_poll_title',
                        content: 'chat_polling_message_discard_poll_content',
                        okText: 'general_discard'
                    );
                }
                return isPop == true;
            },
            child: ChangeNotifierProvider<PollingMessageConfirmButtonController>(
                create: (_) => PollingMessageConfirmButtonController(),
                child: mainWidget()
            )
        );
    }

}
