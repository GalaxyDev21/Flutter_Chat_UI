import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/views/chat/group/set_group_icon.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet_wrapper.dart';
import 'package:organizer/views/components/modal_bottom_sheet_navbar.dart';
import 'package:organizer/globals.dart' as globals;

class CreateGroup extends StatefulWidget {
    
    const CreateGroup();
    
    @override
    State<CreateGroup> createState() => CreateGroupState();
}

class CreateGroupState extends State<CreateGroup> {

    final TextEditingController _nameTextEditingController = TextEditingController();
    final TextEditingController _aboutTextEditingController = TextEditingController();
    String imagePath;
    
    @override
    void initState() {
        super.initState();
    }

    @override
    void dispose() {
        _nameTextEditingController.dispose();
        _aboutTextEditingController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return MyFullscreenBottomSheetWrapper(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    MyModalSheetNavBar(
                        mainTitle: allTranslations.text('chat_create_group'),
                        rightButton: <Widget>[
                            FlatButton(
                                key: const Key('chat_next'),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                    allTranslations.text('chat_next'),
                                    style: TextStyle(
                                        color: globals.Colors.orange,
                                        fontWeight: FontWeight.w600
                                    )
                                ),
                                onPressed: () {
                                    if (_nameTextEditingController.text.isNotEmpty)
                                        Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                                builder: (BuildContext context) => SetGroupIcon(
                                                    context,
                                                    name: _nameTextEditingController.text,
                                                    about: _aboutTextEditingController.text
                                                )
                                            )
                                        );
                                },
                            )
                        ]
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                            key: const Key('chat_name_group'),
                            controller: _nameTextEditingController,
                            autocorrect: true,
                            enableSuggestions: true,
                            decoration: InputDecoration(
                                hintText: allTranslations.text('chat_name_group'),
                                hintStyle: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w800,
                                    color: globals.Colors.lightGray
                                ),
                                border: InputBorder.none,
                            ),
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w800
                            ),
                            cursorColor: Colors.black,
                        ),
                    ),
                    const Divider(height: 1, color: globals.Colors.veryLightGray),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                            children: <Widget>[
                                Expanded(
                                    child: TextField(
                                        key: const Key('chat_about_group'),
                                        controller: _aboutTextEditingController,
                                        autocorrect: true,
                                        enableSuggestions: true,
                                        decoration: InputDecoration(
                                            hintText: allTranslations.text('chat_about_group'),
                                            hintStyle: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: globals.Colors.lightGray
                                            ),
                                            border: InputBorder.none,
                                        ),
                                        inputFormatters: <TextInputFormatter>[
                                            LengthLimitingTextInputFormatter(2048),
                                        ],
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w400
                                        ),
                                        cursorColor: Colors.black,
                                        maxLines: null,
                                    ),
                                )
                            ],
                        ),
                    )
                ],
            )
        );
    }
}