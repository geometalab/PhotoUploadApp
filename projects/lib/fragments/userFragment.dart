import 'package:flutter/material.dart';
import 'package:projects/api/deepLinkListener.dart';
import 'package:projects/api/loginHandler.dart';
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
                return Center(child: CircularProgressIndicator());
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
        ExpansionTile(
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
          children: expandedInfo(userdata),
          expandedAlignment: Alignment.bottomLeft,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
        ),
        OutlinedButton(
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

  List<Widget> expandedInfo(Userdata userdata) {
    List<Widget> list = new List.empty(growable: true);
    list.add(infoField(userdata.username, "username"));
    list.add(infoField(userdata.email, "email"));
    list.add(infoField(userdata.editCount.toString(), "number of edits"));
    return list;
  }

  Widget infoField(String initialValue, String label) {
    return TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
            label: Text(label),
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero),
        enabled: false);
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
