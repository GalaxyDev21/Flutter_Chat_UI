import 'package:flutter/material.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/globals.dart' as globals;

class DateSplitterOnChatMessage extends StatelessWidget {
    final DateTime dateTime;
    
    const DateSplitterOnChatMessage({@required this.dateTime});
    
    @override
    Widget build(BuildContext context) {
        final String currentDate = ChatListController.generateDate(dateTime);
        return Row(
            children: <Widget>[
                const Expanded(
                    child: Divider(height: 1, color: globals.Colors.lightGray,),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                        currentDate,
                        style: const TextStyle(
                            color: globals.Colors.lightGray,
                            fontSize: 12,
                        ),
                    ),
                ),
                const Expanded(
                    child: Divider(height: 1, color: globals.Colors.lightGray,),
                )
            ],
        );
    }
}