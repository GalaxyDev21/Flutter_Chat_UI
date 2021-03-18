
import 'package:flutter/material.dart';
import 'package:organizer/pojo/polling_answer.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet_wrapper.dart';
import 'package:organizer/views/components/modal_bottom_sheet_navbar.dart';
import 'package:organizer/views/components/user_name_view.dart';

class MultipleChoiceViewAnswer extends StatelessWidget {

    MultipleChoiceViewAnswer({
        @required this.answer
    });

    final PollingAnswer answer;

    @override
    Widget build(BuildContext context) {
        return MyFullscreenBottomSheetWrapper(
            child: Column(
                children: <Widget>[
                    MyModalSheetNavBar(mainTitle: answer.answer),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                Expanded(
                                    child: ListView.builder(
                                        itemCount: answer.voters.length,
                                        shrinkWrap: true,
                                        itemBuilder: (BuildContext context, int index) {
                                            return UserListItem(
                                                answer.voters[index],
                                            );
                                        }
                                    )
                                )
                            ],
                        )
                    )
                ],
            )
        );
    }

}