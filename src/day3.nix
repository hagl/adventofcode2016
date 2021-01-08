with (import <nixpkgs/lib>); 
let 
  parseLine = line:
    map toInt (filter (s: s != "") (splitString " " line));

  isTriangleLine = line:
    let 
      numbers = parseLine line;
      a = elemAt numbers 0;
      b = elemAt numbers 1;
      c = elemAt numbers 2;
    in isTriangle a b c;

  isTriangle = a: b: c:
    (a + b > c) && (a + c > b) && (b + c > a);

  lines = str:
     filter (s: s != "") (map head (filter isList (builtins.split "([^\n]*)" str)));

  solve = file: 
    let
      str = readFile file;
      list = lines str;
    # in list;
    in length (filter isTriangleLine list);

  solve2 = file:
    let
      str = readFile file;
      list = map parseLine (lines str);
    in solve2go list 0;

  solve2go = list: acc:
    if (list == []) then acc else let
      newAcc = solve2go2 (elemAt list 0) (elemAt list 1) (elemAt list 2) acc;
    in solve2go (tail (tail (tail list))) newAcc;

  solve2go2 = l1: l2: l3: acc: 
    if l1 == [] then acc else let
      a = head l1;
      b = head l2;
      c = head l3;
    in solve2go2 (tail l1) (tail l2) (tail l3) (acc + (if isTriangle a b c then 1 else 0));

in 
  {
    solution = solve ./day3.txt;
    solution2 = solve2 ./day3.txt;
  }

