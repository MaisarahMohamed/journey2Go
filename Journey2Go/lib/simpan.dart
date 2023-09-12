/*
floatingActionButton: FloatingActionButton(
          onPressed: (){
            setState(() {
              checkedList.clear();
            });
            late TripModel temp;
            for(int i=0 ; i<=places.length ; i++){
              if(isChecked.elementAt(i)){
                temp = new TripModel(
                  destination: places.elementAt(i).destination,
                  description: places.elementAt(i).description,
                  image: places.elementAt(i).image,
                  date: startLocation.startDate,
                  time: startLocation.startTime,
                  id: user?.uid,
                  startDest: startLocation.address,
                  latitude: places.elementAt(i).latitude,
                  longitude: places.elementAt(i).longitude,
                  distance: dist.elementAt(i),
                );
                setState(() {
                  checkedList.add(temp);
                });
              }
            }
            setState(() {
              checkedList.sort((a,b)=> b.distance.compareTo(a.distance));
            });
            checkedList.isNotEmpty ?
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                    title: Text('Save Your Trip'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Overview',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "Starting Point: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Flexible(child: Text('${startLocation.address}', overflow: TextOverflow.ellipsis, maxLines: 1,))
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Date of Trip: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('${startLocation.startDate}')
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Start Journey Time: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('${startLocation.startTime}')
                          ],
                        ),
                        SizedBox(height: 15,),
                        Text(
                          "Trip Planned For You:",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5,),
                        for(int i = 0 ; i < checkedList.length ; i++)
                          Row(
                            children: [
                              Text('${(TimeOfDay(hour:(int.parse(checkedList.elementAt(i).time.split(":")[0])+i),
                                  minute: int.parse(checkedList.elementAt(i).time.split(":")[1]))).format(context)} - '),
                              Text(checkedList.elementAt(i).destination,textAlign: TextAlign.left,),
                            ],
                          )
                      ],
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            // If the button is pressed, return green, otherwise blue
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.red;
                            }
                            return Colors.white;
                          }),
                        ),
                        child: Text('Cancel',style: TextStyle(color: Colors.black),),
                        onPressed: () {
                          Navigator.pop(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage(isBottomSheetShow: false)
                              )
                          );
                        },
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            // If the button is pressed, return green, otherwise blue
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.red;
                            }
                            return Colors.redAccent;
                          }),
                        ),
                        child: Text('Save'),
                        onPressed: () {
                          for(int i=0;i<checkedList.length;i++) {
                            Map<String, dynamic>tripData = {
                              'uid': user?.uid,
                              'destination': checkedList.elementAt(i).destination,
                              'description': checkedList.elementAt(i).description,
                              'startFrom': checkedList.elementAt(i).startDest,
                              'image': checkedList.elementAt(i).image,
                              'date': checkedList.elementAt(i).date,
                              'time': (TimeOfDay(hour:(int.parse(checkedList.elementAt(i).time.split(":")[0])+i),
                                  minute: int.parse(checkedList.elementAt(i).time.split(":")[1]))).format(context),
                            };
                            FirebaseFirestore.instance.collection('trip').add(tripData)
                                .catchError((error) =>
                                Fluttertoast.showToast(
                                  msg:'Trip Failed To Save. $error',
                                ),
                            );
                          }
                          Fluttertoast.showToast(
                            msg:'Trip Successfully Saved',
                          );
                          Navigator.pop(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage(isBottomSheetShow: false)
                              )
                          );
                        },
                      )
                    ],
                    actionsAlignment: MainAxisAlignment.center
                )
            )
                : showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                    title: Text('Alert!'),
                    content: Text('Please tick one of the places first'),
                    actions: <Widget>[
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            // If the button is pressed, return green, otherwise blue
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.red;
                            }
                            return Colors.redAccent;
                          }),
                        ),
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.pop(
                              context,
                              MaterialPageRoute(builder: (context) => HomePage(isBottomSheetShow: false))
                          );
                        },
                      )
                    ],
                    actionsAlignment: MainAxisAlignment.center
                )
            );
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.add),
        ),
 */