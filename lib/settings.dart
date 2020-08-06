import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  Settings({Key key, this.title, this.userId, this.userTiffinData, this.getUserTiffinData})
      : super(key: key);
  final String title;
  final String userId;
  var userTiffinData;
  final VoidCallback getUserTiffinData;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool vegChecked = false;
  bool nonvegChecked = false;
  bool halfChecked = false;
  bool fullChecked = false;
  bool _isLoading = false;
  String _errorMessage;
  int vegHalf;
  int vegFull;
  int nonvegHalf;
  int nonvegFull;
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    vegChecked = widget.userTiffinData['Veg'];
    nonvegChecked = widget.userTiffinData['Non-Veg'];
    halfChecked = widget.userTiffinData['Half'];
    fullChecked = widget.userTiffinData['Full'];
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
        await _updateUserData();
        widget.getUserTiffinData();
        setState(() {
          _isLoading = false;
        });
        _showDialog('Success', 'Your Data has been updated successfully');
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

  Future<void> _updateUserData() async {
    await Firestore.instance
        .collection('users')
        .document(widget.userId)
        .updateData({
      'Veg': vegChecked,
      'Non-Veg': nonvegChecked,
      'Half': halfChecked,
      'Full': fullChecked,
      'Amount': {
        'Veg': {'Half': vegHalf, 'Full': vegFull},
        'Non-Veg': {'Half': nonvegHalf, 'Full': nonvegFull}
      }
    });
  }

  _showDialog(title, text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              title,
              style: TextStyle(color: Colors.black),
            ),
            content: Text(
              text,
              style: TextStyle(color: Colors.black),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
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
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
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
                    '3. Price of Tiffin',
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
                                      initialValue: widget
                                          .userTiffinData['Amount']['Veg']
                                              ['Half']
                                          .toString(),
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
                                      initialValue: widget
                                          .userTiffinData['Amount']['Veg']
                                              ['Full']
                                          .toString(),
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
                                      initialValue: widget
                                          .userTiffinData['Amount']['Non-Veg']
                                              ['Half']
                                          .toString(),
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
                                      initialValue: widget
                                          .userTiffinData['Amount']['Non-Veg']
                                              ['Full']
                                          .toString(),
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
                                color: Colors.teal.shade500,
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
        ));
  }
}
