import 'package:flutter/material.dart';
import '../../../models/Polls.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;

class PollFrequencyTable extends StatefulWidget {
  PollFrequencyTable({Key? key, this.pollsList}) : super(key: key);

  List<Polls>? pollsList;

  @override
  State<PollFrequencyTable> createState() => _PollFrequencyTableState();
}

class _PollFrequencyTableState extends State<PollFrequencyTable> {

  @override
  void initState() {
    for (int i = 0; i < widget.pollsList!.length; i++) {
      List<dynamic> tempPollResults = [0, 0, 0, 0];
      widget.pollsList![i].pollResults!.removeWhere((item) => ["None", null].contains(item));

      for (int j = 0; j < widget.pollsList![i].pollResults!.length; j++) {
        tempPollResults[j] = widget.pollsList![i].pollResults![j];
      }
      widget.pollsList![i].pollResults = tempPollResults;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: (Text("Polls Stats")),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          scrollDirection: Axis.horizontal,
            children: [
              SizedBox(
                height: 1000,
                width: 1000,
                child: charts.BarChart(

                  [
                    charts.Series(
                      id: "Option 1 Votes",
                      data: widget.pollsList!,
                      domainFn: (poll, _) => poll.title,
                      measureFn: (poll, _) => poll.pollResults![0],
                      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,

                    ),
                    charts.Series(
                      id: "Option 2 Votes",
                      data: widget.pollsList!,
                      domainFn: (poll, _) => poll.title,
                      measureFn: (poll, _) => poll.pollResults![1],
                      colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,

                    ),
                    charts.Series(
                      id: "Option 3 Votes",
                      data: widget.pollsList!,
                      domainFn: (poll, _) => poll.title,
                      measureFn: (poll, _) => poll.pollResults![2],
                      colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
                    ),
                    charts.Series(
                      id: "Option 4 Votes",
                      data: widget.pollsList!,
                      domainFn: (poll, _) => poll.title,
                      measureFn: (poll, _) => poll.pollResults![3],
                      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
                    ),

                ],
                animate: true,
                vertical: true,
              ),
            ),]
       )
      ),
    );
  }
}


