import 'package:flutter/material.dart';
import 'package:progress_tab_bar/progress_tab_bar.dart';
import 'package:projects/controller/wiki/login_handler.dart';
import 'package:projects/view/singlePage/not_logged_in_view.dart';
import 'package:projects/view/uploadFlow/description_fragment.dart';
import 'package:projects/view/uploadFlow/information_fragment.dart';
import 'package:projects/view/uploadFlow/review_fragment.dart';
import 'package:projects/view/uploadFlow/select_items_fragment.dart';
import 'package:projects/view/uploadFlow/select_image_fragment.dart';

class CommonsUploadFragment extends StatefulWidget {
  const CommonsUploadFragment({Key? key}) : super(key: key);

  @override
  _CommonsUploadFragmentState createState() => _CommonsUploadFragmentState();
}

class _CommonsUploadFragmentState extends State<CommonsUploadFragment> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    // TODO noticeable frame drop when switching tabs  (maybe my phone is just shit)
    return Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        resizeToAvoidBottomInset: false,
        body: FutureBuilder(
          future: LoginHandler().isLoggedIn(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData && snapshot.data == false) {
              return const NotLoggedIn();
            } else {
              return _body();
            }
          },
        ));
  }

  Widget _body() {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
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
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Divider(
            height: 1,
            thickness: 1,
          ),
        ),
        Expanded(
          child: _content(selectedTab),
        ),
      ],
    );
  }

  Widget _content(int tab) {
    switch (tab) {
      case 0:
        return const SelectImageFragment();
      // case 1:
      //   return StatefulSelectItemFragment(1);
      case 1:
        return const SelectItemFragment(0);
      case 2:
        return const DescriptionFragment();
      case 3:
        return const InformationFragment();
      case 4:
        return const ReviewFragment();
      default:
        throw Exception("Invalid tab index");
    }
  }
}
