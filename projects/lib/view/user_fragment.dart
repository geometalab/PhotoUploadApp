import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projects/controller/eventHandler/deeplink_listener.dart';
import 'package:projects/controller/wiki/login_handler.dart';
import 'package:projects/page_container.dart';
import 'package:projects/style/key_value_field.dart';
import 'package:projects/style/text_styles.dart';
import 'package:projects/style/user_avatar.dart';
import 'package:provider/provider.dart';

import '../style/key_value_field.dart';

class UserFragment extends StatefulWidget {
  const UserFragment({Key? key}) : super(key: key);

  @override
  _UserFragmentState createState() => _UserFragmentState();
}

class _UserFragmentState extends State<UserFragment> {
  LoginHandler loginHandler = LoginHandler();
  bool expanded = false;
  Userdata? userdata;
  late DeepLinkListener deepLinkListener;

  _UserFragmentState() {
    deepLinkListener = DeepLinkListener();
    deepLinkListener.addListener(() async {
      // On return to app from app, refresh widget
      await pullRefresh();
      Provider.of<ViewSwitcher>(context, listen: false).viewIndex = 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement account management (user can change settings)
    return FutureBuilder(
        future: loginHandler.getUserInformationFromFile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else {
            Userdata? data = snapshot.data as Userdata?;
            if (data == null) {
              return RefreshIndicator(
                  child: loggedOut(), onRefresh: pullRefresh);
            } else {
              return RefreshIndicator(
                  child: loggedIn(data), onRefresh: pullRefresh);
            }
          }
        });
  }

  Future<void> pullRefresh() async {
    await LoginHandler().checkCredentials();
    Provider.of<ViewSwitcher>(context, listen: false).viewIndex = 5;
    setState(() {});
  }

  Widget loggedIn(Userdata userdata) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      children: <Widget>[
        Theme(
          data: Theme.of(context).copyWith(
              dividerColor: Colors
                  .transparent), // Make the borders of ExpansionTile invisible
          child: ExpansionTile(
            title: Text(
              userdata.username,
              style: headerText,
            ),
            subtitle: const Text("View Details 〉", style: objectDescription),
            leading: const UserAvatar(Icons.person_outline_rounded),
            children: expandedInfo(userdata, 0),
            expandedAlignment: Alignment.bottomLeft,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
            initiallyExpanded: true,
          ),
        ),
        TextButton(
            onPressed: () {
              setState(() {
                loginHandler.openMediaAccount(userdata.username);
              });
            },
            child: const Text("My uploads")),
        OutlinedButton(
            onPressed: () {
              loginHandler.logOut();
              pullRefresh();
            },
            child: const Text("Log out")),
      ],
    );
  }

  List<Widget> expandedInfo(Userdata userdata, double spaceBetween) {
    List<Widget> list = List.empty(growable: true);
    list.add(ValueLabelField(userdata.username, "username"));
    list.add(ValueLabelField(userdata.email, "email"));
    list.add(ValueLabelField(userdata.editCount.toString(), "number of edits"));
    if (userdata.realName != "") {
      list.add(ValueLabelField(userdata.realName, "real name"));
    }
    list.add(expansionInfoWidget("rights", userdata.rights));
    list.add(expansionInfoWidget("grants", userdata.grants));
    list.add(expansionInfoWidget("groups", userdata.groups));
    list.add(ValueLabelField(DateFormat().format(userdata.lastCheck),
        "last refresh")); // TODO Is there an easy way to localize date time format?
    list.add(const Padding(padding: EdgeInsets.symmetric(vertical: 4)));
    return addPadding(list, spaceBetween);
  }

  List<Widget> addPadding(List<Widget> widgets, double padding) {
    List<Widget> newList = List.empty(growable: true);
    for (int i = 0; i < widgets.length; i++) {
      newList.add(widgets[i]);
      if (i < widgets.length - 1) {
        newList
            .add(Padding(padding: EdgeInsets.symmetric(vertical: padding / 2)));
      }
    }
    return newList;
  }

  Widget expansionInfoWidget(String title, List userdataList) {
    return ExpansionTile(
      title: Text(
        title,
        style: objectDescription,
      ),
      children: listTileGenerator(userdataList),
      tilePadding: EdgeInsets.zero,
    );
  }

  List<ListTile> listTileGenerator(List userdataList) {
    List<ListTile> list = List.empty(growable: true);
    for (String string in userdataList) {
      list.add(ListTile(
        title: Text(string),
        dense: true,
        visualDensity: const VisualDensity(vertical: 0),
      ));
    }
    return list;
  }

  Widget loggedOut() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 80,
                color: Theme.of(context).disabledColor,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
              ),
              const Text(
                "Not logged in",
                style: TextStyle(fontSize: 20),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
              ),
              SizedBox(
                width: 160,
                height: 40,
                child: TextButton(
                  onPressed: () {
                    loginHandler.openWebLogin();
                  },
                  child: const Text("Log in"),
                ),
              ),
              SizedBox(
                width: 160,
                height: 40,
                child: TextButton(
                  onPressed: () {
                    loginHandler.openWebSignUp();
                  },
                  child: const Text("Create account"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
