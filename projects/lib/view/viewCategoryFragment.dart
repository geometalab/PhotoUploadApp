import 'package:button_navigation_bar/button_navigation_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projects/controller/wiki/imageService.dart';
import 'package:projects/controller/wiki/loginHandler.dart';
import 'package:projects/controller/internal/settingsManager.dart';
import 'package:projects/model/informationCollector.dart';
import 'package:projects/pageContainer.dart';
import 'package:projects/style/heroPhotoViewRouteWrapper.dart';
import 'package:projects/view/simpleUpload/simpleUploadPage.dart';
import 'package:provider/provider.dart';

// TODO? tabbed view? for more information (see todos below)
// TODO add a View in Web/App function (requires QTag probably)
// TODO display short description (and maybe more) through QTag -> Wikimedia

class ViewCategoryFragment extends StatefulWidget {
  final Marker marker;
  const ViewCategoryFragment(this.marker, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ViewCategoryFragment(marker);
}

class _ViewCategoryFragment extends State<ViewCategoryFragment> {
  final Marker _marker;
  _ViewCategoryFragment(this._marker);
  InformationCollector collector = InformationCollector();
  int numberOfImages = 10;

  @override
  Widget build(BuildContext context) {
    var categoryTitle =
        _marker.key.toString().substring(3, _marker.key.toString().length - 3);
    List<Widget> cards = List.empty(growable: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              future: ImageService()
                  .getCategoryImages(categoryTitle, 400, numberOfImages),
              builder: (BuildContext context,
                  AsyncSnapshot<List<ImageURL>> snapshot) {
                if (snapshot.hasData) {
                  List<ImageURL> images = snapshot.data!;
                  cards.clear();
                  for (int i = 0; i < images.length; i++) {
                    if (i == images.length - 1 && i == numberOfImages - 1) {
                      cards.add(TextButton(
                        onPressed: () {
                          setState(() {
                            numberOfImages += 10;
                          });
                        },
                        child: const Text("Load more"),
                      ));
                    } else {
                      cards.add(Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                HeroPhotoViewRouteWrapper(
                                                    imageProvider:
                                                        CachedNetworkImageProvider(
                                                  images[i].url,
                                                ))));
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: images[i].url,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    fit: BoxFit.fitWidth,
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(images[i].name,
                                    style:
                                        const TextStyle(fontStyle: FontStyle.italic)),
                              ),
                            ],
                          ),
                        ),
                      ));
                    }
                  }
                  cards.add(const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                  ));
                  return Expanded(
                      child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: cards,
                  ));
                } else {
                  return const CircularProgressIndicator();
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: FutureBuilder(
        future: _floatingActionButton(categoryTitle, context),
        builder: (BuildContext context, AsyncSnapshot<Widget?> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return snapshot.data!;
          } else {
            return const SizedBox
                .shrink(); // Because FutureBuilder can't return null even though floatingActionButton is nullable :)
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<Widget?> _floatingActionButton(
      String prefillCategory, BuildContext context) async {
    // If user is not logged in, no FAB is displayed
    if (!await LoginHandler().isLoggedIn()) {
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
                    icon: const Icon(Icons.close),
                    height: 56,
                    width: 80,
                    onPressed: () {}),
                height: 56,
                width: 250,
                verticalOffset: 64,
                expandableSpacing: 64,
                icon: const Icon(Icons.add),
                label: "Upload to this Category",
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      XFile? image =
                          await _picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        collector.images =
                            List<XFile>.generate(1, (_) => image);
                      }
                      _openSimpleUploadPage(prefillCategory);
                    },
                    child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: const [
                            Icon(Icons.photo_camera),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4)),
                            Text("Take a picture"),
                          ],
                        )),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      XFile? image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        collector.images =
                            List<XFile>.generate(1, (_) => image);
                      }
                      _openSimpleUploadPage(prefillCategory);
                    },
                    child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: const [
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
        heroTag: "nonSimpleModeFAB",
        label: const Text("Upload to this Category"),
        icon: const Icon(Icons.add),
      );
    }
  }

  _openSimpleUploadPage(String categoryName) async {
    if (collector.images.isNotEmpty) {
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
