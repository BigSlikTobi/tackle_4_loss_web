import 'package:flutter/material.dart';

class Team {
  final String id;
  final String name;
  final String logoUrl;
  final Color primaryColor;

  const Team({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.primaryColor,
  });
}
