

import 'package:adhd_journal_flutter/project_strings_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LinkTilesDataClass{
  Text title;
  Uri url;

  LinkTilesDataClass({
    required this.title,
    required this.url
});
}
// List of website links
var linkArray = [
  LinkTilesDataClass( title: Text('Additude magazine'),url:Uri.parse(link_additudemag_website)),
  LinkTilesDataClass(title: Text('CHADD.org'), url: Uri.parse(link_chadd_website)),
];
var youtube_LinksArray =[
  LinkTilesDataClass( title: Text('How to ADHD Youtube Channel'),url:Uri.parse(link_how_to_ADHD_YT)),
];
