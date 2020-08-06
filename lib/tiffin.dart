import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddTiffin extends StatefulWidget {
  AddTiffin({Key key, this.userId, this.userTiffinData}) : super(key: key);
  final String userId;
  var userTiffinData;
  @override
  _AddTiffinState createState() => _AddTiffinState();
}

class _AddTiffinState extends State<AddTiffin> {
  var screenWidth;
  var screenHeight;
  var _selectedDate;
  String selectedType = 'null';
  String selectedMeal = 'null';
  double tiffinCount = 1.0;
  DateTime addDate;
  double yearRank = 0.0;
  int amount;
  var exists;
  var value;
  bool paid;
  bool _isLoading = false;
  var monthMap = {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 910,
    'Nov': 911,
    'Dec': 912
  };
  final dfRef = Firestore.instance;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateFormat.yMMMd().format(DateTime.now());
    addDate = DateTime.now();
  }

  setSelectedType(String val) {
    setState(() {
      selectedType = val;
    });
  }

  setSelectedMeal(String val) {
    setState(() {
      selectedMeal = val;
    });
  }

  checkExist(String date) async {
    bool exists = false;
    await dfRef
        .collection('users')
        .document(widget.userId)
        .collection("meal_box")
        .document(date.substring(0, 3) + date.substring(date.length - 5))
        .get()
        .then((doc) {
      if (doc.exists) {
        exists = true;
      } else
        exists = false;
    });
    return exists;
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

  _checkConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      _showDialog('No Intenet', 'Please check your internet connection!');

      setState(() {
        selectedMeal = 'null';
        selectedType = 'null';
      });
    } else {
      setState(() {
        _isLoading = true;
      });
      exists = await checkExist(_selectedDate);
      if (exists == true) {
        amount = (widget.userTiffinData['Amount'][selectedMeal][selectedType].toInt() *
            tiffinCount.toInt());
        final document = await dfRef
            .collection('users')
            .document(widget.userId)
            .collection('meal_box')
            .document(_selectedDate.substring(0, 3) +
                _selectedDate.substring(_selectedDate.length - 5))
            .get();
        final value = document.data;
        amount = value['Amount'] + amount;
        paid = value['Paid'];
      } else {
        amount = (widget.userTiffinData['Amount'][selectedMeal][selectedType].toInt() *
            tiffinCount.toInt());
        paid = false;
      }

      yearRank = double.parse(
          _selectedDate.substring(_selectedDate.length - 5) +
              '.' +
              monthMap[_selectedDate.substring(0, 3)].toString());
      dfRef
          .collection('users')
          .document(widget.userId)
          .collection("meal_box")
          .document(_selectedDate.substring(0, 3) +
              _selectedDate.substring(_selectedDate.length - 5))
          .setData({
        'Dates': FieldValue.arrayUnion([_selectedDate]),
        'Rank': yearRank,
        'Amount': amount,
        'Paid': paid,
      }, merge: true);
      dfRef
          .collection('users')
          .document(widget.userId)
          .collection("meal_box")
          .document(_selectedDate.substring(0, 3) +
              _selectedDate.substring(_selectedDate.length - 5))
          .collection("Dates")
          .add({
        'Date': addDate,
        'Type': selectedType,
        'Meal': selectedMeal,
        'Number': tiffinCount,
        'Amount': (widget.userTiffinData['Amount'][selectedMeal][selectedType].toInt() *
            tiffinCount.toInt())
      }).then((value) {
        _showDialog('Success!', 'Tiffin has been added successfully');
        setState(() {
          selectedMeal = 'null';
          selectedType = 'null';
          amount = 0;
          tiffinCount = 1.0;
          _isLoading = false;
        });
      });
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showRoundedDatePicker(
        context: context,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101),
        theme: ThemeData(
          primaryColor: Color(0xFF093E60),
          accentColor: Colors.teal,
          dialogBackgroundColor: Colors.grey[200],
          textTheme: TextTheme(
              // ignore: deprecated_member_use
              body1: TextStyle(color: Colors.indigo[600]),
              caption: TextStyle(
                color: Colors.red,
              )),
          disabledColor: Colors.orange[800],
          accentTextTheme:
              // ignore: deprecated_member_use
              TextTheme(body2: TextStyle(color: Colors.deepPurple)),
        ));
    setState(() {
      _selectedDate = DateFormat.yMMMd().format(picked);
      addDate = picked;
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
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Tiffin", style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: <Widget>[
          _showCircularProgress(),
          ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            '$_selectedDate',
                            style: TextStyle(
                              fontSize: screenHeight * 0.023,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.025,
                          ),
                          RaisedButton(
                            onPressed: () => _selectDate(context),
                            child: Text(
                              'Select date',
                              style: TextStyle(color: Colors.white),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            color: Color(0xFF4FCB58),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: screenHeight * 0.02,
                    thickness: 1.0,
                  ),
                  Text(
                    'Meal Type',
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        widget.userTiffinData['Veg']
                            ? Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () => setSelectedMeal("Veg"),
                                    child: Container(
                                        height: screenHeight * 0.12,
                                        width: screenHeight * 0.12,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 3,
                                              color: selectedMeal == "Veg"
                                                  ? Color(0xFF1D889F)
                                                  : Colors.transparent,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0))),
                                        child: SvgPicture.asset(
                                            "assets/images/lunch.svg")),
                                  ),
                                  Text(
                                    'Veg',
                                    style: TextStyle(
                                      fontSize: screenHeight * 0.025,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                width: 0,
                                height: 0,
                              ),
                        widget.userTiffinData['Non-Veg']
                            ? Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () => setSelectedMeal("Non-Veg"),
                                    child: Container(
                                        height: screenHeight * 0.12,
                                        width: screenHeight * 0.12,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 3,
                                              color: selectedMeal == "Non-Veg"
                                                  ? Color(0xFF1D889F)
                                                  : Colors.transparent,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0))),
                                        child: SvgPicture.asset(
                                            "assets/images/dinner.svg")),
                                  ),
                                  Text(
                                    'Non-Veg',
                                    style: TextStyle(
                                      fontSize: screenHeight * 0.025,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                width: 0,
                                height: 0,
                              ),
                      ],
                    ),
                  ),
                  Divider(
                    height: screenHeight * 0.02,
                    thickness: 1.0,
                  ),
                  Text(
                    'Meal Quantity',
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        widget.userTiffinData['Half']
                            ? Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () => setSelectedType("Half"),
                                    child: Container(
                                        height: screenHeight * 0.12,
                                        width: screenHeight * 0.12,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 3,
                                              color: selectedType == "Half"
                                                  ? Color(0xFF1D889F)
                                                  : Colors.transparent,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0))),
                                        child: SvgPicture.asset(
                                            "assets/images/half_meal.svg")),
                                  ),
                                  Text(
                                    'Half',
                                    style: TextStyle(
                                      fontSize: screenHeight * 0.025,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                width: 0,
                                height: 0,
                              ),
                        widget.userTiffinData['Full']
                            ? Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () => setSelectedType("Full"),
                                    child: Container(
                                        height: screenHeight * 0.12,
                                        width: screenHeight * 0.12,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 3,
                                              color: selectedType == "Full"
                                                  ? Color(0xFF1D889F)
                                                  : Colors.transparent,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0))),
                                        child: SvgPicture.asset(
                                            "assets/images/full_meal.svg")),
                                  ),
                                  Text(
                                    'Full',
                                    style: TextStyle(
                                      fontSize: screenHeight * 0.025,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                width: 0,
                                height: 0,
                              ),
                      ],
                    ),
                  ),
                  Divider(
                    height: screenHeight * 0.02,
                    thickness: 1.0,
                  ),
                  Text(
                    'Number of Tiffin',
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Slider(
                      value: tiffinCount,
                      min: 1.0,
                      max: 5.0,
                      divisions: 4,
                      label: '${tiffinCount.round()}',
                      onChanged: (double val) {
                        setState(() {
                          tiffinCount = val;
                        });
                      },
                    ),
                  ),
                  Divider(
                    height: screenHeight * 0.02,
                  ),
                  RaisedButton(
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    onPressed: () {
                      if (selectedType != 'null' && selectedMeal != 'null') {
                        _checkConnectivity();
                      } else {
                        _showDialog('Error', 'Please select all the fields.');
                      }
                    },
                    color: Color(0xFF4FCB58),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
