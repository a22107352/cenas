
import 'package:flutter/material.dart';
import 'package:prjectcm/screens/Pages.dart';



class Mainpage extends StatefulWidget {
  Mainpage({super.key});

  @override
  State<Mainpage> createState() => MainpageState();
}

class MainpageState extends State<Mainpage> {
  int _selectedIndex= 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex].widget,
      bottomNavigationBar: NavigationBar(
        selectedIndex:_selectedIndex ,
        onDestinationSelected: (index)=> setState(() => _selectedIndex= index),
        destinations: pages.map((page) => NavigationDestination(icon: Icon(page.icon,key: page.key,), label: page.title)).toList(),
      ),
    );
  }
}
