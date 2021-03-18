import 'package:flutter/material.dart';
import 'package:organizer/common/common_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/user/user_model.dart';
import 'package:organizer/services/router_service.dart';
import 'package:organizer/views/chat/people/contact_not_found.dart';
import 'package:organizer/views/chat/people/no_result.dart';
import 'package:organizer/views/chat/people/people_in_common_group.dart';
import 'package:organizer/views/chat/people/people_in_contact_list.dart';
import 'package:organizer/views/components/chat_button.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet_wrapper.dart';
import 'package:organizer/views/components/future_builder.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/views/profile/channel_profile/channel_profile_route.dart';
import 'package:organizer/views/profile/user_profile/user_profile_route.dart';

class SearchByIDorName extends StatefulWidget {

    SearchByIDorName({
        this.getContacts
    });

    Future<Contact> getContacts;
    
    @override
    State<SearchByIDorName> createState() => SearchByIDorNameState();
}


class SearchByIDorNameState extends State<SearchByIDorName> {

    final UserController _userController = UserController();
    final TextEditingController _textEditingController = TextEditingController();

    @override
    void dispose() {
        _textEditingController.dispose();
        super.dispose();
    }

    Future<void> _searchWithBid(String text) async {
        final Map<String, dynamic> result = await _userController.getUserFromBid(text);
        if (result['user'] != null) {
            RouterService.instance.navigateTo(UserProfileRoute.buildPath(result['user']), context: context);
        } else if (result['channel'] != null) {
            RouterService.instance.navigateTo(ChannelProfileRoute.buildPath(result['channel']), context: context); //todo: change to sid
        } else {
            setState(() {});
        }
    }

    Widget searchPeople() {
        return MyFutureBuilder<Contact>.empty(
            future: widget.getContacts,
            builder: (BuildContext context, Contact contact) {
                List<User> connected = contact.connected;
                List<User> possible = contact.possible;
                if (_textEditingController.text.isEmpty)
                    return Container();
                connected = connected.where((User user) {
                    if (user.displayName == null)
                        return false;
                    return user.displayName.toLowerCase().contains(_textEditingController.text.toLowerCase());
                }).toList();
                possible = possible.where((User user) {
                    if (user.displayName == null)
                        return false;
                    return user.displayName.toLowerCase().contains(_textEditingController.text.toLowerCase());
                }).toList();
                if (connected.isEmpty && possible.isEmpty)
                    return NoResult(triedBid: false);

                return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: <Widget>[
                        if (possible.isNotEmpty)
                            Padding(
                                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
                                child: Text(
                                    allTranslations.text('chat_people_common'),
                                    style: TextStyle(
                                        color: globals.Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600
                                    ),
                                ),
                            ),
                        if (possible.isNotEmpty)
                            ListView.builder(
                                itemCount: possible.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) => PeopleInCommonGroup(
                                    user: possible[index]
                                )
                            ),
                        if (connected.isNotEmpty)
                            Padding(
                                padding: const EdgeInsets.fromLTRB(12, 24, 12, 6),
                                child: Text(
                                    allTranslations.text('chat_people_contact'),
                                    style: TextStyle(
                                        color: globals.Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600
                                    )
                                ),
                            ),
                        if (connected.isNotEmpty)
                            ListView.builder(
                                itemCount: connected.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) => PeopleInContactList(
                                    user: connected[index]
                                )
                            ),
                        Padding(
                            padding: const EdgeInsets.only(left: 12, right: 12, top: 24),
                            child: ContactNotFound(),
                        )
                    ],
                );
            }
        );
    }

    @override
    Widget build(BuildContext context) {
        return MyFullscreenBottomSheetWrapper(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    AppBar(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                        ),
                        leading: IconButton(
                            icon: const Icon(Icons.arrow_back, color: globals.Colors.brownGray),
                            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                            onPressed: () {
                                Navigator.of(context).maybePop();
                            },
                        ),
                        elevation: 1,
                        centerTitle: false,
                        titleSpacing: 0,
                        title: TextField(
                            key: const Key('input-field'),
                            controller: _textEditingController,
                            autofocus: true,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                                hintText: allTranslations.text('chat_search_by_id'),
                                hintStyle: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    color: globals.Colors.lightGray
                                ),
                                border: InputBorder.none
                            ),
                            style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                            ),
                            cursorColor: Colors.black,
                            onSubmitted: (String text) {
                                if (CommonController.checkBid(text.trim())) {
                                    _searchWithBid(text.trim());
                                } else {
                                    setState(() {});
                                }
                            },
                        ),
                        actions: <Widget>[
                            if (_textEditingController.text.isNotEmpty)
                                IconButton(
                                    icon: Icon(Icons.cancel, color: globals.Colors.brownGray, size: 24),
                                    onPressed: () {
                                        setState(() {
                                            _textEditingController.text = '';
                                        });
                                    },
                                ),
                            Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(right: 9),
                                child: MySendButton(
                                    key: const Key('chat_search'),
                                    text: allTranslations.text('chat_search'),
                                    onTap: () {
                                        if (CommonController.checkBid(_textEditingController.text.trim())) {
                                            _searchWithBid(_textEditingController.text.trim());
                                        } else {
                                            setState(() {});
                                        }
                                    },
                                ),
                            )
                        ]
                    ),
                    Expanded(
                        child: Center(
                            heightFactor: 1.5,
                            child: searchPeople()
                        )
                    )
                ]
            )
        );
    }
}