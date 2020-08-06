import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meal_box/aboutUS.dart';
import 'package:meal_box/authentication.dart';
import 'package:meal_box/detailData.dart';
import 'package:meal_box/meal_box_icons.dart';
import 'package:meal_box/settings.dart';
import 'package:meal_box/tiffin.dart';

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

class OldUserHomePage extends StatefulWidget {
  OldUserHomePage(
      {Key key, this.title, this.userId, this.auth, this.logoutCallback})
      : super(key: key);
  final String title;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  _OldUserHomePageState createState() => _OldUserHomePageState();
}

class _OldUserHomePageState extends State<OldUserHomePage> {
  var screenWidth;
  var screenHeight;
  int x;
  var userTiffinData;
  final dfRef = Firestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    userTiffinData = _getUserTiffinData();
  }

  Widget _cardBuilder(BuildContext context, DocumentSnapshot documentSnapshot) {
    return GestureDetector(
      child: Card(
        margin: EdgeInsets.all(10.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        color: Colors.white,
        elevation: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(10.0)),
                  gradient: LinearGradient(colors: [
                    documentSnapshot['Paid']
                        ? Color(0xFF4FCB58)
                        : Color(0xFFE0332B),
                    Colors.white
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              height: screenHeight * 0.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    documentSnapshot.documentID,
                    style: TextStyle(fontSize: screenHeight * 0.04),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Total Amount: ₹',
                    style: TextStyle(fontSize: screenHeight * 0.02),
                  ),
                  Text(
                    documentSnapshot['Amount'].toString(),
                    style: TextStyle(fontSize: screenHeight * 0.02),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Bill status: ',
                    style: TextStyle(fontSize: screenHeight * 0.02),
                  ),
                  Text(
                    documentSnapshot['Paid'] ? 'Paid' : 'Unpaid',
                    style: TextStyle(
                        color: documentSnapshot['Paid']
                            ? Colors.green
                            : Colors.grey,
                        fontSize: screenHeight * 0.02),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          FadeRoute(
            page: DetailData(
              document: documentSnapshot,
              paid: documentSnapshot.data['Paid'],
              userID: widget.userId,
            ),
          ),
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

  _getUserTiffinData() async {
    await dfRef.collection('users').document(widget.userId).get().then((value) {
      setState(() {
        userTiffinData = value.data;
        _isLoading = false;
      });
    });
    return userTiffinData;
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20),
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/cover.jpg')),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () async {
                await _getUserTiffinData();
                Navigator.push(
                  context,
                  FadeRoute(
                    page: Settings(
                      title: 'Settings',
                      userId: widget.userId,
                      userTiffinData: userTiffinData,
                      getUserTiffinData: _getUserTiffinData,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(MealBox.info),
              title: Text('About us'),
              onTap: () async {
                Navigator.push(
                  context,
                  FadeRoute(
                    page: AboutUs(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: signOut,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Meal Box',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: <Widget>[
          StreamBuilder(
              stream: dfRef
                  .collection('users')
                  .document(widget.userId)
                  .collection('meal_box')
                  .orderBy('Rank')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemCount: snapshot.data.documents.length,
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        _cardBuilder(context, snapshot.data.documents[index]));
              }),
          _showCircularProgress(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          setState(() {
            _isLoading = true;
          });
          await _getUserTiffinData();
          Navigator.push(
            context,
            FadeRoute(
                page: AddTiffin(
              userId: widget.userId,
              userTiffinData: userTiffinData,
            )),
          );
        },
        tooltip: "Add New Tiffin",
      ),
    );
  }
}
