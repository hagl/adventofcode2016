with (import <nixpkgs/lib>); 
with (import ./utils.nix); 

let 
  chars = stringToCharacters "1234567890abcdef";
  
  c5res = map (c: ".*" + (concatStrings (genList (_: c) 5)) + ".*") chars;

  firstTriple = str: let 
      go = c: n: l: if n == 0 then c 
        else if l == [] then null 
        else if (head l) == c then go c (n - 1) (tail l)
        else go (head l) 2 (tail l);
      cs = stringToCharacters str;
    in go (head cs) 2 (tail cs);

  fiveEqual = s:
    map (i: elemAt chars i) (filter (i: builtins.match (elemAt c5res i) s != null) (range 0 15));

  md5 = salt: ix:
    builtins.hashString "md5" (salt + toString ix);

  md5_2017 = salt: ix:
    let 
      hash = builtins.hashString "md5";
    in foldl' (a: _: hash a) (salt + toString ix) (range 0 2016);

  step = first: salt: acc: n: 
    let
      hash = if first then md5 salt n else md5_2017 salt n;
      fs = fiveEqual hash;
      newResults = concatLists (map (c: (filter (m: m> n - 1000) acc.l.${c})) fs);
      triple = firstTriple hash;
      newList = foldl' (a: c: a // {${c} = (if elem c fs then [] else acc.l.${c}) ++ (if c == triple then [n] else []);}) {} chars;
      newAcc = { l = newList; r = acc.r ++ newResults; };
    in deepSeq(newAcc) newAcc;

  solve = salt: first:
    let
      l = foldl' (acc: c: acc // { ${c} = []; }) {} chars;
      x = foldl' (step first salt) { inherit l; r = [];} (range 0 40000);
    in
      builtins.trace(toString (length x.r))
        take 64 (sort (a: b: a<b) x.r);

in 
  {
    solutionEx = solve "abc" true;
    solution = solve "yjdafjpo" true;
    solution2Ex = solve "abc" false;
    solution2 = solve "yjdafjpo" false;
  }

