import 'dart:convert';

import 'package:flutter/material.dart';

ImageProvider? decodeBase64(String? b64) {
  if (b64 == null || b64.isEmpty) return null;
  try {
    final cleaned = b64.contains(',') ? b64.substring(b64.indexOf(',') + 1) : b64;
    return MemoryImage(base64Decode(cleaned));
  } catch (_) {
    return null;
  }
}