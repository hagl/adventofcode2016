with (import <nixpkgs/lib>); 
let
  sum = list:
    foldl (a: b: a+b) 0 list;

  product = list:
    foldl (a: b: a*b) 1 list;
   
  indexOf = elem: list:
    let 
      len = length list;
      go = c: 
        if c >= len then -1 else if elem == elemAt list c then c else go (c + 1);
    in go 0;

  startsWith = sub: str:
    let 
      d = stringLength sub;
      s = substring str d;
    in sub == s;

  lines = str:
    filter (s: s != "") (map head (filter isList (builtins.split "([^\n]*)" str)));

  updateList = arr: y: el:
    (take y arr) ++ [el] ++ (drop (y + 1) arr);

  repeat = n: f: s: foldl' (acc: _: f acc) s (range 0 n);

  grouped = l: n:
    if (length l <= n) then [l] else [(take n l)] ++ (grouped (drop n l) n);

in {
  inherit sum product indexOf startsWith lines updateList repeat grouped;
}