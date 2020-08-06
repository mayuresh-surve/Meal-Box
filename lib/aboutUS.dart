import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'meal_box_icons.dart';

class AboutUs extends StatelessWidget {
  double screenWidth;
  double screenHeight;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            width: screenWidth,
            height: screenHeight * 0.2,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/aboutUscover.jpg'),
                  fit: BoxFit.cover),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: screenWidth,
                color: Color(0xcf093E60),
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0, top: 5.0, bottom: 5.0),
                  child: Text(
                    'About the Developer',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Card(
              borderOnForeground: true,
              shape: Border(
                bottom: BorderSide(color: Color(0xcf093E60), width: 3.0),
              ),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/images/myImage.png'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Mayuresh Surve',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Student, Atharva College of Engineering',
                                style: TextStyle(fontSize: 14),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          GestureDetector(
                            child: Icon(MealBox.twitter),
                            onTap: () {
                              launch(
                                  'https://twitter.com/SurveMayuresh');
                            },
                          ),
                          GestureDetector(
                            child: Icon(MealBox.linkedin),
                            onTap: () {
                              launch(
                                  'https://www.linkedin.com/in/mayuresh-surve/');
                            },
                          ),
                          GestureDetector(
                            child: Icon(MealBox.instagram),
                            onTap: () {
                              launch(
                                  'https://www.instagram.com/mayuresh.surve/');
                            },
                          ),
                          GestureDetector(
                            child: Icon(MealBox.github_circled),
                            onTap: () {
                              launch(
                                  'https://github.com/mayuresh-surve');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
