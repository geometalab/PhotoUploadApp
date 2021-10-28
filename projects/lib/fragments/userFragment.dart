import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projects/api/deepLinkListener.dart';
import 'package:projects/api/loginHandler.dart';
import 'package:projects/style/keyValueField.dart';
import 'package:projects/style/textStyles.dart';

class UserFragment extends StatefulWidget {
  @override
  _UserFragmentState createState() => _UserFragmentState();
}

class _UserFragmentState extends State<UserFragment> {
  LoginHandler loginHandler = new LoginHandler();
  bool expanded = false;
  Userdata? userdata;
  late DeepLinkListener deepLinkListener;

  _UserFragmentState() {
    // TODO access token is retrieved twice, which should not happen
    deepLinkListener = new DeepLinkListener();
    deepLinkListener.addListener(() {
      // On return to app from app, refresh widget
      pullRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement account management (user can change settings)
    return Container(
        child: FutureBuilder(
            future: loginHandler.getUserInformationFromFile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator.adaptive());
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
            }));
  }

  Future<void> pullRefresh() async {
    await LoginHandler().checkCredentials();
    setState(() {});
  }

  Widget loggedIn(Userdata userdata) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(10),
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
            subtitle: Text("View Profile 〉", style: objectDescription),
            leading: CircleAvatar(
              child: Icon(
                Icons.person_outline_rounded,
                color: Color.fromRGBO(229, 229, 229, 1),
              ),
              backgroundColor: Theme.of(context).disabledColor,
            ),
            children: expandedInfo(userdata, 0),
            expandedAlignment: Alignment.bottomLeft,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            childrenPadding: EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        TextButton(
            onPressed: () {
              setState(() {
                loginHandler.openMediaAccount(userdata.username);
              });
            },
            child: Text("My uploads")),
        OutlinedButton(
            onPressed: () {
              setState(() {
                loginHandler.logOut();
              });
            },
            child: Text("Log out")),
      ],
    );
  }

  List<Widget> expandedInfo(Userdata userdata, double spaceBetween) {
    List<Widget> list = new List.empty(growable: true);
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
    list.add(Padding(padding: EdgeInsets.symmetric(vertical: 4)));
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
        visualDensity: VisualDensity(vertical: 0),
      ));
    }
    return list;
  }

  Widget loggedOut() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 104),
            ),
            Icon(
              Icons.person_off_outlined,
              size: 80,
              color: Theme.of(context).disabledColor,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
            ),
            Text(
              "Not signed into Wikimedia",
              style: TextStyle(fontSize: 20),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
            ),
            SizedBox(
              width: 160,
              height: 40,
              child: TextButton(
                onPressed: () {
                  loginHandler.openWebLogin();
                },
                child: new Text("Log in"),
              ),
            ),
            SizedBox(
              width: 160,
              height: 40,
              child: TextButton(
                onPressed: () {
                  loginHandler.openWebSignUp();
                },
                child: new Text("Create account"),
              ),
            ),
          ],
        )
      ],
    );
  }
}
