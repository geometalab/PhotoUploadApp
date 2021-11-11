import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../commonsUploadFragment.dart';

class StatefulInformationFragment extends StatefulWidget {
  @override
  _InformationFragment createState() => _InformationFragment();
}

class _InformationFragment extends State<StatefulInformationFragment> {
  InformationCollector collector = new InformationCollector();

  DateTime selectedDate = InformationCollector().date;
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1, 1),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      setState(() {
        collector.date = picked;
        selectedDate = picked;
      });
    }
  }

  // Find field info here: https://commons.wikimedia.org/wiki/Template:Information
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
          child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: collector.fileName,
                  onChanged: (value) {
                    collector.fileName = value;
                  },
                  // TODO check file name for illegal chars, maybe enforce min and max length
                  decoration: const InputDecoration(
                    icon: Icon(Icons.file_copy_outlined),
                    labelText: 'File Name',
                    hintText: 'Choose a descriptive name',
                  ),
                ),
              ),
              if (collector.fileType != null)
                Padding(
                  padding: EdgeInsets.only(right: 8, left: 8, top: 16),
                  child: Text(collector.fileType!,
                      style: Theme.of(context).textTheme.subtitle1),
                ),
            ],
          ),
        ),
        Padding(
          // TODO allow desc in different languages, also multiple languages per image.
          padding: EdgeInsets.all(8),
          child: TextFormField(
              initialValue: collector.description,
              onChanged: (value) {
                collector.description = value;
              },
              maxLines: 7,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                icon: Icon(Icons.text_fields_outlined),
                labelText: 'Description',
                hintText: 'Write a meaningful description',
              )),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: TextFormField(
              initialValue: collector.source,
              onChanged: (value) {
                collector.source = value;
              },
              // TODO is it always "Own Work"? Or should there at least be a checkbox "not my work" (and only when checked show textfield)?
              decoration: const InputDecoration(
                  icon: Icon(Icons.source),
                  labelText: 'Source',
                  hintText: 'If made by you, enter "Own Work"')),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: TextFormField(
              initialValue: collector.author,
              onChanged: (value) {
                collector.author = value;
              },
              decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  labelText: 'Author',
                  hintText: 'Original author of the file')),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: Colors.grey[600],
                  ),
                  Padding(padding: EdgeInsets.only(left: 18)),
                  Text(
                    "License: ",
                    textScaleFactor: 1.2,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: collector.license,
                onChanged: (String? newValue) {
                  setState(() {
                    collector.license = newValue!;
                  });
                },
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                underline: Container(
                  height: 2,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                items: <String>[
                  // TODO help menu/guide or something for licenses
                  'CC0',
                  'Attribution 3.0',
                  'Attribution-ShareAlike 3.0',
                  'Attribution 4.0',
                  'Attribution-ShareAlike 4.0'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey[600],
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 9)),
                    Text(
                      'Date:',
                      textScaleFactor: 1.2,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                    Text(
                      DateFormat.yMd()
                          .format(collector.date), // TODO local format as well
                      textScaleFactor: 1.1,
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _selectDate(context),
                        child: Text('Select date'),
                      )
                    ]),
              )
            ],
          ),
        ),
      ])),
    );
  }
}
