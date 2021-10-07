import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement account management

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
    LoginHandler().checkCredentials();
    setState(() {});
  }

  Widget loggedIn(Userdata userdata) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(10),
      children: <Widget>[
        ExpansionTile(
            title: Text(userdata.username,style: headerText,),
            subtitle: Text("View Profile 〉", style: objectDescription),
            leading: CircleAvatar(
              child: Icon(Icons.person_outline_rounded,color: Color.fromRGBO(229, 229, 229, 1),),
              backgroundColor: Theme.of(context).disabledColor,
            ),
            children: expandedInfo(userdata),
          expandedAlignment: Alignment.bottomLeft,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
        ),
        OutlinedButton(
            onPressed: () {
              setState(() {
                loginHandler.logOut();
              });
            },
            child: Text("Log out")),
        OutlinedButton(
            onPressed: () {
              setState(() {
                loginHandler.openMediaAccount(userdata.username);
              });
            },
            child: Text("Show my uploads"))
      ],
    );
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


  List<Widget> expandedInfo(Userdata userdata) {
    List<Widget> list = new List.empty(growable: true);
    final Alignment? expandedAlignment;
    list.add(Text("Username: ${userdata.username}",
        textAlign: TextAlign.left)
    );
    //list.add(Text("Access Token: ${userdata.accessToken.substring(0, 5)}..."));
    //list.add(Text("Refresh Token: ${userdata.refreshToken.substring(0, 5)}..."));
    list.add(Text("Email: ${userdata.email}",
        textAlign: TextAlign.left)
    );
    list.add(Text("Edit Count: ${userdata.editCount}",
        textAlign: TextAlign.left)
    );
    return list;
  }
}
