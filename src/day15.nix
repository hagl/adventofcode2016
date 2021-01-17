with (import <nixpkgs/lib>);
with (import ./utils.nix);

let 
  parseSetup = line:
    let matches = map toInt (builtins.match "Disc #([0-9])+ has ([0-9]+) positions; at time=0, it is at position ([0-9]+)." line);
    in { n = elemAt matches 0; p = elemAt matches 1; s = elemAt matches 2;};

  step = { m, c }: {n, p, s}:
    let
      newC = c + m * findFirst (i: mod (i*m + c + s + n) p == 0) null (range 0 (p - 1));
    in { m = m * p; c = newC; };

  solve = file:
    let
      setup = map parseSetup (lines (readFile file));
    in
      foldl' step { m = 1; c = 0; } setup;

  solve2 = file:
    let
      setup = map parseSetup (lines (readFile file));
      newSetup = setup ++ [ {n = (length setup + 1); p = 11; s = 0;}];
    in
      foldl' step { m = 1; c = 0; } newSetup; 

in
  {
    solutionEx = solve ./day15ex.txt;
    solution = solve ./day15.txt;
    solution2 = solve2 ./day15.txt;
  }
