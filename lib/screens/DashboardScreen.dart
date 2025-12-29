import 'package:bazar/screens/FavouriteScreen.dart';
import 'package:bazar/screens/HomeScreen.dart';
import 'package:bazar/screens/ProfileScreen.dart';
import 'package:bazar/screens/SavedScreen.dart';
import 'package:bazar/theme/colors.dart';
import 'package:bazar/theme/textstyle.dart';
import 'package:flutter/material.dart';

class Dashboardscreen extends StatefulWidget {
  const Dashboardscreen({super.key});

  @override
  State<Dashboardscreen> createState() => _DashboardscreenState();
}

class _DashboardscreenState extends State<Dashboardscreen> {
  int _selectedIndex=0;

  List<Widget> lstBottomScreen =[
  const Homescreen(),
  const Savedscreen(),
  const Favouritescreen(),
  const Profilescreen(),
];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
       lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 40,
        items: const[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved'),
           BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favourites'),
           BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index){
          setState(() {
            _selectedIndex=index;
          });
        },
        ),
        );
  }
}