//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:groupproject/models/PostOnline.dart';
import 'package:provider/provider.dart';
import 'package:groupproject/notifications.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../models/Account.dart';
import '../ProfilePage/ProfilePageBuilder.dart';

/*Sources:
Stopped overflow error: https://www.geeksforgeeks.org/flutter-pixels-overflow-error-while-launching-keyboard/#:~:text=Solution%20%3A,the%20entire%20UI%20is%20centered.
Date format: https://stackoverflow.com/questions/51579546/how-to-format-datetime-in-flutter
*/
class CreatePostWidget extends StatefulWidget {
  const CreatePostWidget({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<CreatePostWidget> createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget> {
  var formKey = GlobalKey<FormState>();
  final notifications = Notifications();

  String? userName = ''; //temp
  String? longDescription = '';
  String? title = '';
  String? imageURL = '';
  String? timeString = '';
  String? shortDecription = '';
  String? locationText;

  // Function that gets the users current location then returns a string that returns
  // their city and province or equivalent
  geocode() async {
    Position location = await Geolocator.getCurrentPosition();
    final List<Placemark> places = await placemarkFromCoordinates(
        location.latitude,
        location.longitude
    );
    return "${places[0].locality.toString()}, ${places[0].administrativeArea.toString()}";
  }

  @override
  Widget build(BuildContext context) {
    //Get the account information, to automatically fill in username.
    final args = ModalRoute.of(context)!.settings.arguments as ProfileArguments;
    tz.initializeTimeZones();
    notifications.init();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title!)),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  enabled: isUsername(args.loggedInUser?.userName),
                  decoration: InputDecoration(
                    labelText: displayAuthor(args.loggedInUser?.userName),
                    hintText: args.loggedInUser?.userName!,
                  ),
                  onChanged: (value) {
                    userName = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: "Headline",
                      hintText: "Enter the title of your article"),
                  onChanged: (value) {
                    title = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: "Subtitle",
                      hintText: "Enter the subtitle of your article"),
                  onChanged: (value) {
                    shortDecription = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: "Body",
                      hintText: "Here is the body of your article"),
                  onChanged: (value) {
                    longDescription = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: "Image",
                      hintText: "Enter a Valid URL for an image"),
                  onChanged: (value) {
                    imageURL = value;
                  },
                ),
                Padding(padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0)),
                Text(formatTime()!, style: TextStyle(
                    fontSize: 20,
                  ),
                ),

                ElevatedButton(
                    onPressed: () async {
                      // Requests permission for location
                      LocationPermission permission;
                      permission = await Geolocator.requestPermission();
                      // If permission is denied, no location is set
                      if (permission == LocationPermission.denied) {
                        locationText = "";
                      }
                      // If permission is granted then it gets the users location
                      else {
                        locationText = await geocode();
                      }
                      String? postTime = formatTime();
                      timeString = postTime;
                      notificationLater();
                      print(locationText);
                      PostOnline newPost = PostOnline(
                        userName: postUserName(userName, args.loggedInUser?.userName),
                        timeString: timeString,
                        longDescription: longDescription,
                        imageURL: imageURL,
                        title: title,
                        shortDescription: shortDecription,
                        numReposts: 0,
                        numLikes: 0,
                        numDislikes: 0,
                        comments: [],
                        location: locationText,
                      );
                      var snackBar = const SnackBar(
                          duration: Duration(seconds: 1),
                          content: Text("Article Posted!"));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      Navigator.of(context).pop(newPost);
                    },
                    child: Text("Create Post")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future notificationLater() async {
    var when = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 3));
    await notifications.sendNotificationLater(
        title!, shortDecription!, "payload!", when);
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

  //If there is a user logged in, The text field to add an Author will be disabled
  bool isUsername(String? user)
  {
    if (user != "Anonymous")
      {
        return false;
      }
    return true;
  }

  //If there is a user logged in, the Text Field will display their user name instead
  String displayAuthor(String? user)
  {
    if (user != "Anonymous")
      {
        return user!;
      }
    return "Author";
  }

  //If there is a user logged in, their username will be automatically inserted as the username for the post
  //Otherwise, it will demonstrate that a guest is logged in.
  String postUserName(String? textUser, String? user)
  {
    if (textUser == "")
      {
        return user!;
      }
    return "${textUser!} (Guest)";
  }

}