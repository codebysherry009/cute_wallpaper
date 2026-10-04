import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'config.dart';

/// Decodes JSON even if the PHP script printed warnings / BOM before it.
dynamic decodeLoose(String body) {
  var s = body.replaceAll('\uFEFF', '').trim();
  final i = s.indexOf(RegExp(r'[\[{]'));
  if (i < 0) throw const FormatException('Invalid server response');
  if (i > 0) s = s.substring(i);
  return jsonDecode(s);
}

const _preferredKeys = [
  'data',
  'wallpapers',
  'categories',
  'featured',
  'trending',
  'result',
  'results',
  'items',
  'wallpaper',
  'category',
];

bool _looksLikeItem(dynamic v) {
  if (v is! Map || v.isEmpty) return false;
  final keys = v.keys.map((k) => k.toString().toLowerCase()).toSet();
  const hints = [
    'id', 'name', 'title', 'image', 'image_url', 'image_file', 'thumbnail',
    'thumb', 'category', 'category_name', 'wallpaper', 'file', 'url', 'path',
  ];
  return keys.any(hints.contains);
}

List? _findList(dynamic node, int depth) {
  if (node is List) return node;
  if (node is Map && depth < 4) {
    final lower = <String, dynamic>{
      for (final e in node.entries) e.key.toString().toLowerCase(): e.value,
    };
    for (final k in _preferredKeys) {
      if (lower.containsKey(k)) {
        final r = _findList(lower[k], depth + 1);
        if (r != null) return r;
      }
    }
    for (final v in lower.values) {
      if (v is List || v is Map) {
        final r = _findList(v, depth + 1);
        if (r != null) return r;
      }
    }
    // Object keyed by id, e.g. {"1": {...}, "2": {...}} instead of a real array.
    if (node.values.every(_looksLikeItem)) {
      return node.values.toList();
    }
  }
  return null;
}

/// Works with `[ {...} ]` and with `{ "status": true, "data": [ {...} ] }`.
List<Map<String, dynamic>> extractList(dynamic decoded) {
  final list = _findList(decoded, 0) ?? const [];
  final out = <Map<String, dynamic>>[];
  for (final e in list) {
    if (e is Map) {
      out.add(Map<String, dynamic>.from(e));
    } else if (e is String && e.trim().isNotEmpty) {
      out.add({'image': e});
    }
  }
  return out;
}

/// If server says failure, returns its message.
String? serverError(dynamic decoded) {
  if (decoded is! Map) return null;
  final lower = <String, dynamic>{
    for (final e in decoded.entries) e.key.toString().toLowerCase(): e.value,
  };
  final s = (lower['success'] ?? lower['status'] ?? lower['error'])
      ?.toString()
      .toLowerCase();
  const bad = ['false', 'error', 'failed', '0'];
  if (s != null && bad.contains(s)) {
    return (lower['message'] ?? lower['msg'])?.toString() ?? 'Server error';
  }
  return null;
}

Map<String, dynamic> lowerKeys(Map<String, dynamic> m) => {
      for (final e in m.entries) e.key.toLowerCase(): e.value,
    };

String pickStr(Map<String, dynamic> lower, List<String> keys) {
  for (final k in keys) {
    final v = lower[k];
    if (v == null) continue;
    final s = v.toString().trim();
    if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
  }
  return '';
}

/// Makes any image value from the API a clean absolute URL
/// (fixes relative paths, "//", "///", spaces, escaped slashes).
String resolveUrl(String raw) {
  var u = raw.trim().replaceAll(r'\/', '/');
  if (u.isEmpty) return '';
  if (u.startsWith('//')) {
    u = 'https:$u';
  } else if (!RegExp(r'^https?://', caseSensitive: false).hasMatch(u)) {
    u = u.startsWith('/') ? '${AppConfig.host}$u' : '${AppConfig.apiBase}$u';
  }
  u = u.replaceFirstMapped(
    RegExp(r'^(https?://)(.*)$', caseSensitive: false),
    (m) => '${m[1]}${m[2]!.replaceAll(RegExp(r'/{2,}'), '/')}',
  );
  return u.replaceAll(' ', '%20');
}
