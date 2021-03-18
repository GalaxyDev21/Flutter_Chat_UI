import 'dart:math';

import 'package:flutter/material.dart';

import 'package:organizer/globals.dart' as globals;
import 'package:organizer/views/components/oval_avatar.dart';
import 'package:organizer/views/constants/style_constants.dart';

class PrayerReminderSubmitted extends StatelessWidget {
    final List<String> uids;
    PrayerReminderSubmitted({this.uids = const <String>[]});
    int maxUsers = 5;
    @override
    Widget build(BuildContext context) {
        if (uids.isEmpty)
            return Container();
        return Container(
            width: (min(maxUsers, uids.length) - 1) * 24.0 + 36,
            height: 36,
            child: Stack(
                children: List<Widget>.generate(min(maxUsers, uids.length), (int index) {
                    return Positioned(
                        left: index * 24.0, top: 0,
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: globals.Colors.white, width: 2),
                                color: globals.Colors.white
                            ),
                            child: Stack(
                                children: <Widget>[
                                    MyOvalAvatar.ofUser(uids[index], iconRadius: 16,),
                                    if (index == maxUsers-1 && uids.length > maxUsers)
                                        Positioned(
                                            left: 0, top: 0, right: 0, bottom: 0,
                                            child: Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: globals.Colors.black.withOpacity(0.48),
                                                    borderRadius: BorderRadius.circular(16)
                                                ),
                                                child: Text(
                                                    '+${uids.length - maxUsers}',
                                                    style: k14MediumTextStyle.copyWith(color: globals.Colors.white),
                                                ),
                                            ),
                                        )
                                ],
                            ),
                        ),
                    );
                }),
            ),
        );
    }
}