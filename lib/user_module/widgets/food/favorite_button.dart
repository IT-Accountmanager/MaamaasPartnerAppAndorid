import 'package:flutter/material.dart';
import '../../API/food_authservice.dart';

class FavoriteButton extends StatefulWidget {
  final dish;

  const FavoriteButton({required this.dish, Key? key}) : super(key: key);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool isFavorite = false;

  Future<void> _handleFavorite() async {
    bool success = await food_Authservice.addToFavorites(widget.dish.dishId ?? 0);
    if (success) {
      setState(() => isFavorite = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to favorites')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add to favorites')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero, // remove default padding
      constraints: const BoxConstraints(), // shrink wrap the icon
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : Colors.grey,
        size: 20, // adjust size to fit CircleAvatar
      ),
      onPressed: _handleFavorite,
    );
  }
}
