


import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:organizer/controllers/chat/polling_message_confirm_button_controller.dart';
import 'package:organizer/controllers/chat/polling_message_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/option.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/views/components/switch_tile.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:provider/provider.dart';

class PollingMultipleChoice extends StatefulWidget {

    PollingMultipleChoice(
        this.pollingMessageController,
        this.multipleChoiceFocusNode,
        this.mainContext
    );

    PollingMessageController pollingMessageController;
    FocusNode multipleChoiceFocusNode;
    BuildContext mainContext;
    
    @override
    _PollingMultipleChoiceState createState() => _PollingMultipleChoiceState();
}

class _PollingMultipleChoiceState extends State<PollingMultipleChoice> {

    List<FocusNode> focusNodeList;

    @override
    void initState() {
        super.initState();
        /// generate all 10 (maximum number of options when going into PollingMessage first)
        focusNodeList = List<FocusNode>.generate(10, (_) => FocusNode());
    }

    @override
    void dispose() {
        widget.pollingMessageController.multipleChoices.forEach((_) => _.dispose());
        focusNodeList.forEach((_) => _.dispose());
        super.dispose();
    }

    Widget multipleChoiceBuilder() {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.pollingMessageController.multipleChoices.length,
            itemBuilder: (BuildContext context, int index) {
                return Padding(
                    padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                    child: Row(
                        children: <Widget>[
                            Flexible(
                                flex: 5,
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(color: globals.Colors.lightGray)
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: TextFormField(
                                            focusNode: focusNodeList[index],
                                            controller: widget.pollingMessageController.multipleChoices[index],
                                            autocorrect: true,
                                            enableSuggestions: true,
                                            textCapitalization: TextCapitalization.sentences,
                                            decoration: InputDecoration(
                                                hintText: allTranslations.text('chat_polling_message_multiple_choice_text_hint') + (index + 1).toString(),
                                                hintStyle: const TextStyle(
                                                    color: globals.Colors.lightGray
                                                ),
                                                border: InputBorder.none,
                                            ),
                                            inputFormatters: <TextInputFormatter>[
                                                BlacklistingTextInputFormatter(RegExp('\n')),
                                                LengthLimitingTextInputFormatter(1024),
                                            ],
                                            onChanged: (String value) => checkChoices(),
                                            maxLines: null,
                                            cursorColor: Colors.black
                                        ),
                                    )
                                )
                            ),
                            Flexible(
                                flex: 1,
                                child: Center(
                                    child: IconButton(
                                        icon: Icon(Icons.delete, color: globals.Colors.brownGray),
                                        onPressed: () {
                                            setState(() {
                                                widget.pollingMessageController.multipleChoices.removeAt(index);
                                                checkChoices();
                                            });
                                        },
                                    )
                                )
                            )
                        ],
                    ),
                );
            },
        );
    }

    Widget addMultipleChoice() {
        return Row(
            children: <Widget>[
                Flexible(
                    flex: 5,
                    child: DottedBorder(
                        color: globals.Colors.lightGray,
                        strokeWidth: 1.5,
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(2),
                        padding: const EdgeInsets.all(0),
                        child: OutlineButton(
                            highlightColor: globals.Colors.white,
                            borderSide: BorderSide.none,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                    Icon(Icons.add, color: globals.Colors.lightGray),
                                    Text(
                                        allTranslations.text('chat_polling_message_multiple_choice_add'),
                                        style: const TextStyle(
                                            color: globals.Colors.lightGray
                                        )
                                    )
                                ],
                            ),
                            onPressed: () {
                                if (widget.pollingMessageController.multipleChoices.length < 10) {
                                    setState(() {
                                        widget.pollingMessageController.multipleChoices.add(TextEditingController());
                                        // this delay is necessary for the MC box to be ready and make the focus there
                                        Future.delayed(const Duration(milliseconds: 100), () {
                                            FocusScope.of(context).requestFocus(focusNodeList[widget.pollingMessageController.multipleChoices.length - 1]);
                                        });
                                        checkChoices();
                                    });
                                }
                                else {
                                    showOkDialog(
                                        context,
                                        title: 'chat_polling_message_max_options_title',
                                        content: 'chat_polling_message_max_options_content'
                                    );
                                }
                                
                            },
                        )
                    )
                ),
                Flexible(
                    flex: 1,
                    child: Container()
                )
            ],
        );
    }

    @override
    Widget build(BuildContext context) {
        return SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        child: TextFormField(
                            focusNode: widget.multipleChoiceFocusNode,
                            controller: widget.pollingMessageController.multipleChoiceQuestionTextController,
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
                                BlacklistingTextInputFormatter(RegExp('\n')),
                                LengthLimitingTextInputFormatter(2048),
                            ],
                            onChanged: (String value) {
                                if (value.isNotEmpty)
                                    Provider.of<PollingMessageConfirmButtonController>(context, listen: false).multipleChoiceQuestionFilledWith(true);
                                else
                                    Provider.of<PollingMessageConfirmButtonController>(context, listen: false).multipleChoiceQuestionFilledWith(false);
                            },
                            maxLines: null,
                            autofocus: true,
                            cursorColor: Colors.black
                        ),
                    ),
                    const Divider(height: 1, color: globals.Colors.veryLightGray),
                    Flexible(
                        child: multipleChoiceBuilder()
                    ),
                    Padding(
                        padding: const EdgeInsets.all(12),
                        child: addMultipleChoice(),
                    ),
                    const Divider(height: 1, color: globals.Colors.veryLightGray),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: MySwitchTile(
                            option: const Option(title: 'chat_polling_message_multiple_choice_allow_multi'),
                            value: widget.pollingMessageController.allowMultipleAnswers,
                            onChanged: (bool value) {
                                setState(() {
                                    widget.pollingMessageController.allowMultipleAnswers = value;
                                });
                            }
                        )
                    )
                ],
            )
        );
    }

    void checkChoices() {
        if (widget.pollingMessageController.multipleChoices.length >= 2) {
            int numberOfOptionsFilledWithText = 0;
            bool atLeastTwoOptionsFilledText = false;
            for (TextEditingController textEditing in widget.pollingMessageController.multipleChoices) {
                if (textEditing.text.isNotEmpty) {
                    numberOfOptionsFilledWithText++;
                    if (numberOfOptionsFilledWithText >= 2) {
                        atLeastTwoOptionsFilledText = true;
                        break;
                    }
                }
            }
            Provider.of<PollingMessageConfirmButtonController>(context, listen: false).multipleChoiceAtLeastFilledTwoOptions(atLeastTwoOptionsFilledText);
            Provider.of<PollingMessageConfirmButtonController>(context, listen: false).choicesFilledWith(true);
        }
        else
            Provider.of<PollingMessageConfirmButtonController>(context, listen: false).choicesFilledWith(false);
    }

}