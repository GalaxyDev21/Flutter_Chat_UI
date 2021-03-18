import 'package:flutter/material.dart';
import 'package:organizer/controllers/chat/channel_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet_wrapper.dart';
import 'package:organizer/views/components/modal_bottom_sheet_navbar.dart';
import 'package:organizer/views/profile/self_qr_code.dart';

class DisplayGroupQR extends StatelessWidget {

    DisplayGroupQR({
        @required this.channel
    });

    final ChannelController _channelController = ChannelController();
    Channel channel;

    @override
    Widget build(BuildContext context) {
        return MyFullscreenBottomSheetWrapper(
            child: Column(
                children: <Widget>[
                    MyModalSheetNavBar(
                        mainTitle: allTranslations.text('chat_group_qr'),
                    ),
                    Expanded(
                        child: ChannelQrCode(
                            channel: channel,
                            channelController: _channelController
                        ),
                    )
                ]
            )
        );
    }
}