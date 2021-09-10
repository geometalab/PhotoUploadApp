import 'package:flutter/material.dart';

final titleFont = new TextStyle(height: 30);

class HomeFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new ListView(
          children: [
            Card(
              child: Padding(padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: EdgeInsets.all(10),
                      child: Text("Sample Article", style: TextStyle(),)
                    ),
                    Image.network("https://www.grouphealth.ca/wp-content/uploads/2018/05/placeholder-image-300x225.png"),
                    Padding(padding: EdgeInsets.all(10),
                      child: Text("Description text. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", style: TextStyle(),),
                    )
                  ],
                ),
              ),
            )
          ],
        )
    );
  }


}