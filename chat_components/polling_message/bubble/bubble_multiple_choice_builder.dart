import 'package:flutter/material.dart';
import 'package:organizer/icons_icons.dart';
import 'package:organizer/controllers/chat/polling_message_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/pojo/polling_answer.dart';
import 'package:organizer/pojo/polling_question.dart';
import 'package:organizer/views/components/polling_multiple_choice_tile.dart';
import 'package:provider/provider.dart';

class BubbleMultipleChoiceBuilder extends StatefulWidget {
    
    BubbleMultipleChoiceBuilder({
        @required this.channelSid,
        @required this.pollingId,
        this.isOutsidePublisher,
        this.viewOnly, 
        this.viewOnlyQuestion, 
        this.viewOnlyChoices,
    });

    final String channelSid;
    final String pollingId;
    final bool isOutsidePublisher;
    bool viewOnly = false;
    final String viewOnlyQuestion;
    final List<String> viewOnlyChoices;

    @override
    _BubbleMultipleChoiceBuilderState createState() => _BubbleMultipleChoiceBuilderState();
}

class _BubbleMultipleChoiceBuilderState extends State<BubbleMultipleChoiceBuilder> {
    
    PollingQuestion _question;
    List<PollingAnswer> _answers;
    PollingMessageController pollingMessageController;
    int numberOfVotes = 0;
    bool hasUserVoted = false;
    String userVotedAnswerId;

    @override
    void initState() {
        super.initState();
        pollingMessageController = PollingMessageController(channelSid: widget.channelSid);
    }
    
    @override
    void dispose() {
        super.dispose();
    }


    List<Widget> clickableMultipleChoiceBuilder(PollingQuestion question, List<PollingAnswer> answers) {
        return answers.map((PollingAnswer answer) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: MyPollingMultipleChoiceTile(
                question: question,
                answer: answer,
                hasUserVoted: hasUserVoted,
                userVotedAnswerId: userVotedAnswerId,
                pollingMessageController: pollingMessageController,
                isOutsidePublisher: widget.isOutsidePublisher,
                viewOnly: widget.viewOnly,
            )
        )).toList();
    }


    @override
    Widget build(BuildContext context) {
        if (widget.viewOnly) {
            _question = PollingQuestion(question: widget.viewOnlyQuestion);
            _answers = [];
            widget.viewOnlyChoices.forEach((String choice) => _answers.add(PollingAnswer(answer: choice)));
        }
        else {
            _question = Provider.of<PollingQuestion>(context);
            _answers = Provider.of<List<PollingAnswer>>(context);
            numberOfVotes = 0;
            for (PollingAnswer answer in _answers) {
                if (answer.voters.contains(UserController.currentUser.uid)) {
                    hasUserVoted = true;
                    userVotedAnswerId = answer.id;
                }
                numberOfVotes += answer.voters.length;
            }
        }
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    ),
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
                ...clickableMultipleChoiceBuilder(_question, _answers),
                const Divider(height: 1, color: globals.Colors.veryLightGray),
                if (!widget.viewOnly)
                    Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                            children: <Widget>[
                                Text(
                                    widget.isOutsidePublisher
                                    ? '? members answered'
                                    : (numberOfVotes <= 1 ? '$numberOfVotes member answered' : '$numberOfVotes members answered'),
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