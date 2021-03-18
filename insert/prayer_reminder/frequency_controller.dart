import 'package:flutter/material.dart';
import 'package:organizer/controllers/chat/prayer_reminder_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/views/constants/style_constants.dart';
import 'package:organizer/globals.dart' as globals;
class FrequencyController {
    
    String frequency;
    bool dailyOption;
    bool weeklyOption;
    bool monthlyOption;
    bool noRepeatOption;
    List<bool> collectionFrequency;
    String cancelText;
    String okText;
    List<String> days =  <String>['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    FrequencyController({
        this.frequency = ReminderFrequency.daily,
        this.dailyOption = true,
        this.weeklyOption = true,
        this.monthlyOption = false,
        this.noRepeatOption = false,
        this.collectionFrequency,
        this.cancelText = 'library_cancel',
        this.okText = 'library_ok',
    }) {
        if (collectionFrequency == null) {
            collectionFrequency= [false,false,false,false,false,false,false,];
        }
    }
    StateSetter _setter;
    bool giveWarning;
    Future<bool> selectFrequency(BuildContext context) async {
        String localFrequency = frequency;
        return showDialog<bool> (
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) =>
                StatefulBuilder(
                    builder: (BuildContext context, StateSetter setter) {
                        _setter = setter;
                        return AlertDialog(
                            content: Container(
                                height: 380,
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                        if(noRepeatOption)
                                            InkWell(
                                                child: Padding(
                                                    padding: const EdgeInsets.only(top: 10, bottom:20),
                                                    child: Container(
                                                        height: 20,
                                                        child: Row(
                                                            children: <Widget>[
                                                                Radio<String>(
                                                                    value: ReminderFrequency.noRepeat,
                                                                    groupValue: localFrequency,
                                                                    onChanged: (String value) {
                                                                        setter(() {
                                                                            localFrequency = value;
                                                                        });
                                                                    },
                                                                ),
                                                                Flexible(
                                                                    child: Text(
                                                                        ReminderFrequency.noRepeat,
                                                                        style: k14TextStyle,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                onTap: () {
                                                    setter(() {
                                                        localFrequency = ReminderFrequency.noRepeat;
                                                    });
                                                },
                                            ),

                                        if (dailyOption)
                                            InkWell(
                                                child: Padding(
                                                    padding: const EdgeInsets.only(top: 10, bottom:20),
                                                    child: Container(
                                                        height: 20,
                                                        child: Row(
                                                            children: <Widget>[
                                                                Radio<String>(
                                                                    value: ReminderFrequency.daily,
                                                                    groupValue: localFrequency,
                                                                    onChanged: (String value) {
                                                                        setter(() {
                                                                            localFrequency = value;
                                                                        });
                                                                    },
                                                                ),
                                                                Flexible(
                                                                    child: Text(
                                                                        ReminderFrequency.daily,
                                                                        style: k14TextStyle,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                onTap: () {
                                                    setter(() {
                                                        localFrequency = ReminderFrequency.daily;
                                                    });
                                                },
                                            ),
                                        if (weeklyOption)
                                            ...[
                                                InkWell(
                                                    child: Padding(
                                                        padding: const EdgeInsets.only(bottom: 19),
                                                        child: Container(
                                                            height: 20,
                                                            child: Row(
                                                                children: <Widget>[
                                                                    Radio<String>(
                                                                        value: ReminderFrequency.weekly,
                                                                        groupValue: localFrequency,
                                                                        onChanged: (String value) {
                                                                            setter(() {
                                                                                localFrequency = value;
                                                                            });
                                                                        },
                                                                    ),
                                                                    Flexible(
                                                                        child: Text(
                                                                            ReminderFrequency.weekly,
                                                                            style: k14TextStyle,
                                                                        )
                                                                    ),
                                                                ],
                                                            ),
                                                        ),
                                                    ),
                                                    onTap: () {
                                                        setter(() {
                                                            localFrequency = ReminderFrequency.weekly;
                                                        });
                                                    },
                                                ),
                                                Expanded(
                                                    child: Padding(
                                                        padding: const EdgeInsets.only(left: 35),
                                                        child: ListView(
                                                            children: daysTile(localFrequency)
                                                        ),
                                                    ),
                                                ),
                                            ],
                                        if (monthlyOption)
                                            InkWell(
                                                child: Padding(
                                                    padding: const EdgeInsets.only(top: 10, bottom:20),
                                                    child: Container(
                                                        height: 20,
                                                        child: Row(
                                                            children: <Widget>[
                                                                Radio<String>(
                                                                    value: ReminderFrequency.monthly,
                                                                    groupValue: localFrequency,
                                                                    onChanged: (String value) {
                                                                        setter(() {
                                                                            localFrequency = value;
                                                                        });
                                                                    },
                                                                ),
                                                                Flexible(
                                                                    child: Text(
                                                                        ReminderFrequency.monthly,
                                                                        style: k14TextStyle,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                onTap: () {
                                                    setter(() {
                                                        localFrequency = ReminderFrequency.monthly;
                                                    });
                                                },
                                            ),
                                    ]
                                )
                            ),
                            actions: <Widget>[
                                FlatButton(
                                    child: Text(
                                        allTranslations.text(cancelText),
                                        style: const TextStyle(color: globals.Colors.orange)
                                    ),
                                    onPressed: () {
                                        Navigator.of(context).pop(false);
                                    }
                                ),
                                FlatButton(
                                    child: Text(
                                        allTranslations.text(okText),
                                        style: const TextStyle(color: globals.Colors.orange)
                                    ),
                                    onPressed: () {
                                        if (notOk(localFrequency)) {
                                            setter(() {
                                                giveWarning = true;
                                                
                                            });
                                            return null;
                                        }
                                        frequency = localFrequency;
                                        Navigator.of(context).pop(true);
                                    }
                                )
                            ]
                        );
                    }
            )
        );
    }  



    List<Widget> daysTile(String localFrequency) {
        final List<Widget> tiles = [];
        for(int i = 0 ; i < 7 ; i ++) {
            tiles.add(
                AbsorbPointer(
                    absorbing: localFrequency != ReminderFrequency.weekly,
                    child: Opacity(
                        opacity: localFrequency == ReminderFrequency.weekly ? 1 : 0.36,
                        child: InkWell(
                            child: Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: Container(
                                    height: 18,
                                    child: Row(
                                        children: <Widget>[
                                            Checkbox(
                                                value: collectionFrequency[i],
                                                onChanged: (bool value) {
                                                    giveWarning = false;
                                                    _setter(() { 
                                                        collectionFrequency[i] = value;
                                                    });
                                                } ,
                                            ),
                                            Text(days[i], style: k14TextStyle)
                                        ],
                                    ),
                                ),
                            ),
                            onTap: () {
                                giveWarning = false;
                                _setter(() {
                                    collectionFrequency[i] = !collectionFrequency[i]; 
                                });
                            },
                        ),
                    ),
                )
            );
        }
        if (giveWarning)
            tiles.add(
                Padding(
                    padding: const EdgeInsets.only(left:14),
                    child: Text(
                        allTranslations.text('prayer_reminder_select_day_warning'),
                        style: kWarningTextStyle
                    )
                )
            );
        return tiles;
    }

    bool notOk(String localFrequency) {
        return localFrequency == ReminderFrequency.weekly && noDaySelected();
    }

    bool noDaySelected() {
        for (bool day in collectionFrequency) {
            if (day)
                return false;
        }
        return true;
    }
}

