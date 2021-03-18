import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

import 'package:organizer/views/calendar/event_form/location_add.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:organizer/views/components/select_profile_icon.dart';

class GroupCreateEvent extends StatefulWidget {
    GroupCreateEvent({
        this.isUpdate = false
    });
    
    bool isUpdate;
    
    @override
    _GroupCreateEventState createState() => _GroupCreateEventState();
}

class _GroupCreateEventState extends State<GroupCreateEvent> with TickerProviderStateMixin {
    
    TextEditingController _eventTitleController;
    bool _isPull = false;
    bool _isMember = false;
    String _location;
    String _description;
    DateTime _startDate, _startTime, _endDate, _endTime;
    String _image;
    
    @override
    void initState() {
        super.initState();
        _eventTitleController = TextEditingController();
    }
    
    @override
    void dispose() {
        _eventTitleController.dispose();
        super.dispose();
    }
    
    Future<void> _selectPhoto() async {
        final String image = await showMyModalBottomSheet<String>(
            context: context,
            child: SelectProfileIcon(title: allTranslations.text('profile_select_group_icon')),
            fullScreen: true
        );
        if (image != null) {
            setState(() {
                _image = image;
            });
        }
    }
    
    Widget _dateItem(DateTime date, bool isDate, {Function(DateTime) onPick}) {
        return FlatButton(
            child: Row(
                children: <Widget>[
                    Icon(
                        isDate ? Icons.calendar_today : Icons.access_time,
                        color: globals.Colors.brownGray,
                        size: 24,
                    ),
                    Container(width: 12),
                    Text(
                        date == null
                            ? (isDate
                                ? allTranslations.text('chat_date')
                                : allTranslations.text('chat_time'))
                            : (isDate
                                ? DateFormat('MMM dd, yyyy').format(date)
                                : DateFormat('hh:mm a').format(date)),
                        style: TextStyle(
                            color: date == null
                                ? globals.Colors.lightGray
                                : globals.Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400
                        ),
                    )
                ],
            ),
            onPressed: () {
                if (isDate) {
                    DatePicker.showDatePicker(
                        context,
                        showTitleActions: true,
                        onChanged: (DateTime date) {
                            onPick(date);
                        },
                        onConfirm: (DateTime date) {
                            onPick(date);
                        },
                        currentTime: date ?? DateTime.now(),
                        locale: LocaleType.en
                    );
                } else {
                    DatePicker.showTimePicker(
                        context,
                        showTitleActions: true,
                        onChanged: (DateTime date) {
                            onPick(date);
                        },
                        onConfirm: (DateTime date) {
                            onPick(date);
                        },
                        currentTime: date ?? DateTime.now(),
                        locale: LocaleType.en
                    );
                }
            },
        );
    }
    
