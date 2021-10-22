import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  // TODO implement additional fields if needed
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
          child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.all(8),
          child: TextFormField(
              initialValue: collector.fileName,
              onChanged: (value) {
                collector.fileName = value;
              },
              decoration: const InputDecoration(
                icon: Icon(Icons.file_copy_outlined),
                labelText: 'File Name',
                hintText: 'Choose a descriptive name',
              )),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: TextFormField(
              // TODO big text field doesn't soft wrap
              initialValue: collector.description,
              onChanged: (value) {
                collector.description = value;
              },
              decoration: const InputDecoration(
                icon: Icon(Icons.text_fields_outlined),
                labelText: 'Description',
                hintText: 'Write a meaningful description',
                contentPadding: const EdgeInsets.only(bottom: 100),
              )),
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
                      "${selectedDate.toLocal()}".split(' ')[0],
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
