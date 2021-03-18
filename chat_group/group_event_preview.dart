import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flushbar/flushbar.dart';

import 'package:organizer/globals.dart' as globals;
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/controllers/chat/create_org_event_controller.dart';
import 'package:organizer/views/chat/chat_group/group_create_event.dart';
import 'package:organizer/views/components/future_builder.dart';
import 'package:organizer/views/tab_component.dart';
import 'package:organizer/models/user/user_model.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:organizer/controllers/option.dart';

class GroupEventPreview extends TabComponent {
    
    GroupEventPreview() {
        iconData = Icons.calendar_today;
        keyIndex = DateTime.now().toIso8601String();
    }
    
    @override
    _GroupEventPreviewState createState() => _GroupEventPreviewState();
}

class _GroupEventPreviewState extends State<GroupEventPreview> {
    
    final UserController _userController = UserController();
    final CreateOrgEventController _createOrgEventController = CreateOrgEventController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    bool _isOwner = true;
    
    @override
    void initState() {
        super.initState();
    }
    
    @override
    void dispose() {
        super.dispose();
    }
    
    Widget _readModeButton() {
        return IconButton(
            iconSize: 20,
            icon: const Icon(Icons.more_vert, color: globals.Colors.brownGray),
            onPressed: () async {
                final Option selectedOption = await showMyModalBottomSheetWithOptions(
                    context: context,
                    header: Option(title: allTranslations.text('chat_interview'), icon: Icons.calendar_today, multiLocale: false),
                    options: _createOrgEventController.getEditMenu()
                );
            },
        );
    }

