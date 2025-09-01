import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''
      <svg xmlns="http://www.w3.org/2000/svg" width="$size" height="$size" viewBox="0 0 48 48">
        <path fill="#4285F4" d="M24 9.5c3.2 0 6 1.1 8.2 3.2l6.1-6.1C34.7 3 29.7 1 24 1 14.9 1 7 6.7 3.5 14.7l7.2 5.6C12.2 14.5 17.6 9.5 24 9.5z"/>
        <path fill="#34A853" d="M46.5 24.5c0-1.6-.1-3.1-.4-4.5H24v9h12.7c-.6 3-2.2 5.5-4.6 7.2l7.2 5.6c4.2-3.9 6.6-9.6 6.6-17.3z"/>
        <path fill="#FBBC05" d="M10.7 28.9c-1-2.9-1-6.1 0-9l-7.2-5.6C1.1 18 0 21 0 24s1.1 6 3.5 9l7.2-4.1z"/>
        <path fill="#EA4335" d="M24 47c6.5 0 12-2.1 16-5.7l-7.2-5.6c-2.1 1.5-4.9 2.5-8.8 2.5-6.4 0-11.8-5-13.3-11.7l-7.2 5.6C7 41.3 14.9 47 24 47z"/>
      </svg>
      ''',
      width: size,
      height: size,
    );
  }
}
