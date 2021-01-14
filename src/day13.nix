with (import <nixpkgs/lib>); 
with (import ./utils.nix); 
with (import ./utils2d.nix); 

let 
  max = 50;

  inArray = array: p: 
    let 
      m = length array;
    in 
      0 <= p.x && 0<= p.y && p.x < m && p.y < m;

  neighbors = {x, y}:
    [ {x=x + 1; y=y;} {x=x - 1; y=y;} {x=x; y=y + 1;} {x=x; y=y - 1;}];

  isEmpty = array: {x, y}:
    elemAt (elemAt array y) x == 0;

  update = n: array: {x, y}:
    let
      row = getRow array y;
      newRow = updateRow row x n;
      newArray = updateRow array y newRow;
    in newArray;

  step = {a, l}: n:
    let
      go = {a, l}: p:
        let 
          nps = filter (n: inArray a n && isEmpty a n) (neighbors p);
          newA = foldl' (update (n + 1)) a nps;
        in { a = newA; l = l ++ nps;};
      result = foldl' go {a=a; l=[];} l;
    in deepSeq (result) result;

  run = array: start: steps:
    foldl' step {a = array; l=[start];} (range 1 steps);

  valAt = fav: x: y: - (bitAnd 1 (sum (toBaseDigits 2 (x*x + 3*x + 2*x*y + y + y*y + fav))));

  solve = fav: target:
    let
      array = genList (y: genList (x: valAt fav x y) max) max;
      x = run array {x = 1; y = 1;} 100;
      result1 = (elemAt (elemAt x.a target.y) target.x) -1;
      result2 = length (filter (n: n > 0 && n <= 51) (concatLists x.a));
    in
      builtins.trace ("\n" + (printArray x.a)) 
        { task1 = result1; task2 = result2;};
  
in 
  {
    solutionEx = solve 10 {x=7; y=4;};
    solution = solve 1352 {x=31; y=39;};
  }

