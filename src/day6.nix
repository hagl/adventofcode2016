with (import <nixpkgs/lib>); 
let 
  lines = str:
     filter (s: s != "") (map head (filter isList (builtins.split "([^\n]*)" str)));

  compare = s1: s2:
    (s1.count > s2.count) || (s1.count == s2.count && s1.char < s2.char);

  mostCommonChar = lines: most: pos:
    let
      chars = map (l: substring pos 1 l) lines;
      grouped = groupBy id chars;
      countedChars = map (c: {char=c; count = (length (getAttr c grouped));}) (attrNames grouped);
      sorted = sort compare countedChars;
    in if most then (head sorted).char else (last sorted).char;
 
  solve = file: most:
    let
      str = readFile file;
      chars = map (mostCommonChar (lines str) most) (range 0 7);
    in
      concatStrings chars;

in 
  {
    solutionEx = solve ./day6ex.txt true;
    solution2Ex = solve ./day6ex.txt false;
    solution = solve ./day6.txt true;
    solution2 = solve ./day6.txt false;
  }

