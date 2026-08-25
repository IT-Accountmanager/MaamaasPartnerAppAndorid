import 'package:flutter/cupertino.dart';

enum TransitionType {
  fade,
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
  scale,
  rotation,
  slideFade,
}

void navigateWithTransition(
  BuildContext context,
  Widget page,
  TransitionType type,
) {
  PageRouteBuilder route;

  switch (type) {
    case TransitionType.fade:
      route = PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
      break;

    case TransitionType.leftToRight:
      route = PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final offset = Tween<Offset>(
            begin: Offset(-1, 0),
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(position: offset, child: child);
        },
      );
      break;

    case TransitionType.rightToLeft:
      route = PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final offset = Tween<Offset>(
            begin: Offset(1, 0),
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(position: offset, child: child);
        },
      );
      break;

    case TransitionType.topToBottom:
      route = PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final offset = Tween<Offset>(
            begin: Offset(0, -1),
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(position: offset, child: child);
        },
      );
      break;

    case TransitionType.bottomToTop:
      route = PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final offset = Tween<Offset>(
            begin: Offset(0, 1),
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(position: offset, child: child);
        },
      );
      break;

    case TransitionType.scale:
      route = PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final scale = Tween<double>(begin: 0.8, end: 1.0).animate(animation);
          return ScaleTransition(scale: scale, child: child);
        },
      );
      break;

    case TransitionType.rotation:
      route = PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return RotationTransition(turns: animation, child: child);
        },
      );
      break;

    case TransitionType.slideFade:
      route = PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final offset = Tween<Offset>(
            begin: Offset(1, 0),
            end: Offset.zero,
          ).animate(animation);
          final fade = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
          return SlideTransition(
            position: offset,
            child: FadeTransition(opacity: fade, child: child),
          );
        },
      );
      break;
  }

  Navigator.push(context, route);
}