    Widget _editModeButtons() {
        return Row(
            children: <Widget>[
                IconButton(
                    iconSize: 20,
                    icon: const Icon(MdiIcons.pencil, color: globals.Colors.lightRed),
                    onPressed: () async {
                        await showMyModalBottomSheet<void>(
                            context: context,
                            child: GroupCreateEvent(isUpdate: true),
                            fullScreen: true
                        );
                    },
                ),
                IconButton(
                    iconSize: 20,
                    icon: const Icon(Icons.more_vert, color: globals.Colors.brownGray),
                    onPressed: () async {
                        final Option selectedOption = await showMyModalBottomSheetWithOptions(
                            context: context,
                            header: Option(title: 'chat_interview', icon: Icons.calendar_today),
                            options: _createOrgEventController.getEditMenu()
                        );
                        
                        if (selectedOption == OrgEventOptions.delete) {
                            showDialog<void>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                        title: Text(
                                            allTranslations.text('chat_confirm_delete')
                                        ),
                                        actions: <Widget>[
                                            FlatButton(
                                                onPressed: () async {
                                                    Navigator.of(dialogContext).maybePop();
                                                },
                                                child: Text(
                                                    allTranslations.text('chat_no')
                                                ),
                                            ),
                                            FlatButton(
                                                onPressed: () async {
                                                    Navigator.of(dialogContext).maybePop();
                                                },
                                                child: Text(
                                                    allTranslations.text('chat_yes')
                                                ),
                                            ),
                                        ],
                                    );
                                }
                            );
                        }
                    },
                )
            ],
        );
    }
    
    Widget _readModeHeader() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: Row(
                        children: <Widget>[
                            Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                        Text(
                                            allTranslations.text('chat_organizer'),
                                            style: TextStyle(
                                                color: globals.Colors.brownGray,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12
                                            ),
                                        ),
                                        Container(height: 3),
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: MyFutureBuilder<User>.spin(
                                                future: _userController.getMe(),
                                                builder: (BuildContext context, User user) {
                                                    return Text(
                                                        user.displayName ?? '',
                                                        style: TextStyle(
                                                            color: globals.Colors.black,
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 16
                                                        ),
                                                    );
                                                },
                                            )
                                        )
                                    ],
                                ),
                            ),
                            InkWell(
                                child: Text(
                                    allTranslations.text('chat_+calendar'),
                                    style: TextStyle(
                                        color: globals.Colors.orange,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14
                                    ),
                                ),
                                onTap: () async {
                                    final Flushbar<int> flushBar = FlushBar(
                                        key: _formKey,
                                        title: allTranslations.text('chat_event_added'),
                                        subtitle: allTranslations.text('library_undo'),
                                        onTap: (Flushbar<int> flushBar) {
                                            flushBar.dismiss(1);
                                        }
                                    );
                                    final int result = await flushBar.show(context);
                                    if (result == 1) {
                                    } else {
                                    }
                                },
                            )
                        ],
                    ),
                ),
                const Divider(height: 1, color: globals.Colors.lightGray)
            ],
        );
    }
    
    Widget _mainWidget() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                _readModeHeader(),
                Expanded(
                    child: ListView(
                        children: <Widget>[
                            Image.asset(
                                'assets/images/sample_image.png',
                                width: 351, height: 210, fit: BoxFit.cover,
                            ),
                            Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                        Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: Text(
                                                'How To Boost Your Traffic Of Your Blog And Destroy The Competition',
                                                style: TextStyle(
                                                    color: globals.Colors.black,
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.w800
                                                ),
                                            ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                    Padding(
                                                        padding: const EdgeInsets.only(top: 2),
                                                        child: Icon(
                                                            Icons.access_time, color: globals.Colors.black, size: 13,
                                                        ),
                                                    ),
                                                    Container(width: 6),
                                                    Text(
                                                        'Dec 22, 4:15pm',
                                                        style: TextStyle(
                                                            color: globals.Colors.black,
                                                            fontSize: 14,
                                                        ),
                                                    )
                                                ],
                                            ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                    Padding(
                                                        padding: const EdgeInsets.only(top: 2),
                                                        child: Icon(
                                                            Icons.location_on, color: globals.Colors.black, size: 13,
                                                        ),
                                                    ),
                                                    Container(width: 6),
                                                    Expanded(
                                                        child: Text(
                                                            'The Coffee House Cafe',
                                                            style: TextStyle(
                                                                color: globals.Colors.black,
                                                                fontSize: 14,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                        ),
                                                    )
                                                ],
                                            ),
                                        ),
                                        Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                                Padding(
                                                    padding: const EdgeInsets.only(top: 2),
                                                    child: Icon(
                                                        Icons.info_outline, color: globals.Colors.black, size: 13,
                                                    ),
                                                ),
                                                Container(width: 6),
                                                Expanded(
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                                        children: <Widget>[
                                                            Padding(
                                                                padding: const EdgeInsets.only(bottom: 6),
                                                                child: Text(
                                                                    'When I first got into the online advertising business, I was looking for the magical combination that would put my website into the top search engine rankings, catapult me to the forefront of the minds or individuals looking to buy my product, and generally make me rich beyond my wildest dreams! After succeeding in the business for this long, I’m able to look back on my old self with this kind of thinking and shake my head.',
                                                                    style: TextStyle(
                                                                        color: globals.Colors.black,
                                                                        fontSize: 14,
                                                                    ),
                                                                ),
                                                            ),
                                                            Text(
                                                                'https://app.zeplin.io/project/event/html',
                                                                style: TextStyle(
                                                                    color: globals.Colors.lightBlue,
                                                                    fontSize: 14,
                                                                ),
                                                            )
                                                        ],
                                                    ),
                                                )
                                            ],
                                        )
                                    ],
                                ),
                            )
                        ],
                    ),
                ),
            ],
        );
    }
    
    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                Row(
                    children: <Widget>[
                        IconButton(
                            iconSize: 20,
                            icon: const Icon(MdiIcons.arrowCollapse, color: globals.Colors.brownGray),
                            onPressed: () {
                                widget.onCollapse();
                            },
                        ),
                        Spacer(),
                        if (!_isOwner)
                            _readModeButton()
                        else
                            _editModeButtons()
                    ],
                ),
                const Divider(height: 1, color: globals.Colors.lightGray),
                Expanded(child: _mainWidget())
            ],
        );
    }
}
