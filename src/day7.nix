with (import <nixpkgs/lib>); 
let 
  lines = str:
     filter (s: s != "") (map head (filter isList (builtins.split "([^\n]*)" str)));

  splitList = list: 
    let 
      go = acc1: acc2: list: if list == [] then [acc2 acc1] else go acc2 (acc1 ++ [(head list)]) (tail list); 
    in go [] [] list;

  parts = str:
    splitList (filter isString ( builtins.split "[\][]" str));

  hasABBAat = str: ix: 
    let
      c0 = elemAt str ix;
      c1 = elemAt str (ix + 1);
      c2 = elemAt str (ix + 2);
      c3 = elemAt str (ix + 3);
    in c0 ==c3 && c1 == c2 && c0 != c1;

  containsABBA = str:
    any (hasABBAat (stringToCharacters str)) (range 0 ((stringLength str) - 4));

  hasTLS = str:
    let
      p = parts str;
      l1 = elemAt p 0;
      l2 = elemAt p 1;
    in (any containsABBA l1) && !(any containsABBA l2);

  findABAat = str: ix:
    let
      c0 = elemAt str ix;
      c1 = elemAt str (ix + 1);
      c2 = elemAt str (ix + 2);
    in if c0 ==c2 && c0 != c1 then [ "${c1}${c0}${c1}" ] else [];

  findABAs = str:
    concatLists (map (findABAat (stringToCharacters str)) (range 0 ((stringLength str) - 3)));

  containsABAs = list: str:
    any (s: any (x: x == s) list) (map (ix: substring ix 3 str) (range 0 ((stringLength str) - 3)));

  hasSSL = str:
    let
      p = parts str;
      l1 = elemAt p 0;
      l2 = elemAt p 1;
      abas = (concatLists (map findABAs l1));
    in (any (containsABAs abas) l2);

  solve = file:
    let
      addrs = lines (readFile file);
      tlss = filter hasTLS addrs;
    in
      length tlss;

  solve2 = file:
    let
      addrs = lines (readFile file);
      ssls = filter hasSSL addrs;
    in
      length ssls;

in 
  {
    solutionEx = solve ./day7ex.txt;
    solution2Ex = solve2 ./day7ex2.txt;
    solution = solve ./day7.txt;
    solution2 = solve2 ./day7.txt;
  }

