import 'package:flutter/material.dart';

import '../project_resources/project_colors.dart';

class ComposeHelpWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compose Entry Guide'),
      ),
      body: ListView(
        children: [
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
          ),
          ListTile(
            title: Text(
                "This guide should help clear up any confusion you might have about how to use the create/edit journal entry screen."),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
          ),
          ListTile(
            title: Text('Title Text Field'),
            subtitle: Text(
                'The text box named \"What do you want to call this?\" is where you would want to put the name of the event at.'),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
          ),
          ListTile(
            title: Text('Event Description Text Field'),
            subtitle: Text(
                'The text box named  \"What happened?\" is where you would put what happened during the event.'),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
          ),
          ListTile(
            title: Text('The Rating Slider'),
            subtitle: Text(
                'The rating slider is scaled from 0 to 100. The ranking is based on 0 being the worst, and 100 being excellent.'),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
          ),
          ListTile(
            title: Text('The Additional Thoughts/Sources Text Field'),
            subtitle: Text(
                'This field is used for adding personal thoughts to the current entry being edited/composed and can be used to add your opinion or simply any lessons you think you learned from the experience.'),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
          ),
          ListTile(
            title: Text('The Tags Text Field'),
            subtitle: Text(
                'The categories text box is where you can add tags to the entry for gathering by category type. It makes searching a lot easier if you don\'t remember what entries you\'re looking for.'),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
          ),
          ListTile(
            title: Text('The success/fail switch'),
            subtitle: Text(
                'This is where you can classify if you thought the event was a success or a fail.'),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
          ),
          ListTile(
            title: Text('ADHD Symptom field'),
            subtitle: Text(
                'This is where you identify what particular ADHD Symptoms affected the outcome or triggered the event. You\'ll need to click on the field to access the selection screen.\r\n'
                    'These are sorted by category and by severity going from best to worst. The first category is the list of  positive effects of ADHD and shouldn\'t be conseidered sorted this way.\r\n'
                    'Hit save when completed on this screen.'),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
          ),
        ],
      ),
    );
  }
}
