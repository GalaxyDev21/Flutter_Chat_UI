import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:organizer/common/clipboard_helper.dart';
import 'package:organizer/common/qrcode_helper.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/option.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/user/user_model.dart';
import 'package:organizer/services/router_service.dart';
import 'package:organizer/views/chat/group/create_group.dart';
import 'package:organizer/views/chat/people/people_in_common_group.dart';
import 'package:organizer/views/chat/people/search_by_id_name.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet.dart';
import 'package:organizer/views/components/future_builder.dart';
import 'package:organizer/views/components/modal_bottom_sheet_header.dart';
import 'package:organizer/views/components/option_tile.dart';
import 'package:organizer/views/components/tile.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:organizer/views/components/dual_color_tile.dart';
import 'package:organizer/views/profile/channel_profile/channel_profile_route.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/views/profile/self_qr_code.dart';
import 'package:organizer/views/profile/user_profile/user_profile_route.dart';

class AddContact extends MyFullscreenBottomSheet {

    AddContact();
    
    @override
    State<AddContact> createState() => AddContactState();
}

class AddContactState extends MyFullscreenBottomSheetState<AddContact> {

    final UserController _userController = UserController();
    Future<User> _me;
    Future<Contact> _getContacts;
    
    @override
    void initState() {
        super.initState();
        _me = _userController.getMe();
        _getContacts = _userController.getContacts();
        mainTitle = allTranslations.text('chat_add_to_contact');
    }

    Future<void> _addByQR() async {
        final List<String> result = await QRCodeHelper.scanQRCode();
        switch(result.last) {
            case 'U': {
                RouterService.instance.navigateTo(UserProfileRoute.buildPath(result.first), context: context);
            }
            break;
            case 'O': {
                RouterService.instance.navigateTo(ChannelProfileRoute.buildPath(result.first), context: context); //todo: change to sid
            }
            break;
            default: {
                print('Invalid QR');
            }
            break;
        }
    }

    @override
    Widget mainWidget() {
        return ListView(
            children: <Widget>[
                const Padding(padding: EdgeInsets.symmetric(vertical: 6)),
                MyOptionTile(
                    option: Option(title: 'chat_search_by_id', icon: Icons.search),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () async {
                        final String channelId = await Navigator.of(context).push(
                            MaterialPageRoute<String>(
                                builder: (BuildContext context) {
                                    return SearchByIDorName(
                                        getContacts: _getContacts
                                    );
                                }
                            )
                        );
                        if (channelId != null) {
                            final ChatListController chatListController = ChatListController();
                            final Channel channel = chatListController.channels.firstWhere((Channel channel) {
                                return channel.info.friendlyName == channelId;
                            });
                            if (channel != null) {
                                chatListController.chatNotifier.navigate(channel);
                                Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
                            }
                        }
                    }
                ),
                MyOptionTile(
                    option: Option(title: 'chat_scan_qrcode', icon: MdiIcons.qrcodeScan),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: _addByQR
                ),
                MyOptionTile(
                    option: Option(title: 'chat_create_group', icon: MdiIcons.accountGroup),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () async {
                        Navigator.of(context).push(
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) {
                                    return CreateGroup();
                                }
                            )
                        );
                    }
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                    child: Text(
                        allTranslations.text('chat_let_find'),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                        )
                    ),
                ),
                MyOptionTile(
                    padding: const EdgeInsets.only(left: 12),
                    option: const Option(title: 'chat_qrcode', icon: MdiIcons.qrcode),
                    onPressed: () async {
                        showMyModalBottomSheet(
                            context: context,
                            fullScreen: true,
                            child: Column(
                                children: <Widget>[
                                    MyModalBottomSheetHeader(
                                        child: MyTile(
                                            option: const Option(title: 'chat_your_qr', icon: Icons.close),
                                            onIconPressed: () => Navigator.of(context).maybePop(),
                                        )
                                    ),
                                    Expanded(
                                        child: SelfQrCode(
                                            userController: _userController,
                                        )
                                    )
                                ]
                            )
                        );
                    },
                ),
                MyFutureBuilder<User>.spin(
                    future: _me,
                    builder: (BuildContext context, User user) {
                        return DualColorTile(
                            title: Text(
                                allTranslations.text('chat_id_short'),
                            ),
                            content: Text(
                                user.bid,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700
                                )
                            ),
                            trailing: IconButton(
                                icon: Icon(
                                    MdiIcons.fileMultiple,
                                    color: globals.Colors.lightRed,
                                ),
                                onPressed: () {
                                    if (user != null) {
                                        copyToClipboard(
                                            context: context,
                                            data: ClipboardData(text: user.bid)
                                        );
                                    }
                                },
                            )
                        );
                    },
                ),
                MyFutureBuilder<Contact>.bounce(
                    future: _getContacts,
                    builder: (BuildContext context, Contact contact) {
                        final List<User> possible = contact.possible;
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                if (possible.isNotEmpty)
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                                        child: Text(
                                            allTranslations.text('chat_people_you_know'),
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                                color: globals.Colors.black,
                                            )
                                        ),
                                    ),
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: ListView.builder(
                                        itemCount: possible.length,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemBuilder: (BuildContext context, int index) => PeopleInCommonGroup(
                                            user: possible[index],
                                            buttonKey: index == 0 ? const Key('first_people') : null,
                                        )
                                    ),
                                )
                            ],
                        );
                    }
                )
            ],
        );
    }
}