import 'package:flutter/material.dart';
import 'package:progress_tab_bar/progress_tab_bar.dart';
import 'package:projects/controller/wiki/loginHandler.dart';
import 'package:projects/view/singlePage/notLoggedIn.dart';
import 'package:projects/view/uploadFlow/descriptionFragment.dart';
import 'package:projects/view/uploadFlow/informationFragment.dart';
import 'package:projects/view/uploadFlow/reviewFragment.dart';
import 'package:projects/view/uploadFlow/selecItems.dart';
import 'package:projects/view/uploadFlow/selectImage.dart';

class CommonsUploadFragment extends StatefulWidget {
  @override
  _CommonsUploadFragmentState createState() => _CommonsUploadFragmentState();
}

class _CommonsUploadFragmentState extends State<CommonsUploadFragment> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    // TODO noticeable frame drop when switching tabs  (maybe my phone is just shit)
    return new Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        resizeToAvoidBottomInset: false,
        body: FutureBuilder(
          future: LoginHandler().isLoggedIn(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData && snapshot.data == false) {
              return NotLoggedIn();
            } else {
              return _body();
            }
          },
        ));
  }

  Widget _body() {
    return Column(
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        ProgressTabBar(
          selectedTab: selectedTab,
          children: [
            ProgressTab(
                onPressed: () {
                  setState(() {
                    selectedTab = 0;
                  });
                },
                label: "Select File"),
            /*
            ProgressTab( // TODO implement depictions
            onPressed: () {
                  setState(() {
                    selectedTab = 1;
                  });
                },
                label: "Depicts"),
             */
            ProgressTab(
                onPressed: () {
                  setState(() {
                    selectedTab = 1;
                  });
                },
                label: "Categories"),
            ProgressTab(
                onPressed: () {
                  setState(() {
                    selectedTab = 2;
                  });
                },
                label: "Describe"),
            ProgressTab(
                onPressed: () {
                  setState(() {
                    selectedTab = 3;
                  });
                },
                label: "Add information"),
            ProgressTab(
                onPressed: () {
                  setState(() {
                    selectedTab = 4;
                  });
                },
                label: "Review"),
          ],
        ),
        Divider(),
        Expanded(
          child: _content(selectedTab),
        ),
      ],
    );
  }

  Widget _content(int tab) {
    switch (tab) {
      case 0:
        return SelectImageFragment();
      // case 1:
      //   return StatefulSelectItemFragment(1);
      case 1:
        return SelectItemFragment(0);
      case 2:
        return DescriptionFragment();
      case 3:
        return InformationFragment();
      case 4:
        return ReviewFragment();
      default:
        throw Exception("Invalid tab index");
    }
  }
}
