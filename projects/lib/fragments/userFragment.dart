import 'package:flutter/material.dart';
import 'package:projects/api/lifeCycleEventHandler.dart';
import 'package:projects/api/loginHandler.dart';

class UserFragment extends StatefulWidget{
  @override
  _UserFragmentState createState() => _UserFragmentState();
}

class _UserFragmentState extends State<UserFragment> {
  LoginHandler loginHandler = new LoginHandler();
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
                  return RefreshIndicator(child: loggedOut(), onRefresh: _pullRefresh);
                } else {
                  return RefreshIndicator(child: loggedIn(data), onRefresh: _pullRefresh);
                }
              }
            }));
  }

  Future<void> _pullRefresh() async {
    Future.delayed(Duration(seconds: 2));
  }

  Widget loggedIn(Userdata userdata) {
    return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Text("Username: ${userdata.username}"),
          Text("Access Token: ${userdata.accessToken.substring(0, 5)}..."),
          Text("Refresh Token: ${userdata.refreshToken.substring(0, 5)}..."),
          Text("Email: ${userdata.email}"),
          Text("Edit Count: ${userdata.editCount}"),
          OutlinedButton(
              onPressed: () {
                setState(() {
                  loginHandler.logOut();
                });
              },
              child: Text("Log out")
          )
        ],
    );
  }

  Widget loggedOut() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        Padding(
            padding: EdgeInsets.all(8), child: Text("Not signed to Wikimedia")),
        Padding(
            padding: EdgeInsets.all(8),
            child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    loginHandler.openWebLogin();
                  },
                  child: new Text("Log in"),
                )))
      ],
    );
  }
}
