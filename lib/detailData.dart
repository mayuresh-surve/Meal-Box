import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailData extends StatefulWidget {
  DetailData({Key key, this.document, this.paid, this.userID})
      : super(key: key);
  final DocumentSnapshot document;
  bool paid;
  final String userID;

  @override
  _DetailDataState createState() => _DetailDataState();
}

class _DetailDataState extends State<DetailData> {
  var screenWidth;
  var screenHeight;
  bool _isLoading = false;

  void initstate() {
    super.initState();
  }

  List<DataRow> _buildList(QuerySnapshot snapshot) {
    List<DataRow> newList =
        snapshot.documents.map((DocumentSnapshot documentSnapshot) {
      return new DataRow(cells: [
        DataCell(Text(
          DateFormat.yMMMd()
              .format(documentSnapshot['Date'].toDate())
              .substring(
                  0,
                  (DateFormat.yMMMd()
                          .format(documentSnapshot['Date'].toDate())
                          .length -
                      6)),
        )),
        DataCell(Text(
          documentSnapshot['Meal'],
        )),
        DataCell(Text(
          documentSnapshot['Type'],
        )),
        DataCell(Text(
          documentSnapshot['Number'].toInt().toString(),
        )),
        DataCell(Text(
          documentSnapshot['Amount'].toInt().toString(),
        )),
        DataCell(
          GestureDetector(
              child: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onTap: () {
                _showDeleteAlert('Notice', 'Are you sure you want to delete?',
                    documentSnapshot);
              }),
        ),
      ]);
    }).toList();

    return newList;
  }

  _showAlert(title, text) {
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
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('ok'),
                onPressed: () {
                  _paidChange();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
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
      },
    );
  }

  void _showDeleteAlert(title, text, DocumentSnapshot documentSnapshot) {
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
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('ok'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    _isLoading = true;
                  });
                  await Firestore.instance
                      .collection('users')
                      .document(widget.userID)
                      .collection('meal_box')
                      .document(widget.document.documentID)
                      .updateData({
                    'Amount': (widget.document['Amount'] -
                        documentSnapshot['Amount']),
                    'Dates': FieldValue.arrayRemove([
                      DateFormat.yMMMd()
                          .format(documentSnapshot['Date'].toDate())
                    ])
                  });
                  await Firestore.instance
                      .collection('users')
                      .document(widget.userID)
                      .collection('meal_box')
                      .document(widget.document.documentID)
                      .collection('Dates')
                      .document(documentSnapshot.documentID)
                      .delete();
                  await Firestore.instance
                      .collection('users')
                      .document(widget.userID)
                      .collection('meal_box')
                      .document(widget.document.documentID)
                      .get()
                      .then((value) async {
                    final int delMonth = value.data['Dates'].length;
                    if (delMonth == 0) {
                      await Firestore.instance
                          .collection('users')
                          .document(widget.userID)
                          .collection('meal_box')
                          .document(widget.document.documentID)
                          .delete();
                    }
                    _showDialog('Success!', 'Tiffin has been Deleted');
                    setState(() {
                      _isLoading = false;
                    });
                  });
                },
              ),
            ],
          );
        });
  }

  void _paidChange() async {
    await Firestore.instance
        .collection('users')
        .document(widget.userID)
        .collection('meal_box')
        .document(widget.document.documentID)
        .updateData({'Paid': !widget.paid});
    setState(() {
      widget.paid = !widget.paid;
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
        title: Text('Meal Box'),
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      widget.document.documentID,
                      style: TextStyle(fontSize: screenHeight * 0.05),
                    ),
                    SizedBox(
                      width: screenWidth * 0.25,
                    ),
                    RaisedButton(
                      child: Text(
                        widget.paid ? 'Paid' : 'Unpaid',
                        style: TextStyle(
                            color: widget.paid ? Colors.white : Colors.white),
                      ),
                      onPressed: () {
                        _showAlert('Notice', 'Are you sure?');
                      },
                      color:
                          widget.paid ? Color(0xFF4FCB58) : Color(0xFFE0332B),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    children: <Widget>[
                      LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                          child: Container(
                            alignment: Alignment.topLeft,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth: constraints.minWidth),
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: Firestore.instance
                                      .collection('users')
                                      .document(widget.userID)
                                      .collection('meal_box')
                                      .document(widget.document.documentID)
                                      .collection('Dates')
                                      .orderBy('Date')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData)
                                      return Center(
                                        child: Container(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    return Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                      child: DataTable(
                                        dataRowHeight: 60.0,
                                        columnSpacing: screenWidth * 0.005,
                                        columns: [
                                          DataColumn(
                                              label: Text(
                                            'Date',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 16.0),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Meal',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 16.0),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Type',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 16.0),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Quantity',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 16.0),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Amount',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 16.0),
                                          )),
                                          DataColumn(
                                              label: Text(
                                            'Delete',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 16.0),
                                          )),
                                        ],
                                        rows: _buildList(snapshot.data),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _showCircularProgress(),
        ],
      ),
    );
  }
}
