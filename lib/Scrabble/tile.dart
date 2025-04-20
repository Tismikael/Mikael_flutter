import "package:flutter/material.dart";


class Tile extends Container
{
  final String letter;
  Tile( this.letter, {Color? color, required Color borderColor}) : super 
  (
    decoration: BoxDecoration(
      border: Border.all(width: 1, color: borderColor),
      color: color ?? Colors.lightGreen[800],
       ),
      width: 30, height: 30,
      child: Center(child:Text(letter, style: const TextStyle(fontSize: 20) ) ) ,
  );
}

