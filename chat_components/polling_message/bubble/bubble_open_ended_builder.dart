import 'package:flutter/material.dart';
import 'package:organizer/icons_icons.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/pojo/polling_answer.dart';
import 'package:organizer/pojo/polling_question.dart';
import 'package:provider/provider.dart';

class BubbleOpenEndedBuilder extends StatelessWidget {
    
    int numberOfVotes = 0; 
    
    BubbleOpenEndedBuilder({
        this.isOutsidePublisher,
        this.viewOnly,
        this.viewOnlyQuestion
    });
    
    final bool isOutsidePublisher;
    bool viewOnly = false;
    final String viewOnlyQuestion;
    
    @override
    Widget build(BuildContext context) {
        PollingQuestion _question;
        List<PollingAnswer> _answers;
        if (viewOnly) {
            _question = PollingQuestion(question: viewOnlyQuestion, isStopped: false);
        }
        else {
            _question = Provider.of<PollingQuestion>(context);
            _answers = Provider.of<List<PollingAnswer>>(context);
            numberOfVotes = _answers.length;
        }
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                        children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Icon(
                                    MyIcons.poll,
                                    color: globals.Colors.brownGray
                                )
                            ),
                            Text(
                                allTranslations.text('chat_polling_message'),
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                )
                            )
                        ],
                    )
                ),
                const Divider(height: 1, color: globals.Colors.veryLightGray),
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                        _question.question,
                        style: TextStyle(
                        fontWeight: FontWeight.w600
                        )
                    )
                ),
                const Divider(height: 1, color: globals.Colors.veryLightGray),
                if (!viewOnly)
                    Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                            children: <Widget>[
                                Text(
                                    isOutsidePublisher
                                    ? '? member answered'
                                    : numberOfVotes <= 1 ? '$numberOfVotes member answered' : '$numberOfVotes members answered',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: globals.Colors.gray
                                    )
                                ),
                                const Spacer(),
                                if (_question.isStopped)
                                    Text(
                                        allTranslations.text('chat_polling_message_stopped'),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        )
                                    )
                            ],
                        )
                    )
            ],
        );
    }
}