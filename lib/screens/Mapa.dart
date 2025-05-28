import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Pages.dart';

class Mapa extends StatelessWidget {
  const Mapa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(pages[2].title,style: TextStyle(fontFamily: "NotoSans"),),
      ),
      body: SizedBox.expand(
        child: Image(
            fit: BoxFit.cover,
            image: NetworkImage("https://www.portugalmapa.com/wp-content/uploads/2018/12/Mapa-Lisboa.jpg")
        ),
      ),

    );
  }
}