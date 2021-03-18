import 'package:flutter/material.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/handlers/chat_insert_handler.dart';
import 'package:organizer/views/chat/chat_components/chat_screen/unsent_scheduled_message_button.dart';
import 'package:organizer/views/chat/insert/chat_insert.dart';
import 'package:organizer/views/components/dialogs.dart';

class ChatScreenInputField extends StatefulWidget {
    
    final FocusNode focusNode;
    final TextEditingController textEditingController;
    final Channel channel;
    final Function onPressed;
    final ChatInsertHandler chatInsertHandler;
    final Map<String, dynamic> replyTo;
    
    const ChatScreenInputField({
        Key key,
        this.focusNode,
        this.textEditingController,
        this.channel,
        this.onPressed,
        this.chatInsertHandler,
        this.replyTo
    }) : super(key: key);

    @override
    _ChatScreenInputFieldState createState() => _ChatScreenInputFieldState();
}

class _ChatScreenInputFieldState extends State<ChatScreenInputField> {

    TextInputAction textInputAction;

    @override
    void initState() { 
      super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            constraints: const BoxConstraints(minHeight:56.0, maxHeight: 112.0),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: globals.Colors.shadow,
                        offset: const Offset(0, -2),
                        blurRadius: 3
                    )
                ]
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Flexible(
                        child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: TextField(
                                key: const Key('input-field'),
                                style: TextStyle(color: Colors.black, fontSize: 15.0),
                                focusNode: widget.focusNode,
                                controller: widget.textEditingController,
                                textCapitalization: TextCapitalization.sentences,
                                autocorrect: true,
                                enableSuggestions: true,
                                decoration: InputDecoration.collapsed(
                                    hintText: allTranslations.text(
                                        widget.channel != null && widget.channel.type != ChannelType.SELF
                                            ? 'chat_type'
                                            : 'chat_type_self'
                                    ),
                                    hintStyle: const TextStyle(color: Colors.grey),
                                ),
                                onChanged: (String text) {
                                    widget.channel.typingMessage = text;
                                    setState(() {});
                                },
                                maxLines: null,
                            ),
                            
                        ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                            UnsentScheduledMessageButton(channel:widget.channel),
                            if (widget.textEditingController.text.isNotEmpty)
                                IconButton(
                                    key: const Key('send-button'),
                                    padding: const EdgeInsets.all(0),
                                    icon: Icon(Icons.send, color: globals.Colors.orange),
                                    onPressed: widget.onPressed

                                )
                            else
                                if (widget.replyTo == null)
                                    Row(
                                        children: <Widget>[
                                            IconButton(
                                                key: const Key('add-button'),
                                                padding: const EdgeInsets.all(0),
                                                icon: Icon(Icons.add, color: globals.Colors.gray),
                                                onPressed: () {
                                                    showMyModalBottomSheet<String>(
                                                        context: context,
                                                        child: ChatInsert(
                                                            channel: widget.channel,
                                                            insertHandler: widget.chatInsertHandler,
                                                            isAdmin: widget.channel.isAdmin(uid: UserController.currentUser.uid)
                                                        ),
                                                        fullScreen: true
                                                    );
                                                },
                                            )
                                        ],
                                    )
                        ]
                    )
                ],
            ),
        );
    }      
}
