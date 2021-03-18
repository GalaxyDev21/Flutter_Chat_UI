import 'package:flutter/material.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/globals.dart' as globals;

class ContactNotFound extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return Container(
            decoration: BoxDecoration(
                border: Border.all(color: globals.Colors.veryLightGray),
                borderRadius: BorderRadius.circular(2)
            ),
            child: IntrinsicHeight(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            color: globals.Colors.veryLightGray,
                            child: Icon(Icons.info_outline, color: globals.Colors.black, size: 24),
                        ),
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                        Text(
                                            allTranslations.text('chat_cannot_find'),
                                            style: TextStyle(
                                                color: globals.Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400
                                            ),
                                        ),
                                        Container(height: 3),
                                        Text(
                                            allTranslations.text('chat_try_enter'),
                                            style: TextStyle(
                                                color: globals.Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600
                                            ),
                                        )
                                    ],
                                ),
                            ),
                        )
                    ],
                ),
            ),
        );
    }
}