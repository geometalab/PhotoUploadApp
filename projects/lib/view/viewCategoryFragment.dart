import 'package:button_navigation_bar/button_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projects/controller/imageDataExtractor.dart';
import 'package:projects/controller/imageService.dart';
import 'package:projects/controller/loginHandler.dart';
import 'package:projects/controller/settingsManager.dart';
import 'package:projects/model/informationCollector.dart';
import 'package:projects/view/commonsUploadFragment.dart';
import 'package:projects/pages/menuDrawer.dart';
import 'package:projects/view/simpleUpload/simpleUploadPage.dart';
import 'package:provider/provider.dart';

// TODO? tabbed view? for more information (see todos below)
// TODO add a View in Web/App function (requires QTag probably)
// TODO display short description (and maybe more) through QTag -> Wikimedia

class ViewCategoryFragment extends StatefulWidget {
  final Marker marker;
  ViewCategoryFragment(this.marker, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ViewCategoryFragment(marker);
}

class _ViewCategoryFragment extends State<ViewCategoryFragment> {
  final Marker _marker;
  _ViewCategoryFragment(this._marker);
  InformationCollector collector = new InformationCollector();

  @override
  Widget build(BuildContext context) {
    var categoryTitle =
        _marker.key.toString().substring(3, _marker.key.toString().length - 3);
    List<Widget> cards = List.empty(growable: true);

    return new Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              future: ImageService().getCategoryImages(categoryTitle, 400,
                  10), // TODO? at the moment only 10 first pics get shown, maybe someting like "load more" at the end?
              builder: (BuildContext context,
                  AsyncSnapshot<List<ImageURL>> snapshot) {
                // TODO Loading Indicator for Images as they might take quite a long time to load
                if (snapshot.hasData) {
                  List<ImageURL> images = snapshot.data!;
                  cards.clear();
                  for (int i = 0; i < images.length; i++) {
                    cards.add(new Card(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              images[i].url,
                              fit: BoxFit.fitWidth,
                            ), // TODO Implement fullscreen viewer for Images (on image click)
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(images[i].name,
                                  style:
                                      TextStyle(fontStyle: FontStyle.italic)),
                            ),
                          ],
                        ),
                      ),
                    ));
                  }
                  cards.add(Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                  ));
                  return Expanded(
                      child: ListView(
                    padding: EdgeInsets.all(8),
                    children: cards,
                  ));
                } else {
                  return CircularProgressIndicator();
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: FutureBuilder(
        future: _floatingActionButton(categoryTitle, context),
        builder: (BuildContext context, AsyncSnapshot<Widget?> snapshot) {
          if(snapshot.hasData && snapshot.data != null) {
            return snapshot.data!;
          } else {
            return SizedBox.shrink(); // Because FutureBuilder can't return null even though floatingActionButton is nullable :)
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<Widget?> _floatingActionButton(String prefillCategory, BuildContext context) async {
    // If user is not logged in, no FAB is displayed
    if(!await LoginHandler().isLoggedIn()) {
      return null;
    }
    if (SettingsManager().isSimpleMode()) {
      final ImagePicker _picker = ImagePicker();
      return ButtonNavigationBar(
          borderRadius: BorderRadius.circular(30),
          children: [
            ButtonNavigationItem.expandable(
                collapseButton: ButtonNavigationItem(
                    color: Theme.of(context).colorScheme.secondary,
                    icon: Icon(Icons.close),
                    height: 56,
                    width: 80,
                    onPressed: () {}),
                height: 56,
                width: 250,
                verticalOffset: 64,
                expandableSpacing: 64,
                icon: Icon(Icons.add),
                label: "Upload to this Category",
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      collector.image =
                          await _picker.pickImage(source: ImageSource.camera);
                      _openSimpleUploadPage(prefillCategory);
                    },
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.photo_camera),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4)),
                            Text("Take a picture"),
                          ],
                        )),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      collector.image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      _openSimpleUploadPage(prefillCategory);
                    },
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.folder),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4)),
                            Text("Select from files"),
                          ],
                        )),
                  ),
                ])
          ]);
    } else {
      return FloatingActionButton.extended(
        onPressed: () {
          collector.preFillContent = prefillCategory;
          Navigator.pop(context);
          Provider.of<ViewSwitcher>(context, listen: false).viewIndex = 2;
        },
        label: Text("Upload to this Category"),
        icon: Icon(Icons.add),
      );
    }
  }

  _openSimpleUploadPage(String categoryName) async {
    if (collector.image != null) {
      collector.preFillContent = categoryName;
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => SimpleUploadPage(),
        ),
      );
    }
  }
}
