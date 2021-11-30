import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:projects/controller/imageService.dart';
import 'package:projects/view/viewCategoryFragment.dart';

class CategoryPopup extends StatefulWidget {
  final Marker marker;
  CategoryPopup(this.marker, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CategoryPopupState(marker);
}

class _CategoryPopupState extends State<CategoryPopup> {
  final Marker _marker;
  _CategoryPopupState(this._marker);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewCategoryFragment(_marker)),
          );
        }),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 100,
              height: 70,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: FutureBuilder(
                    future: ImageService().getCategoryThumbnail(_marker.key
                        .toString()
                        .substring(3, _marker.key.toString().length - 3)),
                    builder:
                        (BuildContext context, AsyncSnapshot<Image> snapshot) {
                      Widget thumbnail;
                      if (snapshot.hasData) {
                        thumbnail = snapshot
                            .data!; // TODO Sometimes (maybe because of file type or res), the progress indicator disappears, but it still takes a few seconds for image to appear
                      } else if (snapshot.hasError) {
                        throw ("Could not display thumbnail");
                      } else {
                        thumbnail = Padding(
                          padding: EdgeInsets.zero,
                          child: Center(
                              child: CircularProgressIndicator.adaptive(
                            strokeWidth: 1.5,
                          )),
                        );
                      }
                      return thumbnail;
                    }),
              ),
            ),
            _cardDescription(context),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 15),
              child: Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        constraints: BoxConstraints(minWidth: 100, maxWidth: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _marker.key.toString().substring(
                  3,
                  _marker.key.toString().length -
                      3), // marker keys come with unnecessary chars at
              overflow: TextOverflow.fade,
              softWrap: false,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
            Text(
              'Position: N ${_marker.point.latitude.toStringAsFixed(3)}, E ${_marker.point.longitude.toStringAsFixed(3)}',
              style: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }
}
