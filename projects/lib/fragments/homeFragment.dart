import 'package:flutter/material.dart';
import 'package:projects/style/textStyles.dart' as customStyles;

final titleFont = new TextStyle(height: 30);

class HomeFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(7),
              child: Row(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(2),
                      children: [
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: EdgeInsets.fromLTRB(02, 2, 0, 12),
                                    child: Text(
                                      "Sample Article",
                                      style: customStyles.articleTitle,
                                    )),
                                Image.network(
                                  "https://designshack.net/wp-content/uploads/placeholder-image.png",
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    "Description text. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                                    style: customStyles.articleDescription,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(2),
                      children: [
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: EdgeInsets.fromLTRB(02, 2, 0, 12),
                                    child: Text(
                                      "Sample Article",
                                      style: customStyles.articleTitle,
                                    )),
                                Image.network(
                                  "https://designshack.net/wp-content/uploads/placeholder-image.png",
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    "Description text. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                                    style: customStyles.articleDescription,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ),
                ],
              ),
            )
          ),
        ],
      )
    );
  }
}
