import 'package:flutter/material.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/views/chat/people/contact_not_found.dart';

class NoResult extends StatelessWidget {

    NoResult({
        this.triedBid = false
    });

    bool triedBid;

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                Expanded(
                    child: Container()
                ),
                Image.asset('assets/images/group80.png', width: 156, height: 160),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                        allTranslations.text('search_people_result_empty'),
                        style: TextStyle(
                            color: globals.Colors.brownGray,
                            fontSize: 24,
                            fontWeight: FontWeight.w400
                        ),
                        textAlign: TextAlign.center,
                    ),
                ),
                if (!triedBid)
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ContactNotFound(),
                    ),
                Expanded(
                    child: Container()
                ),
            ],
        );
    }
}