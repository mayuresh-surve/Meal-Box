import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meal_box/authentication.dart';

class ResetPassword extends StatefulWidget {
  ResetPassword({Key key, this.auth}) : super(key: key);
  final BaseAuth auth;

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = new GlobalKey<FormState>();
  String _email;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        await widget.auth.resetPassword(_email);
        _showDialog('Done!', 'Please check your Email to change password');
      } catch (e) {
        print('Error: $e');
        setState(() {
          _formKey.currentState.reset();
        });
      }
    }
  }

  void resetForm() {
    _formKey.currentState.reset();
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
                resetForm();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Please enter Email registered with your account',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
                decoration: new InputDecoration(
                    hintText: 'Email',
                    icon: new Icon(
                      Icons.mail,
                      color: Colors.grey,
                    )),
                validator: (value) =>
                    value.isEmpty ? 'Email can\'t be empty' : null,
                onSaved: (value) => _email = value.trim(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: RaisedButton(
                elevation: 5.0,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Color(0xFF4FCB58),
                child: new Text('Submit',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white)),
                onPressed: validateAndSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
