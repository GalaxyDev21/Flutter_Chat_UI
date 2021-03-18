import 'package:flutter/material.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:intl/intl.dart';
import 'package:organizer/common/date_utils.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/views/components/fullscreen_bottom_sheet_wrapper.dart';
import 'package:organizer/views/components/modal_bottom_sheet_navbar.dart';
import 'package:organizer/views/components/buttons.dart';

class WellDoneDialog extends StatefulWidget {
    
    final DateTime prayTime;
    WellDoneDialog({@required this.prayTime});
    
    @override
    State<WellDoneDialog> createState() => WellDoneDialogState();
}

class WellDoneDialogState extends State<WellDoneDialog> with TickerProviderStateMixin {
    GifController controller;
    
    @override
    void initState() {
        super.initState();
        controller = GifController(vsync: this, duration: const Duration(milliseconds: 1000));
        controller.value = 0;
        controller.animateTo(20);
    }
    
    @override
    Widget build(BuildContext context) {
        return MyFullscreenBottomSheetWrapper(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    MyModalSheetNavBar(
                        mainTitle: '',
                        leftButton: IconButton(
                            icon: const Icon(Icons.close, color: globals.Colors.brownGray, size: 30),
                            onPressed: () {
                                Navigator.of(context).maybePop();
                            },
                        ),
                    ),
                    Expanded(
                        child: ListView(
                            children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 24),
                                    child: GifImage(
                                        controller: controller,
                                        image: const AssetImage('assets/images/well-done-single.gif'),
                                    ),
                                ),
                                Text(
                                    allTranslations.text('prayer_reminder_well_done'),
                                    style: const TextStyle(
                                        color: globals.Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500
                                    ),
                                    textAlign: TextAlign.center,
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 3, bottom: 35),
                                    child: RichText(
                                        text: TextSpan(
                                            children: <TextSpan>[
                                                TextSpan(
                                                    text: allTranslations.text('prayer_reminder_everyone'),
                                                ),
                                                TextSpan(
                                                    text: DateFormat('h:mm a').format(widget.prayTime.toLocal()),
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold
                                                    )
                                                ),
                                                TextSpan(
                                                    text: ' ${Utils.isSameDay(widget.prayTime.toLocal(), DateTime.now())
                                                        ? allTranslations.text('prayer_reminder_today')
                                                        : allTranslations.text('prayer_reminder_tomorrow')}.',
                                                )
                                            ],
                                            style: const TextStyle(
                                                color: globals.Colors.black,
                                                fontSize: 14,
                                                height: 1.3
                                            ),
                                        ),
                                        textAlign: TextAlign.center,
                                    ),
                                ),
                                Center(
                                    child: shadowGradientButton(
                                        width: 190,
                                        child: Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                                allTranslations.text('prayer_reminder_got_it'),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: globals.Colors.white
                                                ),
                                            ),
                                        ),
                                        onPressed: () {
                                            Navigator.maybePop(context);
                                        }
                                    ),
                                )
                            ],
                        ),
                    )
                ],
            ),
        );
    }
}