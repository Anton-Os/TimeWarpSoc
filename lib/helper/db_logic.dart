import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:timewarpsoc/helper/timeline_types.dart';
import 'package:timewarpsoc/helper/timeline_conversion.dart';

// TODO: Database classes should be wrapped in ChangeValueNotifier classes

// Local Fetching

class SavedPrefsData {
  SavedPrefsData(){}

  Future<void> init() async {
    sharedPrefs = await SharedPreferences.getInstance();

    if(sharedPrefs.getStringList('exclusionIndices') == null)
      sharedPrefs.setStringList('exclusionIndices', exclusionIndices.map((i) => i.toString()).toList());
    /* else
      exclusionIndices = sharedPrefs.getStringList('exclusionIndices').map((s) => int.parse(s)).toList(); */

    if(sharedPrefs.getStringList('creationIndices') == null)
      sharedPrefs.setStringList('creationIndices', exclusionIndices.map((i) => i.toString()).toList());
    /* else
      creationIndices = sharedPrefs.getStringList('creationIndices').map((s) => int.parse(s)).toList(); */
  }

  void addExclusionIndex(int index){
    exclusionIndices.add(index); // Add target element
    sharedPrefs.setStringList('exclusionIndices', exclusionIndices.map((i) => i.toString()).toList()); // Update shared prefs
  }

  void addCreationIndex(int index){
    creationIndices.add(index); // Add target element
    sharedPrefs.setStringList('creationIndices', exclusionIndices.map((i) => i.toString()).toList()); // Update shared prefs
  }

  SharedPreferences sharedPrefs;
  List<int> creationIndices = [];
  List<int> exclusionIndices = [];
}

// Network Fetching

class SearchRecords_FirebaseDB {
  SearchRecords_FirebaseDB(){}

  Future<void> init() async {
    // TODO: Refine database entries, storing name is not enough!
    Firestore.instance.collection('timelines').document('SearchRecord').get()
    .then((DocumentSnapshot snapshot){

        //Map<String, String> searchRecMap = snapshot.data.entries;
        searchRecMap = snapshot.data.entries;
        searchRecMap.forEach((element) {
          String keyStr = element.key;
          String valStr = element.value;
          print("$keyStr maps to $valStr in Search Records!"); // TEST CASE
        });
    });
  }

  Iterable<MapEntry<String, dynamic>> getRecords(List<int> exclusionIndices, List<int> creationIndices){
    if(searchRecMap.isEmpty){
      print("Cannot call get records while empty");
      return null;
    }

    List<MapEntry<String, dynamic>> finRecords = [];

    for(int c = 0; c < creationIndices.length; c++) // Created timelines appear first
      finRecords.add(searchRecMap.elementAt(c));

    for(int r = 0; r < searchRecMap.length; r++){
      bool skipCase = false;
      exclusionIndices.forEach((element) {
        if(element == r)
          skipCase = true;
      });

      creationIndices.forEach((element) { // We are avoiding the created timelines from reappearing twice
        if(element == r)
          skipCase = true;
      });

      if(! skipCase) finRecords.add(searchRecMap.elementAt(r));
    }

    return finRecords;
  }

  Future<void> addEntry(String docId, String docName){
    Firestore.instance.collection('timelines').document('SearchRecord').updateData( {docId : docName} );
    // Adds a new element to the Search Records
  }

  Iterable<MapEntry<String, dynamic>> searchRecMap = [];
}

class Timeline_FirebaseDB extends ChangeNotifier {
  Timeline_FirebaseDB({ this.firebaseDocStr }) {}

  final String firebaseDocStr;
  TimelineData data = new TimelineData();

