import 'package:flutter/material.dart';
import 'package:groupproject/models/Polls.dart';

import '../../../notifications.dart';

class CreatePollPage extends StatefulWidget {
  const CreatePollPage({Key? key}) : super(key: key);

  @override
  State<CreatePollPage> createState() => _CreatePollPageState();
}

class _CreatePollPageState extends State<CreatePollPage> {
  var formKey = GlobalKey<FormState>();

  String? title = "";
  String? timeString = "";
  String? description = "";
  String? userName = "";
  List<dynamic> pollOptions = ["", "", "", ""];
  List<dynamic> pollResults = [0, 0, 0, 0];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Poll"),),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Author",
                      hintText: "Enter your username",
                    ),
                    onChanged: (value) {
                      userName = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Headline",
                      hintText: "Enter the title of your poll",
                    ),
                    onChanged: (value) {
                      title = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Description",
                      hintText: "What would you like to tell the pollers",
                    ),
                    onChanged: (value) {
                      description = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Choice 1",
                      hintText: "Enter an answer to your poll",
                    ),
                    onChanged: (value) {
                      pollOptions[0] = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Choice 2",
                      hintText: "Enter an answer to your poll",
                    ),
                    onChanged: (value) {
                      pollOptions[1] = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Choice 3",
                      hintText: "Enter an answer to your poll",
                    ),
                    onChanged: (value) {
                      pollOptions[2] = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Choice 4",
                      hintText: "Enter an answer to your poll",
                    ),
                    onChanged: (value) {
                      pollOptions[3] = value;
                    },
                  ),

                  ElevatedButton(
                      onPressed: (){
                        String? postTime = formatTime();
                        timeString = postTime;
                        pollOptions.removeWhere((item) => ["", null].contains(item));
                        if (pollOptions.length <= 1){
                        Navigator.of(context).pop(null);
                        }
                        else {
                          Polls newPoll = Polls(
                              userName: userName,
                              title: title,
                              timeString: timeString,
                              description: description,
                              pollOptions: pollOptions,
                              pollResults: pollResults
                          );
                          var snackBar = const SnackBar(
                              duration: Duration(seconds: 1),
                              content: Text("Poll Created!"));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Navigator.of(context).pop(newPoll);
                        }
                      },
                      child: const Text("Create Post")),
                ]
            ),
          ),
        ),
      ),
    );
  }

  String? formatTime() {
    DateTime now = DateTime.now();
    String dayHalf = "";
    int adjustedHour = now.hour;
    String? adjustedMinute = now.minute.toString();
    String? adjustedSecond = now.second.toString();
    if (adjustedHour >= 12) {
      dayHalf = "pm";
      if (adjustedHour != 12) {
        adjustedHour -= 12;
      }
    } else {
      dayHalf = "am";
      if (adjustedHour == 0) {
        adjustedHour += 12;
      }
    }
    if (now.minute < 10) {
      adjustedMinute = "0$adjustedMinute";
    }
    if (now.second < 10) {
      adjustedSecond = "0$adjustedSecond";
    }
    return "${now.day}-${now.month}-${now.year} at $adjustedHour:$adjustedMinute:$adjustedSecond$dayHalf";
  }

}
