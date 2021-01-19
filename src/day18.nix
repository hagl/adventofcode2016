with (import <nixpkgs/lib>);
with (import ./utils.nix);

let 
  parseSetup = line:
    let matches = map toInt (builtins.match "Disc #([0-9])+ has ([0-9]+) positions; at time=0, it is at position ([0-9]+)." line);
    in { n = elemAt matches 0; p = elemAt matches 1; s = elemAt matches 2;};

  step = { c, l }: _:
    let
      next = nextLine l;
      result = { l = next; c = c + countSave next; };
    in deepSeq result result;

  nextLine = l:
    let
      rule = t: let 
        a = elemAt t 0;
        b = elemAt t 1;
        c = elemAt t 2;
      in 
        if (a == "^" && b == "^" && c == ".") ||
           (a == "." && b == "^" && c == "^") ||
           (a == "^" && b == "." && c == ".") ||
           (a == "." && b == "." && c == "^") 
        then "^" else ".";
    in map rule (sliding (["."] ++ l ++ ["."]) 3);

  countSave = l: 
    length ( filter (c: c == ".") l);

  solve = file: count:
    let
      firstLine = stringToCharacters (readFile file);
    in
      foldl' step { l = firstLine; c = countSave firstLine; } (range 2 count);

in
  {
    solutionEx = solve ./day18ex.txt 10;
    solution = solve ./day18.txt 40;
    solution2 = solve ./day18.txt 400000;
  }
