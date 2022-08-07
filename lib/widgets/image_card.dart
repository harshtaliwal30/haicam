import 'dart:io';

import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final dynamic imageData;
  const ImageCard(this.imageData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Image.file(
          File(imageData["image"]),
          fit: BoxFit.cover,
          height: (size.width / (size.width / 150).ceil()) * 0.8,
          width: (size.width / (size.width / 150).ceil()),
        ),
        Text(
          imageData["title"],
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: (size.width / (size.width / 150).ceil()) * 0.1,
          ),
        )
      ],
    );
  }
}