    @override
    Widget build(BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height - 60,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    Container(height: 5),
                    Row(
                        children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.close, color: globals.Colors.gray, size: 30,),
                                onPressed: () {
                                    showDialog<void>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext dialogContext) {
                                            return AlertDialog(
                                                title: Text(
                                                    !widget.isUpdate
                                                        ? allTranslations.text('chat_event_discard')
                                                        : allTranslations.text('chat_discard_change')
                                                ),
                                                actions: <Widget>[
                                                    FlatButton(
                                                        onPressed: () {
                                                            Navigator.of(dialogContext).pop();
                                                        },
                                                        child: Text(
                                                            !widget.isUpdate
                                                                ? allTranslations.text('chat_back')
                                                                : allTranslations.text('chat_no')
                                                        ),
                                                    ),
                                                    FlatButton(
                                                        onPressed: () {
                                                            Navigator.of(dialogContext).pop();
                                                            Navigator.of(context).pop();
                                                        },
                                                        child: Text(
                                                            allTranslations.text('chat_yes')
                                                        ),
                                                    ),
                                                ],
                                            );
                                        }
                                    );
                                },
                            ),
                            Spacer(),
                            FlatButton(
                                child: Text(
                                    !widget.isUpdate
                                        ? allTranslations.text('chat_publish')
                                        : allTranslations.text('chat_update'),
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        color: globals.Colors.orange,
                                    )
                                ),
                                onPressed: () {
                                    if (_eventTitleController.text.isEmpty
                                        || _startDate == null || _startTime == null
                                        || _endDate == null || _endTime == null) {
                                        showDialog<void>(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext dialogContext) {
                                                return AlertDialog(
                                                    title: Text(allTranslations.text('chat_title_time')),
                                                    actions: <Widget>[
                                                        FlatButton(
                                                            onPressed: () async {
                                                                Navigator.of(dialogContext).maybePop();
                                                            },
                                                            child: Text(
                                                                allTranslations.text('library_ok')
                                                            ),
                                                        ),
                                                    ],
                                                );
                                            }
                                        );
                                    } else {
                                        showDialog<void>(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext dialogContext) {
                                                return AlertDialog(
                                                    title: Text(allTranslations.text('chat_announcement')),
                                                    content: Text(allTranslations.text('chat_ask_notify')),
                                                    actions: <Widget>[
                                                        FlatButton(
                                                            onPressed: () async {
                                                                Navigator.of(dialogContext).maybePop();
                                                                Navigator.of(context).maybePop();
                                                            },
                                                            child: Text(
                                                                allTranslations.text('chat_no')
                                                            ),
                                                        ),
                                                        FlatButton(
                                                            onPressed: () async {
                                                                Navigator.of(dialogContext).maybePop();
                                                                Navigator.of(context).maybePop();
                                                            },
                                                            child: Text(
                                                                allTranslations.text('chat_notify')
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
                    ),
                    Container(height: 5),
                    const Divider(height: 1, color: globals.Colors.veryLightGray,),
                    Expanded(
                        child: ListView(
                            children: <Widget>[
                                InkWell(
                                    child: Container(
                                        height: 175,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(_image ?? ''),
                                                fit: BoxFit.cover
                                            ),
                                            color: globals.Colors.multiTab,
                                        ),
                                        child: _image == null
                                            ? Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                    Icon(
                                                        Icons.add_photo_alternate,
                                                        color: globals.Colors.brownGray,
                                                        size: 48,
                                                    ),
                                                    Padding(
                                                        padding: const EdgeInsets.only(top: 12),
                                                        child: Text(
                                                            allTranslations.text('chat_add_photo'),
                                                            style: TextStyle(
                                                                color: globals.Colors.black,
                                                                fontSize: 15,
                                                            ),
                                                        ),
                                                    )
                                                ],
                                            )
                                            : Container(),
                                    ),
                                    onTap: () {
                                    
                                    },
                                    onTapDown: (TapDownDetails details) async {
                                        if (_image == null) {
                                            _selectPhoto();
                                        } else {
                                            final Size size = MediaQuery.of(context).size;
                                            final Offset tapPosition = details.globalPosition;
                                            final int result = await showMenu<int>(
                                                context: context,
                                                position: RelativeRect.fromRect(
                                                    tapPosition & const Size(0, 0), // smaller rect, the touch area
                                                    Offset.zero & size   // Bigger rect, the entire screen
                                                ),
                                                items: <PopupMenuEntry<int>>[
                                                    PopupMenuItem<int>(
                                                        value: 0,
                                                        child: Text(
                                                            allTranslations.text('chat_use_another')
                                                        ),
                                                    ),
                                                    PopupMenuItem<int>(
                                                        value: 1,
                                                        child: Text(
                                                            allTranslations.text('library_remove')
                                                        ),
                                                    )
                                                ],
                                            );
                                            if (result == 0) {
                                                _selectPhoto();
                                            } else if (result == 1) {
                                                setState(() {
                                                    _image = null;
                                                });
                                            }
                                        }
                                    },
                                ),
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: IntrinsicHeight(
                                        child: TextField(
                                            controller: _eventTitleController,
                                            decoration: InputDecoration(
                                                hintText: allTranslations.text('library_event_title'),
                                                border: InputBorder.none,
                                            ),
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w800
                                            ),
                                            cursorColor: Colors.black,
                                            maxLines: null,
                                        ),
                                    ),
                                ),
                                const Divider(height: 1, color: globals.Colors.veryLightGray),
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                        children: <Widget>[
                                            Container(
                                                width: 50,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    allTranslations.text('chat_start'),
                                                    style: TextStyle(
                                                        color: globals.Colors.black,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w700
                                                    ),
                                                ),
                                            ),
                                            Expanded(
                                                child: _dateItem(
                                                    _startDate,
                                                    true,
                                                    onPick: (DateTime date) {
                                                        setState(() {
                                                            _startDate = date;
                                                            _endDate = date;
                                                        });
                                                    }
                                                ),
                                            ),
                                            Expanded(
                                                child: _dateItem(
                                                    _startTime,
                                                    false,
                                                    onPick: (DateTime date) {
                                                        setState(() {
                                                            _startTime = date;
                                                            _endTime = date.add(Duration(hours: 1));
                                                        });
                                                    }
                                                ),
                                            )
                                        ],
                                    ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                        children: <Widget>[
                                            Container(
                                                width: 50,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    allTranslations.text('chat_end'),
                                                    style: TextStyle(
                                                        color: globals.Colors.black,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w700
                                                    ),
                                                ),
                                            ),
                                            Expanded(
                                                child: _dateItem(
                                                    _endDate,
                                                    true,
                                                    onPick: (DateTime date) {
                                                        setState(() {
                                                            _endDate = date;
                                                        });
                                                    }
                                                ),
                                            ),
                                            Expanded(
                                                child: _dateItem(
                                                    _endTime,
                                                    false,
                                                    onPick: (DateTime date) {
                                                        setState(() {
                                                            _endTime = date;
                                                        });
                                                    }
                                                ),
                                            )
                                        ],
                                    ),
                                ),
                                const Divider(height: 1, color: globals.Colors.veryLightGray),
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                        children: <Widget>[
                                            Icon(Icons.star, color: globals.Colors.brownGray,),
                                            Container(width: 12),
                                            Expanded(
                                                child: Text(
                                                    allTranslations.text('chat_pull_highlight'),
                                                    style: TextStyle(
                                                        color: globals.Colors.black,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w400
                                                    ),
                                                ),
                                            ),
                                            Switch(
                                                value: _isPull,
                                                activeColor: globals.Colors.lightRed,
                                                onChanged: (bool value) {
                                                    if (value == true && _image == null) {
                                                        showDialog<void>(
                                                            context: context,
                                                            barrierDismissible: false,
                                                            builder: (BuildContext dialogContext) {
                                                                return AlertDialog(
                                                                    title: Text(allTranslations.text('chat_photo_first')),
                                                                    actions: <Widget>[
                                                                        FlatButton(
                                                                            onPressed: () async {
                                                                                Navigator.of(dialogContext).maybePop();
                                                                            },
                                                                            child: Text(
                                                                                allTranslations.text('library_ok')
                                                                            ),
                                                                        ),
                                                                    ],
                                                                );
                                                            }
                                                        );
                                                    } else {
                                                        setState(() {
                                                            _isPull = value;
                                                        });
                                                    }
                                                }
                                            )
                                        ],
                                    ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                        children: <Widget>[
                                            Icon(Icons.lock, color: globals.Colors.brownGray,),
                                            Container(width: 12),
                                            Expanded(
                                                child: Text(
                                                    allTranslations.text('chat_available_member'),
                                                    style: TextStyle(
                                                        color: globals.Colors.black,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w400
                                                    ),
                                                ),
                                            ),
                                            Switch(
                                                value: _isMember,
                                                activeColor: globals.Colors.lightRed,
                                                onChanged: (bool value) {
                                                    setState(() {
                                                        _isMember = value;
                                                    });
                                                }
                                            )
                                        ],
                                    ),
                                ),
                                const Divider(height: 1, color: globals.Colors.veryLightGray),
                                Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: InkWell(
                                        child: Row(
                                            children: <Widget>[
                                                Icon(
                                                    Icons.pin_drop,
                                                    color: globals.Colors.brownGray
                                                ),
                                                Container(width: 12),
                                                Expanded(
                                                    child: Text(
                                                        _location == null
                                                            ? allTranslations.text('chat_location')
                                                            : _location,
                                                        style: TextStyle(
                                                            color: _location == null
                                                                ? globals.Colors.lightGray
                                                                : globals.Colors.black,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400
                                                        ),
                                                    ),
                                                ),
                                            ],
                                        ),
                                        onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute<void>(
                                                    builder: (BuildContext context) => LocationAdd(
                                                    location: _location,
                                                        onComplete: (String location) {
                                                            _location = location;
                                                        },
                                                    ),
                                                )
                                            );
                                        },
                                    ),
                                ),
                                const Divider(height: 1, color: globals.Colors.veryLightGray),
                                Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: InkWell(
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                                Icon(
                                                    Icons.info_outline,
                                                    color: globals.Colors.brownGray
                                                ),
                                                Container(width: 12),
                                                Expanded(
                                                    child: Text(
                                                        _description == null
                                                            ? allTranslations.text('library_description')
                                                            : _description,
                                                        style: TextStyle(
                                                            color: _description == null
                                                                ? globals.Colors.lightGray
                                                                : globals.Colors.black,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400
                                                        ),
                                                    ),
                                                ),
                                            ],
                                        ),
                                        onTap: () {
                                            showDescriptionDialog(
                                                context,
                                                description: _description,
                                                onComplete: (String text) {
                                                    _description = text;
                                                }
                                            );
                                        },
                                    ),
                                )
                            ],
                        ),
                    )
                ],
            ),
        );
    }
}