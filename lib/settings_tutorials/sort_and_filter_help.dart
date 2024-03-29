import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../project_resources/project_colors.dart';

class SortHelp extends StatelessWidget {
  const SortHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(builder: (context, swapper, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sorting and Searching Guide'),
        ),
        body: ListView(
          children: [
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
            ),
            const ListTile(
              title: Text(
                  "This guide should help you with sorting and searching for specific entries in your journal. They use both the search and sort buttons on the top of the diary list screen."),
              subtitle: Text(
                  'This feature allows you to easily search your entire journal for any specific entries by text search. It will list them on screen after you hit search on the dialog window. '),
            ),
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
            ),
            const ListTile(
              title: Text("Search Function"),
              subtitle: Text(
                  'This feature allows you to easily search your entire journal for any specific entries by text search. It will list them on screen after you hit search on the dialog window. '),
            ),
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
            ),
            const ListTile(
              title: Text("Sorting Function"),
              subtitle: Text(
                  'This will allow you to sort the records by type such as most recent, time created, alphabetical (By title name), and ratings. The default sort method is done by most recent entries.'),
            ),
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
            ),
            const ListTile(
              title: Text("The Reset Button"),
              subtitle: Text(
                  'This will reset the search filter and sort the list by its default setting.'),
            )
          ],
        ),
      );
    });
  }
}
