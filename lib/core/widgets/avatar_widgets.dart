
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../constants/constants.dart';
import '../injection.dart';
import '../utils/Initials.dart';

import '../utils/base64_utils.dart';

class CircleAvatarOrInitials extends StatelessWidget {
  final String? base64;
  final String fullName;
  final double radius;

  const CircleAvatarOrInitials({
    super.key,
    required this.base64,
    required this.fullName,
    this.radius = 26,
  });

  @override
  Widget build(BuildContext context) {
    // decode once & reuse via cache; width ~ diameter is a good hint
    final img = getIt<AvatarCache>().fromBase64(base64, targetWidth: (radius * 2).round());

    return CircleAvatar(
      radius: radius,
      backgroundColor: lightGray,
      backgroundImage: img,
      child: img == null ? Initials(fullName) : null,
    );
  }
}

class RectAvatarOrInitials extends StatelessWidget {
  final String? base64;
  final String fullName;
  final double size; // square

  const RectAvatarOrInitials({
    super.key,
    required this.base64,
    required this.fullName,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    final img = getIt<AvatarCache>().fromBase64(base64, targetWidth: size.round());

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: img != null
          ? Image(image: img, width: size, height: size, fit: BoxFit.cover)
          : Container(
        width: size,
        height: size,
        color: lightGray,
        alignment: Alignment.center,
        child: Initials(fullName),
      ),
    );
  }
}