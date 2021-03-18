import 'package:flutter/material.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/user/user_model.dart';
import 'package:organizer/views/components/chat_button.dart';
import 'package:organizer/views/components/oval_avatar.dart';
import 'package:organizer/views/components/progress_indicator.dart';
import 'package:organizer/views/components/shadow_view.dart';
import 'package:organizer/views/components/user_name_view.dart';
import 'package:provider/provider.dart';

class InsertTo extends StatefulWidget {
    Function(String channelId) onSend;
    
    InsertTo({this.onSend});
    
    @override
    State<StatefulWidget> createState() {
        return InsertToState();
    }
}

class InsertToState extends State<InsertTo> with TickerProviderStateMixin {
    
    TabController _tabController;
    TextEditingController _textEditingController;
    final ChatListController _chatListController = ChatListController();
    List<Channel> _filtered;
    List<bool> _listSent = <bool>[];

    @override
    void initState() {
        super.initState();
        _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
        _textEditingController = TextEditingController();
        _listSent = List<bool>.generate(_chatListController.channels.length, (int index) => false);
        _filtered = _chatListController.channels;
    }

    @override
    void dispose() {
        _tabController.dispose();
        _textEditingController.dispose();
        super.dispose();
    }
    
    Widget _chatItem(Channel channel) {
        final int index = _chatListController.channels.indexWhere((Channel ch) => ch.info.sid == channel.info.sid);
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
            child: Row(
                children: <Widget>[
                    MyOvalAvatar.ofChannel(channel.avatar, iconRadius: 21),
                    Container(width: 15),
                    Expanded(
                        child: channel.type == ChannelType.PRIVATE
                            ? UserNameView(
                                channel.name,
                                noDataChild: SizedBox(
                                    width: 15, height: 15,
                                    child: CircularIndicator(size: 15),
                                )
                            )
                            : Text(
                                channel.name,
                                style: TextStyle(
                                    color: globals.Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600
                                ),
                            ),
                    ),
                    MySendButton(
                        text: _listSent[index] ? allTranslations.text('library_done') : allTranslations.text('chat_send'),
                        disabled: _listSent[index],
                        onTap: () {
                            if (!_listSent[index]) {
                                widget.onSend(channel.info.sid);
                                setState(() {
                                    _listSent[index] = true;
                                });
                            }
                        },
                    ),
                ],
            ),
        );
    }
    
    Widget _people() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                Text(
                    allTranslations.text('chat_people'),
                    style: TextStyle(
                        color: globals.Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700
                    ),
                ),
                Container(height: 6),
                ListView.builder(
                    itemCount: _filtered.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                        return _chatItem(_filtered[index]);
                    }
                )
            ],
        );
    }
    
    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                Container(height: 5),
                Row(
                    children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.close, color: globals.Colors.brownGray, size: 30,),
                            onPressed: () {
                                Navigator.of(context).maybePop();
                            },
                        ),
                        Text(
                            allTranslations.text('library_insert'),
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                color: globals.Colors.black,
                            )
                        )
                    ],
                ),
                Container(height: 5),
                const Divider(height: 2, color: globals.Colors.veryLightGray,),
//                Container(
//                    height: 56,
//                    decoration: BoxDecoration(
//                        boxShadow: <BoxShadow>[
//                            BoxShadow(
//                                color: globals.Colors.black.withOpacity(0.24),
//                                offset: const Offset(0, 4),
//                                blurRadius: 2
//                            )
//                        ]
//                    ),
//                    child: Container(
//                        color: globals.Colors.white,
//                        child: TabBar(
//                            isScrollable: true,
//                            controller: _tabController,
//                            indicator: UnderlineTabIndicator(
//                                borderSide: BorderSide(color: globals.Colors.orange, width: 2.0),
//                            ),
//                            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
//                            labelStyle: TextStyle(
//                                fontSize: 14,
//                                color: globals.Colors.black,
//                                fontWeight: FontWeight.w500,
//                            ),
//                            unselectedLabelColor: globals.Colors.lightGray,
//                            tabs: <Widget>[
//                                Tab(text: allTranslations.text('chat_chat_bold')),
//                                Tab(text: allTranslations.text('chat_document')),
//                            ],
//                        ),
//                    ),
//                ),
                Expanded(
                    child: ListView(
                        padding: const EdgeInsets.all(12),
                        children: <Widget>[
                            ShadowView(
                                width: double.infinity, height: 48,
                                offset: const Offset(0, 2),
                                shadowColor: globals.Colors.black.withOpacity(0.36),
                                backgroundColor: globals.Colors.lightWhite,
                                blurRadius: 2,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                    children: <Widget>[
                                        Icon(Icons.search, color: globals.Colors.brownGray,),
                                        Container(width: 12),
                                        Expanded(
                                            child: TextField(
                                                controller: _textEditingController,
                                                decoration: InputDecoration(
                                                    hintText: allTranslations.text('chat_search'),
                                                    border: InputBorder.none
                                                ),
                                                style: const TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w400
                                                ),
                                                cursorColor: globals.Colors.black,
                                                onChanged: (String text) {
                                                    setState(() {
                                                        _filtered = _chatListController.channels.where((Channel channel) {
                                                            String name;
                                                            if (channel.type == ChannelType.PRIVATE){
                                                                final User user = Provider.of<UsersInfo>(context, listen:false).user(channel.name);
                                                                name = user != null ? user.displayName : '';
                                                            }
                                                            else
                                                                name = channel.name;
                                                            return name.toLowerCase().contains(text.toLowerCase());
                                                        }).toList();
                                                    });
                                                },
                                            ),
                                        ),
                                        if (_textEditingController.text.isNotEmpty)
                                            Icon(Icons.cancel, color: globals.Colors.gray, size: 20,)
                                    ],
                                )
                            ),
                            Container(height: 16),
                            _people()
                        ],
                    ),
                )
            ],
        );
    }
}