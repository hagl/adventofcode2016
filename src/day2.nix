with (import <nixpkgs/lib>); 
with trivial;
let 
  move = pos: c: 
    if c == "U" then pos // { y = max (pos.y - 1) 0; } 
    else if c == "D" then pos // { y = min (pos.y + 1) 2; }
    else if c == "L" then pos // { x = max (pos.x - 1) 0; }
    else if c == "R" then pos // { x = min (pos.x + 1) 2; }
    else "unexpected character";
    
  abs = x: if x < 0 then (-x) else x;

  move2 = pos: c: 
    if c == "U" then pos // { y = max (pos.y - 1) (abs (2 - pos.x)); } 
    else if c == "D" then pos // { y = min (pos.y + 1) (4 - abs (2 - pos.x)); }
    else if c == "L" then pos // { x = max (pos.x - 1) (abs (2 - pos.y)); }
    else if c == "R" then pos // { x = min (pos.x + 1) (4 - abs (2 - pos.y)); }
    else "unexpected character";

  # moveLine: (pos, [pos]) -> string -> (pos, [pos])
  moveLine = m: acc: str:
    let result = foldl m acc.pos (stringToCharacters str);
    in { pos = result; list = acc.list ++ [ result ]; };

  decode = p: 
    toString ((3*p.y) + p.x + 1);

  values = map stringToCharacters [ 
    "XX1XX"
    "X234X"
    "56789"
    "XABCX"
    "XXDXX"
  ];

  decode2 = p: 
    elemAt (elemAt values p.y) p.x;

  solve = file: start: m: d:
    let
      str = readFile file;
      list = splitString "\n" str;
      positions = foldl (moveLine m) { pos = start; list = []; } list;
    in concatStrings (map d (positions.list));

  solve1 = file: solve file { x = 1; y = 1;} move decode;
  solve2 = file: solve file { x = 0; y = 2;} move2 decode2;

in 
  {
    ex = solve1 ./day2ex.txt;
    ex2 = solve2 ./day2ex.txt;
    solution = solve1 ./day2.txt;
    solution2 = solve2 ./day2.txt;
  }