  Future<void> init() async {
    // TODO: Support apple version as well eventually
    if(data.segments.isNotEmpty) return; // Avoiding extra re-runs

    Firestore.instance.collection('timelines').document(firebaseDocStr).get()
    .then((DocumentSnapshot snapshot) {

      // TODO: Check for null data

      Iterable<MapEntry<String, dynamic>> timelineMap = snapshot.data.entries;
      // MapEntry<String, dynamic> currentMap = timelineMap.first; // Data from first element
      for(MapEntry entry in timelineMap){
        print("Found $entry field in timelineMap");

        if(entry.key[0] == '_') { // For things not displayed as timeline items
          Map<String, dynamic> item_entries = new Map<String, dynamic>.from(entry.value);
          switch(entry.key){
            case("_Meta"):
              item_entries.forEach((key, value) {
                switch(key){
                  case("dates"):
                    data.titleDatesStr = value;
                    break;
                  case("description"):
                    data.titleDescStr = value;
                    break;

                  default:
                    print("Unknown $key field encountered!");
                    break;
                }
              });
              break;
            case("_Theme"):
              data.themeColors = item_entries.entries;
              break;

            deault:
              print("Unknown $entry special field encountered");
              break;
          }
        }
        else {

          String desc = "";
          TimePoint tp1;
          TimePoint tp2;

          Map<String, dynamic> item_entries = new Map<String, dynamic>.from(entry.value);

          int itemIndex = 0; // To avoid RangeError use indexing instead
          while(itemIndex < item_entries.length){
            MapEntry item_entry = item_entries.entries.elementAt(itemIndex);
            switch (item_entry.key) {
              case("start"):
                tp1 = new TimePoint(
                    year: getYearFromInput(item_entry.value.toString()),
                    extension: getExtFromInput(item_entry.value.toString())
                );
                break;
              case("end"):
                tp2 = new TimePoint(
                    year: getYearFromInput(item_entry.value.toString()),
                    extension: getExtFromInput(item_entry.value.toString())
                );
                break;
              case("desc"):
                desc = item_entry.value.toString(); // TODO: Fix with new
                break;
              default:
                print("Not yet supported!!!");
                break;
            }
            itemIndex++;
          }

          TimelineSegData segment = new TimelineSegData(
              header: entry.key, desc: desc, tp1: tp1, tp2: tp2
          );

          data.segments.add(segment);
        }
      }

      // Comparison function accurate down to hour comparison
      data.segments.sort((TimelineSegData seg1, TimelineSegData seg2) {
        if(seg1.tp1.year.compareTo(seg2.tp1.year) != 0) return seg1.tp1.year.compareTo(seg2.tp1.year); // Years Match for else statement
        else
          if(getNumFromMonth(seg1.tp1.month).compareTo(getNumFromMonth(seg2.tp1.month)) != 0) return getNumFromMonth(seg1.tp1.month).compareTo(getNumFromMonth(seg2.tp1.month)); // Months Match for else statement
          else
            if(seg1.tp1.day.compareTo(seg2.tp1.day) != 0) return seg1.tp1.day.compareTo(seg2.tp1.day); // Days Match for else statement
            else return seg1.tp1.hour.compareTo(seg2.tp1.hour);
      });

      notifyListeners();
    });
  }

  Future<void> initDefaults() async {
    data.titleDatesStr = '(Insert start date here) to (Insert end date here)'; // Default dates string
    data.titleDescStr = 'Insert a brief description of the timeline here';

    // TODO: Add all default themes
    // TODO: Format the code below correctly
    Map<String, dynamic> title_colors = { 'Primary': 0xFF555555, 'Secondary': 0xFF575757, 'Text': 0xFFAEAEAE };
    Map<String, dynamic> item_colors = { 'Primary': 0xFF555555, 'Secondary': 0xFF575757, 'Text': 0xFFAEAEAE, 'Filler': 0xFF525252 };
    Map<String, dynamic> center_colors = { 'Primary': 0xFF555555, 'Secondary': 0xFF575757, 'Text': 0xFFAEAEAE };

    Iterable<MapEntry<String, dynamic>> themeColor_entries = [
      MapEntry('Title Colors', title_colors),
      MapEntry('Item Colors', item_colors),
      MapEntry('Center Colors', center_colors),
    ];
    data.themeColors = themeColor_entries; // TODO: See if this functions correctly

    // Notify listeners here??
  }

  // Adds a segment of data and overrides database entries
  void addDataSeg(TimelineSegData newSegData){
    data.segments.add(newSegData);

    // Comparison function accurate down to hour comparison
    data.segments.sort((TimelineSegData seg1, TimelineSegData seg2) {
      if(seg1.tp1.year.compareTo(seg2.tp1.year) != 0) return seg1.tp1.year.compareTo(seg2.tp1.year); // Years Match for else statement
      else
        if(getNumFromMonth(seg1.tp1.month).compareTo(getNumFromMonth(seg2.tp1.month)) != 0) return getNumFromMonth(seg1.tp1.month).compareTo(getNumFromMonth(seg2.tp1.month)); // Months Match for else statement
        else
          if(seg1.tp1.day.compareTo(seg2.tp1.day) != 0) return seg1.tp1.day.compareTo(seg2.tp1.day); // Days Match for else statement
          else return seg1.tp1.hour.compareTo(seg2.tp1.hour);
    });

    // TODO: See if the new data replaces the old
    // Firestore.instance.collection('timelines').document(firebaseDocStr).setData( Map.fromIterable(data.segments) );

    notifyListeners();
  }
}
