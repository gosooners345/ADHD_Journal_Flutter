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

class PodcastTilesDataClass {
  final Text title;
  final Text host;
  var serviceTitles = [];
  var urlLinks = [];

  PodcastTilesDataClass({
    required this.title ,required this.host, required this.serviceTitles,required this.urlLinks
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
var podcast_LinksArray =[PodcastTilesDataClass(title: Text('ADHD reWired'),host: Text('Dr. Eric Tivers'), serviceTitles:['Apple Podcasts',
  "Spotify",] , urlLinks:link_adhd_rewired ) ];
