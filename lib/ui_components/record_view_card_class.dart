import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../record_data_package/records_data_class_db.dart';

class RecordCardViewWidget extends StatefulWidget {
  RecordCardViewWidget({Key? key, required this.record}) : super(key: key);
  final Records record;

  @override
  State<RecordCardViewWidget> createState() {
    return _RecordCardViewWidget();
  }
}

class _RecordCardViewWidget extends State<RecordCardViewWidget> {
  bool isExpanded = false;
  SizedBox space2 = const SizedBox(width: 8);
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Column(
        children: <Widget>[
          // Title Field

          ExpansionTile(
            tilePadding: EdgeInsets.only(left: 0, right: 0, top: 2, bottom: 0),
            expandedAlignment: Alignment.topLeft,

            title: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      super.widget.record.title,
                      style: TextStyle(overflow: TextOverflow.ellipsis),
                      textAlign: TextAlign.left,
                    )),
                    SizedBox(
                      width: 16,
                    ),
                    Text('Rating: ' + super.widget.record.rating.toString()),
                  ],
                ),
                SizedBox(
                  height: 2,
                ),
                Row(children: [
                  Expanded(
                      child: Text(super.widget.record.content,
                          maxLines: 3,
                          style: TextStyle(overflow: TextOverflow.ellipsis)))
                ]),
              ],
            ),
            // Content field
            children: [
              Divider(
                height: 1,
                color: AppColors.mainAppColor,
              ),
              SizedBox(
                height: 2,
              ),
              //Feelings
              Row(children: [
                Expanded(
                    child: Text(
                  'I felt ' + super.widget.record.emotions.toLowerCase(),
                  style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontStyle: FontStyle.italic),
                  maxLines: 2,
                ))
              ]),
              Divider(
                height: 1,
                color: AppColors.mainAppColor,
              ),
              SizedBox(
                height: 2,
              ),
              //Sources Field
              Row(children: [
                Expanded(
                    child: Text(
                  'My thoughts were: ' + super.widget.record.sources,
                  maxLines: 2,
                  style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontStyle: FontStyle.italic),
                )),
              ]),
              Divider(
                height: 1,
                color: AppColors.mainAppColor,
              ),
              SizedBox(
                height: 2,
              ),
              // Symptom field
              Row(children: [
                Expanded(
                    child: Text(
                  'Related ADHD Symptoms are: ' + super.widget.record.symptoms,
                  maxLines: 2,
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      overflow: TextOverflow.ellipsis),
                )),
              ]),
              Divider(
                height: 1,
                color: AppColors.mainAppColor,
              ),
              SizedBox(
                height: 2,
              ),
              // Success state
              Row(children: [
                Text(
                    'This was a ${(super.widget.record.success ? "success" : "failure")}'),
              ]),
              Divider(
                height: 1,
                color: AppColors.mainAppColor,
              ),
            ],
          ),
          SizedBox(
            height: 2,
          ),
          // This is for timestamp collection
          Row(
            children: [
              Expanded(
                  child: Text(
                'Time created: ' +
                    DateFormat("MM/dd/yyyy hh:mm:ss aa")
                        .format(super.widget.record.timeCreated),
                style: TextStyle(fontStyle: FontStyle.italic),
              )),
              space2,
              Expanded(
                  child: Text(
                'Time updated: ' +
                    DateFormat("MM/dd/yyyy hh:mm:ss aa")
                        .format(super.widget.record.timeUpdated),
                style: TextStyle(fontStyle: FontStyle.italic),
              )),
            ],
          ),
        ],
      ),
      // )
    );
  }
}
