import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meal_box/authentication.dart';
import 'package:meal_box/newUserHomePage.dart';
import 'package:meal_box/oldUserHomePage.dart';

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}

enum VerifyState { NEW_USER_VERIFIED, NEW_USER_NOT_VERIFIED, OLD_USER }

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.userId, this.auth, this.logoutCallback})
      : super(key: key);
  final String title;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var screenWidth;
  var screenHeight;
  int x;
  final dfRef = Firestore.instance;
  bool _isEmailVerified = false;
  VerifyState verifyState;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      setState(() {
        verifyState = VerifyState.NEW_USER_NOT_VERIFIED;
      });
    } else if (_isEmailVerified) {
      oldUserVerified();
    }
  }

  void oldUserCallback(){
    setState(() {
      verifyState = VerifyState.OLD_USER;
    });
  }

  void oldUserVerified() {
    dfRef.collection('users').document(widget.userId).get().then((value) {
      if (value.exists) {
        setState(() {
          verifyState = VerifyState.OLD_USER;
        });
      } else {
        setState(() {
          verifyState = VerifyState.NEW_USER_VERIFIED;
        });
      }
    });
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }
  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (verifyState) {
      case VerifyState.NEW_USER_NOT_VERIFIED:
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: <Widget>[
              new FlatButton(
                  child: new Text('Logout',
                      style:
                          new TextStyle(fontSize: 16.0, color: Colors.white)),
                  onPressed: signOut)
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Please verify your Email to continue',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      child: Text(
                        'Resend Link',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Color(0xFF4FCB58),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onPressed: () {
                        _resentVerifyEmail();
                      },
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    RaisedButton(
                      child: Text(
                        'Done',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Color(0xFF4FCB58),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onPressed: () {
                        _checkEmailVerification();
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        );
        break;
      case VerifyState.NEW_USER_VERIFIED:
        return new NewUserHomePage(
          userId: widget.userId,
          auth: widget.auth,
          logoutCallback: widget.logoutCallback,
          oldUserCallback: oldUserCallback,
        );
        break;
      case VerifyState.OLD_USER:
        return new OldUserHomePage(
          title: 'Meal Box',
          userId: widget.userId,
          auth: widget.auth,
          logoutCallback: widget.logoutCallback,
        );
        break;
      default:
        return buildWaitingScreen();
    }
  }
}
