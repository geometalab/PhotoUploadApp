import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projects/main.dart';

class SelectImageFragment extends StatelessWidget {
  //TODO Support Video Files
  //TODO Support Audio Files
  //TODO Support multiple Files

  final ImagePicker _picker = ImagePicker();

  // Upload Info
  late final XFile? image;

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(2),
              child: OutlinedButton(
                onPressed: () async {
                  image = await _picker.pickImage(source: ImageSource.gallery);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SelectCategoryFragment()),
                  );
                },
                child: Text("Select Image from Files"),
              ),
            ),
            Padding(
                padding: EdgeInsets.all(2),
                child: OutlinedButton(
                  onPressed: () async {
                    image = await _picker.pickImage(source: ImageSource.camera);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SelectCategoryFragment()),
                    );
                  },
                  child: Text("Capture a Photo"),
                )
            )
          ],
      )
    );
  }
}

class SelectCategoryFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Column(children: <Widget>[
          AppBar(
            title: Text('Add Categories'),
            actions: [
              IconButton(onPressed: () { Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StatefulInformationFragment()),
                );
              }
              , icon: Icon(Icons.done), color: Colors.white),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
              )
            ],
          ),
          Padding(padding: EdgeInsets.all(2)),
          Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(
                    labelText: 'Category', border: OutlineInputBorder()),
              )
          )

          //TODO: Implement Typeahead field
          /*
                  TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                        autofocus: true,
                        style: DefaultTextStyle.of(context).style.copyWith(
                            fontStyle: FontStyle.italic
                        ),
                        decoration: InputDecoration(
                            border: OutlineInputBorder()
                        )
                    ),
                    suggestionsCallback: (pattern) async {
                      return await backendService.getSuggestions(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        leading: Icon(Icons.shopping_cart),
                        title: Text(suggestion['name']),
                        subtitle: Text('\$${suggestion['price']}'),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      //TODO Implement onSuggestionSelected
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProductPage(product: suggestion)
                      ));
                    },
                  )
                  */
        ]
      )
    );
  }
}

class StatefulInformationFragment extends StatefulWidget {
  @override
  _InformationFragment createState() => _InformationFragment();
}

class _InformationFragment extends State<StatefulInformationFragment> {

  DateTime selectedDate = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1, 1),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Find field info here: https://commons.wikimedia.org/wiki/Template:Information
  // TODO implement source
  // TODO implement permission
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: ListView(
            children: <Widget>[
              AppBar(
                title: Text('Enter File Details'),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.file_copy_outlined),
                      labelText: 'File Name',
                      hintText: 'Choose a descriptive name',
                    )
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child:
                TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.text_fields_outlined),
                      labelText: 'Description',
                      hintText: 'Write a meaningful description',
                      contentPadding: const EdgeInsets.only(bottom: 100),
                    )
                ),
              ),
              Padding(padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Author',
                    hintText: 'Original author of the file'
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey,),
                          Padding(padding: EdgeInsets.only(left: 18)),
                          Text('Date:', textScaleFactor: 1.2, style: TextStyle(color: Colors.grey[700]),),
                        ],),
                    ),
                    Container(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("${selectedDate.toLocal()}".split(' ')[0], textScaleFactor: 1.2,),
                            Padding(padding: EdgeInsets.only(left: 30)),
                            OutlinedButton(
                              onPressed: () => _selectDate(context),
                              child: Text('Select date'),
                            )
                          ]),
                    )
                  ],
                ),
              ),


              Padding(padding: EdgeInsets.all(10),
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                    //TODO Implement with API
                    },
                    child: Text('Submit to Commons'),
                  )
                )
              ),
            ]
        )
    );
  }

}



