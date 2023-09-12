/*import 'package:flutter/material.dart';
import 'package:journey2go/StartFrom.dart';
import 'package:journey2go/FilterMosque.dart';
import 'package:journey2go/FilterMuseum.dart';
import 'package:journey2go/FilterNature.dart';

import 'FilterWeather.dart';

class FilterButtons extends StatelessWidget {
  const FilterButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:<Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => Weather()),
              );
            },
            child: Icon(Icons.cloud, color: Colors.white),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(20),
              backgroundColor: Colors.red[900], // <-- Button color
              foregroundColor: Colors.redAccent[700], // <-- Splash color
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => Mall()),
              );
            },
            child: Icon(Icons.shopping_bag, color: Colors.white),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(20),
              backgroundColor: Colors.red[900], // <-- Button color
              foregroundColor: Colors.redAccent[700], // <-- Splash color
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => Museum()),
              );
            },
            child: Icon(Icons.museum, color: Colors.white),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(20),
              backgroundColor: Colors.red[900], // <-- Button color
              foregroundColor: Colors.redAccent[700], // <-- Splash color
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => Nature()),
              );
            },
            child: Icon(Icons.park, color: Colors.white),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(20),
              backgroundColor: Colors.red[900], // <-- Button color
              foregroundColor: Colors.redAccent[700], // <-- Splash color
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => Mosque()),
              );
            },
            child: Icon(Icons.mosque, color: Colors.white),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(20),
              backgroundColor: Colors.red[900], // <-- Button color
              foregroundColor: Colors.redAccent[700], // <-- Splash color
            ),
          ),
        ],
      ),
    );
  }
}
*/