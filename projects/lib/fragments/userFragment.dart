import 'package:flutter/material.dart';
import 'package:projects/api/loginHandler.dart';

class UserFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement sign out and account management
    LoginHandler loginHandler = new LoginHandler();
    return new Center(
      child: FutureBuilder(
        future: loginHandler.getUsername(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }else{
            String username = snapshot.data.toString();
            if(username == "0"){
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(8),
                    child: Text("Not signed to Wikimedia")
                  ),
                  Padding(padding: EdgeInsets.all(8),
                      child: SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              loginHandler.openWebLogin(); // TODO Add correct url for wiki login
                            }, child: new Text("Log in"),
                          )
                      )
                  )
                ],
              );
            }else{
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(8),
                      child: Text("Signed in as " + username)
                  ),
                ],
              );
            }
          }
        }
      )
    );
  }
}