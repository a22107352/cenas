import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'Lista.dart';
import 'Mapa.dart';
import 'Avaliacoes.dart';

class PageItem {
  final String title;
  final IconData icon;
  final Widget widget;
  final Key key;

  PageItem({
    required this.title,
    required this.icon,
    required this.widget,
    required this.key,
  });
}

final List<PageItem> pages = [
  PageItem(
    title: "Dashboard",
    icon: Icons.dashboard,
    widget: Dashboard(),
    key: Key("dashboard-bottom-bar-item"),
  ),
  PageItem(
    title: "Lista",
    icon: Icons.list_alt,
    widget: Lista(),
    key: Key("lista-bottom-bar-item"),
  ),
  PageItem(
    title: "Mapa",
    icon: Icons.map,
    widget: GoogleMapPage(),
    key: Key("mapa-bottom-bar-item"),
  ),
  PageItem(
    title: "Avaliações",
    icon: Icons.star_rate,
    widget: Avaliacoes(),
    key: Key("avaliacoes-bottom-bar-item"),
  ),
];
