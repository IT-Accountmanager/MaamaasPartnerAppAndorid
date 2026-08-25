import 'package:flutter/material.dart';
import 'package:maamaaspartner/user_module/API/food_authservice.dart';


class FavoriteButton1 extends StatefulWidget {
  final int? favId;
  final VoidCallback? onFavoriteToggled; // <-- Add this

  const FavoriteButton1({
    required this.favId,
    this.onFavoriteToggled, // <-- Add this
    Key? key,
  }) : super(key: key);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}


class _FavoriteButtonState extends State<FavoriteButton1> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    // If there's a favId, we assume it's already favorited
    isFavorite = widget.favId != null && widget.favId != 0;
  }

  void toggleFavorite() async {
    // print("pp");
    if (!isFavorite) return;

    final success = await food_Authservice.unfavoriteDish(widget.favId ?? 0);

    if (success) {
      setState(() {
        isFavorite = false;
      });

      if (widget.onFavoriteToggled != null) {
        widget.onFavoriteToggled!(); // <-- Trigger the callback
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to remove from favorites")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : Colors.grey,
      ),
      onPressed: toggleFavorite,
    );
  }
}