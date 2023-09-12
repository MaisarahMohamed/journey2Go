import 'package:flutter/material.dart';
import 'package:journey2go/AllLocation.dart';
import 'package:journey2go/FavouritesPage.dart';
import 'package:journey2go/NavBar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:journey2go/NearMe.dart';
import 'package:journey2go/StartFrom.dart';
import 'package:journey2go/Trip.dart';
import 'package:journey2go/auth/CheckStatus.dart';
import 'SplashScreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/home': (context) => const HomePage(),
      '/itinerary': (context) => const Itinerary(),
      '/favourite': (context) => const FavouritesPage(),
    },
  ));
}

class MyApp extends StatelessWidget {

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journey2Go',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(child:Text('All')),
              Tab(child:Text('Near Me')),
              Tab(child:Text('Start From')),
            ],
          ),
          title: Image.asset('assets/logo.png', scale: 3.2),
          centerTitle: true,
          backgroundColor: Colors.indigo[900],
          actions: [
            IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>FavouritesPage()));
            }, icon: Icon(Icons.favorite))
          ],
        ),
        drawer: NavBar(),
        body: TabBarView(
          children: [
            AllLocation(),
            NearMe(),
            StartFrom(),
          ],
        ),
      ),
    );
  }
}