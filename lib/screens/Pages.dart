import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Avaliacoes.dart';
import 'Lista.dart';
import 'Mapa.dart';
import 'dashboard.dart';
final pages = [
  (title: "Dashboard", icon: Icons.dashboard , widget: Dashboard(),key:Key("dashboard-bottom-bar-item")),
  (title: "Lista", icon: Icons.list_alt , widget:Lista(),key:Key("lista-bottom-bar-item")),
  (title: "Mapa", icon: Icons.map , widget:Mapa(),key:Key("mapa-bottom-bar-item")),
  (title: "Avalições", icon: Icons.star_rate , widget:Avaliacoes(),key: Key("avaliacoes-bottom-bar-item")),

];

