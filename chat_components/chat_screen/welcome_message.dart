import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/user/user_model.dart';
import 'package:organizer/views/components/oval_avatar.dart';
import 'package:organizer/views/components/quick_note_avatar.dart';
import 'package:provider/provider.dart';

class WelcomeMessage extends StatelessWidget {

    const WelcomeMessage(this.channel);

    final Channel channel;

    @override
    Widget build(BuildContext context) {
        if (channel == null)
            return Container();
        return _WelcomeMessage(channel);
    }
}
// TO PREVENT API CALLS TOO MUCH
// https://stackoverflow.com/questions/55683803/flutter-page-keeps-reloading-every-time-on-navigation-pop
// https://stackoverflow.com/questions/57330202/how-to-avoid-reloading-data-every-time-navigating-to-page
// https://medium.com/saugo360/flutter-my-futurebuilder-keeps-firing-6e774830bc2
class _WelcomeMessage extends StatefulWidget {

    const _WelcomeMessage(this.channel);

    final Channel channel;

    @override
    _WelcomeMessageState createState() => _WelcomeMessageState();
}

class _WelcomeMessageState extends State<_WelcomeMessage> {

    String path;
    IconData icon;
    String title;
    String subtitle;
    String description;
    // Future<User> _getUser;
    
    @override
    void initState() {
        super.initState();
        // _getUser = UserController().getUserFromUid(widget.channel.name);
    }

    @override
    Widget build(BuildContext context) {
        switch (widget.channel.type) {
            case ChannelType.PRIVATE:
                icon = Icons.person;
                break;
            case ChannelType.ORGANIZATION:
                icon = MdiIcons.accountGroup;
                title = widget.channel.name;
                subtitle = allTranslations.text('chat_welcome_group_subtitle');
                description = widget.channel.description ?? '';
                break;
            case ChannelType.SELF:
                title = allTranslations.text('chat_welcome_self_title');
                subtitle = allTranslations.text('chat_welcome_self_subtitle');
                break;
            default:
                return Container();
        }
        if (widget.channel.type != ChannelType.PRIVATE)
            return WelcomeMessageBuilder(
                channelType: widget.channel.type,
                icon: icon,
                title: title,
                subtitle: subtitle,
                description: description,
                channel: widget.channel,
            );
        return Selector<UsersInfo, String>(
            selector: (BuildContext context, UsersInfo usersInfo) => usersInfo.user(widget.channel.name)?.displayName,
            builder: (BuildContext context, String displayName, Widget child){ 
                title = displayName ?? '';
                subtitle = '${allTranslations.text('chat_welcome_private_subtitle')} $title.';
                return WelcomeMessageBuilder(
                    channelType: widget.channel.type,
                    icon: icon,
                    title: title,
                    subtitle: subtitle,
                    description: description,
                    channel: widget.channel,
                );
            }
        );
    }
}

class WelcomeMessageBuilder extends StatelessWidget {

    const WelcomeMessageBuilder({
        @required this.channelType,
        // @required this.path,
        @required this.icon,
        @required this.title,
        @required this.subtitle,
        @required this.description,

        this.channel
    });

    final ChannelType channelType;
    // final String path;
    final IconData icon;
    final String title;
    final String subtitle;
    final String description;
    final Channel channel;
    @override
    Widget build(BuildContext context) {
        return Column(
            children: <Widget>[
                if (channelType == ChannelType.SELF)
                    MyQuickNoteAvatar(
                        chatListVersion: false,
                        imagePadding: 6
                    )
                else      
                    MyOvalAvatar.fromChannel(channel,iconRadius: 60),
                Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Center(
                        child: Text(
                            title, 
                            style: TextStyle(
                                fontSize: 20,
                                color: globals.Colors.black,
                                fontWeight: FontWeight.w600
                            ),
                        ),
                    ),
                ),
                description != null && description != ''
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Center(
                            child: Text(
                                description,
                                style: const TextStyle(
                                    color: globals.Colors.gray
                                ),
                                textAlign: TextAlign.center,
                                )
                            ),
                        )
                    : Container(),
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: Center(
                        child: Text(
                            subtitle,
                            style: const TextStyle(
                                color: globals.Colors.gray
                            ),
                            textAlign: TextAlign.center,
                        )
                    ),
                )
            ]
        );
    }   
}
