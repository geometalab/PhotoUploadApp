import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/datasets.dart' as data;
import 'package:projects/controller/internal/ownWorkHelper.dart';
import 'package:projects/model/informationCollector.dart';
import 'package:projects/style/themes.dart';

class InformationFragment extends StatefulWidget {
  @override
  _InformationFragment createState() => _InformationFragment();
}

class _InformationFragment extends State<InformationFragment> {
  InformationCollector collector = InformationCollector();

  DateTime selectedDate = InformationCollector().date;
  Future<void> _selectDate(BuildContext context) async {
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
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                  value: collector.ownWork,
                  onChanged: (bool? value) async {
                    OwnWorkHelper owh = OwnWorkHelper();
                    if (value == true) {
                      await owh.setOwnWork();
                      setState(() {});
                    } else {
                      owh.removeOwnWork();
                    }
                    setState(() {});
                  }),
              const Text("This file is my own work"),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextFormField(
              controller: TextEditingController(text: collector.source),
              onChanged: (value) {
                collector.source = value;
              },
              enabled: !collector.ownWork,
              decoration: const InputDecoration(
                  icon: Icon(Icons.source),
                  labelText: 'Source',
                  hintText: 'Where this digital file came from')),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextFormField(
              controller: TextEditingController(text: collector.author),
              enabled: !collector.ownWork,
              onChanged: (value) {
                collector.author = value;
              },
              decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  labelText: 'Author',
                  hintText: 'Original author of the file')),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
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
                    color:
                        CustomColors().getDefaultIconColor(Theme.of(context)),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 18)),
                  Text(
                    "License: ",
                    textScaleFactor: 1.2,
                    style: TextStyle(
                        color: CustomColors()
                            .getDefaultIconColor(Theme.of(context))),
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
                // TODO help menu/guide or something for licenses
                items: data.licences.values
                    .map<DropdownMenuItem<String>>((String value) {
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
          padding: const EdgeInsets.all(8),
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
                      color:
                          CustomColors().getDefaultIconColor(Theme.of(context)),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 9)),
                    Text(
                      'Date:',
                      textScaleFactor: 1.2,
                      style: TextStyle(
                          color: CustomColors()
                              .getDefaultIconColor(Theme.of(context))),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                    Text(
                      DateFormat.yMd().format(
                          collector.date), // TODO local format instead of yMd
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
                        child: const Text('Select date'),
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
