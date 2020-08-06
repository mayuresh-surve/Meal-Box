import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meal_box/authentication.dart';

class NewUserHomePage extends StatefulWidget {
  NewUserHomePage(
      {Key key,
      this.userId,
      this.auth,
      this.userAuth,
      this.logoutCallback,
      this.oldUserCallback})
      : super(key: key);
  final BaseAuth auth;
  final BaseAuth userAuth;
  final String userId;
  final VoidCallback logoutCallback;
  final VoidCallback oldUserCallback;

  @override
  _NewUserHomePageState createState() => _NewUserHomePageState();
}

class _NewUserHomePageState extends State<NewUserHomePage> {
  bool vegChecked = false;
  bool nonvegChecked = false;
  bool halfChecked = false;
  bool fullChecked = false;
  bool _isLoading = false;
  final _formKey = new GlobalKey<FormState>();

  String _errorMessage;
  int vegHalf;
  int vegFull;
  int nonvegHalf;
  int nonvegFull;

  @override
  void initState() {
    super.initState();
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (validateAndSave()) {
      try {
        await _createUser();
        widget.oldUserCallback();
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          _formKey.currentState.reset();
        });
      }
    }
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _createUser() async {
    await Firestore.instance
        .collection('users')
        .document(widget.userId)
        .setData({
      'Veg':vegChecked,
      'Non-Veg': nonvegChecked,
      'Half': halfChecked,
      'Full': fullChecked,
      'Amount':{
        'Veg':{
          'Half': vegHalf,
          'Full': vegFull
        },
        'Non-Veg': {
          'Half': nonvegHalf,
          'Full': nonvegFull
        }
      }
    }, merge: true);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Box', style: TextStyle(color: Colors.white),),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 16.0, color: Colors.white)),
              onPressed: signOut)
        ],
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Welcome',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Please add your custom Tiffin data.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                child: Text(
                  '1. Which type of meal do you order?',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  '    Please select all that apply',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: vegChecked,
                            onChanged: (value) {
                              if (vegChecked == false) {
                                setState(() {
                                  vegChecked = true;
                                });
                              } else if (vegChecked == true) {
                                setState(() {
                                  vegChecked = false;
                                });
                              }
                            },
                          ),
                          Text('Veg'),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: nonvegChecked,
                            onChanged: (value) {
                              if (nonvegChecked == false) {
                                setState(() {
                                  nonvegChecked = true;
                                });
                              } else if (nonvegChecked == true) {
                                setState(() {
                                  nonvegChecked = false;
                                });
                              }
                            },
                          ),
                          Text('Non-Veg'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                child: Text(
                  '2. What quantity of meal do you order?',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  '    Please select all that apply',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: halfChecked,
                            onChanged: (value) {
                              if (halfChecked == false) {
                                setState(() {
                                  halfChecked = true;
                                });
                              } else if (halfChecked == true) {
                                setState(() {
                                  halfChecked = false;
                                });
                              }
                            },
                          ),
                          Text('Half'),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: fullChecked,
                            onChanged: (value) {
                              if (fullChecked == false) {
                                setState(() {
                                  fullChecked = true;
                                });
                              } else if (fullChecked == true) {
                                setState(() {
                                  fullChecked = false;
                                });
                              }
                            },
                          ),
                          Text('Full'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                child: Text(
                  '3. Price of Tiffin\'s',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Form(
                key: _formKey,
                child: new Column(
                  children: <Widget>[
                    (vegChecked && halfChecked)
                        ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          Text('Price of Veg-Half Tiffin - '),
                          Expanded(
                            child: TextFormField(
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              autofocus: false,
                              decoration: new InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(10))),
                              validator: (value) => value.isEmpty
                                  ? 'This field can\'t be empty'
                                  : null,
                              onSaved: (value) =>
                              vegHalf = int.parse(value),
                            ),
                          ),
                        ],
                      ),
                    )
                        : Container(
                      width: 0,
                      height: 0,
                    ),
                    (vegChecked && fullChecked)
                        ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          Text('Price of Veg-Full Tiffin - '),
                          Expanded(
                            child: TextFormField(
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              autofocus: false,
                              decoration: new InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(10))),
                              validator: (value) => value.isEmpty
                                  ? 'This field can\'t be empty'
                                  : null,
                              onSaved: (value) =>
                              vegFull = int.parse(value),
                            ),
                          ),
                        ],
                      ),
                    )
                        : Container(
                      width: 0,
                      height: 0,
                    ),
                    (nonvegChecked && halfChecked)
                        ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          Text('Price of Non-Veg-Half Tiffin - '),
                          Expanded(
                            child: TextFormField(
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              autofocus: false,
                              decoration: new InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(10))),
                              validator: (value) => value.isEmpty
                                  ? 'This field can\'t be empty'
                                  : null,
                              onSaved: (value) =>
                              nonvegHalf = int.parse(value),
                            ),
                          ),
                        ],
                      ),
                    )
                        : Container(
                      width: 0,
                      height: 0,
                    ),
                    (nonvegChecked && fullChecked)
                        ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          Text('Price of Non-Veg-Full Tiffin - '),
                          Expanded(
                            child: TextFormField(
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              autofocus: false,
                              decoration: new InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(10))),
                              validator: (value) => value.isEmpty
                                  ? 'This field can\'t be empty'
                                  : null,
                              onSaved: (value) =>
                              nonvegFull = int.parse(value),
                            ),
                          ),
                        ],
                      ),
                    )
                        : Container(
                      width: 0,
                      height: 0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                              color: Color(0xFF4FCB58),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: new Text(
                                'Submit',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20.0),
                              ),
                              onPressed: validateAndSubmit),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _showCircularProgress(),
        ],
      )
    );
  }
}
