

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/globals.dart' as globals;

class MybotHeader extends StatelessWidget {
    const MybotHeader(this.dateCreated, {this.visibleToAll = false});

    final bool visibleToAll;
    final DateTime dateCreated;

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
                children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                            allTranslations.text('onboarding_mybot'),
                            style: TextStyle(
                                color: globals.Colors.orange,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600
                            ),
                        ),
                    ),
                    if(!visibleToAll)
                        Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(2.0),
                                child: Container(
                                    width: 88,
                                    height: 16,
                                    color: globals.Colors.lightGray,
                                    child: Center(
                                        child: Text(
                                            allTranslations.text('chat_message_only_visible_to_you'),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: globals.Colors.white,
                                                fontSize: 10.0,
                                            )
                                        )
                                    )
                                ),
                            ),
                        ),
                    Expanded(
                        child: Text(
                            DateFormat('hh:mm a').format(dateCreated.toLocal()),
                            style: TextStyle(
                                color: globals.Colors.lightGray,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400
                            ),
                        ),
                    )
                ],
            )
        );
    }
}