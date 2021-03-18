import 'package:flutter/material.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/views/components/user_name_view.dart';

class ChatReadBy extends StatefulWidget {
    ChatReadBy({@required this.uids});
    List<String> uids;
    
    @override
    State<StatefulWidget> createState() {
        return ChatReadByState();
    }
}

class ChatReadByState extends State<ChatReadBy> {
    
    @override
    void initState() {
        super.initState();
    }
    
    @override
    void dispose() {
        super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
        return Column(
            children: <Widget>[
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                        children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.close, color: globals.Colors.brownGray, size: 30,),
                                onPressed: () {
                                    Navigator.of(context).maybePop();
                                },
                            ),
                            Text(
                                '${allTranslations.text('chat_read_by')} ${widget.uids.length}',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    color: globals.Colors.black,
                                )
                            )
                        ],
                    ),
                ),
                const Divider(height: 1, color: globals.Colors.veryLightGray),
                Expanded(
                    child: ListView.builder(
                        itemCount: widget.uids.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                            return UserListItem(
                                widget.uids[index]
                            );
                        }
                    ),
                )
            ],
        );
    }
}
