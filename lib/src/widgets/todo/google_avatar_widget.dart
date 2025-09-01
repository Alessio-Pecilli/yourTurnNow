import 'package:flutter/material.dart';

String? googlePhotoSized(String? url, {int size = 64}) {
  if (url == null || url.isEmpty) return null;
  final uri = Uri.parse(url);
  final qp = Map<String, String>.from(uri.queryParameters);
  qp['sz'] = '$size';
  return uri.replace(queryParameters: qp).toString();
}

class GoogleAvatar extends StatelessWidget {
  const GoogleAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 18,
    this.tooltip,
  });

  final String name;
  final String? photoUrl;
  final double radius;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final sized = googlePhotoSized(photoUrl, size: (radius * 2).round());
    final avatarCore = ClipOval(
      child: sized == null
          ? _fallback(name, radius)
          : Image.network(
              sized,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(name, radius),
              loadingBuilder: (c, w, progress) => progress == null
                  ? w
                  : Container(
                      width: radius * 2,
                      height: radius * 2,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
            ),
    );

    final avatarWithBorder = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
      ),
      child: SizedBox(width: radius * 2, height: radius * 2, child: avatarCore),
    );

    final semantic = Semantics(label: 'Foto profilo di $name', image: true, child: avatarWithBorder);
    return tooltip == null ? semantic : Tooltip(message: tooltip!, child: semantic);
  }

  Widget _fallback(String name, double radius) {
    final initials = _initials(name);
    return Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      child: Text(initials, style: TextStyle(fontSize: radius * 0.9, fontWeight: FontWeight.w600)),
    );
  }

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.characters.take(2).toString().toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }
}
