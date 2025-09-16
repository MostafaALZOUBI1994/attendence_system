import 'package:flutter/material.dart';

class ServiceDef {
  final IconData icon;
  final String titleKey;
  final WidgetBuilder builder;
  const ServiceDef({required this.icon, required this.titleKey, required this.builder});
}
