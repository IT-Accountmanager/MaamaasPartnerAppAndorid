import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';

void openProfileDrawer(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Profile",
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height,
          child: Material(
            color: Colors.white,
            child: SafeArea(
              bottom: true,
              child: Column(
                children: [
                  // Align(
                  //   alignment: Alignment.topRight,
                  //   child: IconButton(
                  //     icon: const Icon(Icons.close, size: 28),
                  //     onPressed: () {
                  //       Navigator.of(context).pop();
                  //     },
                  //   ),
                  // ),
                  Expanded(child: Profile()),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(anim1),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
