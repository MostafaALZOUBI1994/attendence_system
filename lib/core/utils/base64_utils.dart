// lib/core/utils/avatar_cache.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AvatarCache {
  final Map<int, ImageProvider<Object>> _cache = {};

  /// Returns a cached ImageProvider for a base64 string.
  /// Decodes only once per unique string (and targetWidth).
  ImageProvider<Object>? fromBase64(String? b64, {int? targetWidth}) {
    if (b64 == null || b64.isEmpty) return null;

    // strip data URI prefix if present
    final core = b64.contains(',') ? b64.substring(b64.indexOf(',') + 1) : b64;

    // Keyed by content and resize target so we can reuse safely.
    final key = Object.hash(core, targetWidth);

    final cached = _cache[key];
    if (cached != null) return cached;

    try {
      final Uint8List bytes = base64Decode(core);
      ImageProvider<Object> img = MemoryImage(bytes);
      if (targetWidth != null) {
        // decode at a smaller size to save RAM/CPU (useful for avatars)
        img = ResizeImage(img, width: targetWidth);
      }
      _cache[key] = img;
      return img;
    } catch (_) {
      return null;
    }
  }

  void clear() => _cache.clear();              // e.g., on logout
  void remove(String? b64, {int? targetWidth}) {
    if (b64 == null) return;
    final core = b64.contains(',') ? b64.substring(b64.indexOf(',') + 1) : b64;
    _cache.remove(Object.hash(core, targetWidth));
  }
}