import 'package:flutter/material.dart';

import '../project_resources/project_colors.dart';

class DashboardHelp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Guide'),
      ),
      body: ListView(
        children: [
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
          ),
          const ListTile(
            title: Text(
                "This guide should help you clear up any confusion about how the dashboard works."),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
          ),
          const ListTile(
            title: Text(
              "The summary card",
            ),
            subtitle: Text(
                'This is a summary of how many journal entries you have, what\'s trending in terms of fail/success, average ratings, and most recently occurring ADHD Symptoms. \r\n'),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
          ),
          const ListTile(
            title: Text('The graphing cards'),
            subtitle: Text(
                'The cards correspond to each statistic collected from your journal to display on screen. The ratings graph displays the ratings values from the start of your journal to most recently created.\r\n'
                ' The emotions and symptoms bar graphs collect info on what symptoms are present the most and how you\'ve felt according to your journal entries. \r\n'
                ' The Success/Fail pie chart shows how many entries you\'ve recorded a successful and what you recorded as failures.'),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
          ),
          const ListTile(
            title: Text('How to zoom in on each card'),
            subtitle: Text(
                'Each card has the ability to zoom and pan by simply double tapping on the graph where you\'re wanting to zoom in on. Double tapping the graph deactivates it for scrolling.\r\n'
                'Each card has a reset button to reset the zoom back to normal so you can continue scrolling.'),
          ),
        ],
      ),
    );
  }
}
