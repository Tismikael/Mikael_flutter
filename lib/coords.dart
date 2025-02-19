class Coords
{
  int c;
  int r;

  Coords( this.c, this.r );

  bool equals( Coords there )
  { return there.c==c && there.r==r;
  }

  // code to serialize Coords to JSON
  Map<String, dynamic> toMap() {
    return {
      'c': c,
      'r': r,
    };
  }

  // code to deserialize Coords from JSON
  factory Coords.fromMap(Map<String, dynamic> map){
    return Coords(
      map['c'],
      map['r'],
    );
  }
}