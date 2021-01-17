with (import <nixpkgs/lib>); 
with (import ./utils.nix); 

let 
  isVault = {x, y, ...}: x == 4 && y == 4;

  dirs = [ {n = "U"; x = 0; y = -1;} {n = "D"; x = 0; y = 1;} {n = "L"; x = -1; y = 0;} {n = "R"; x = 1; y = 0;} ];

  step = pos: 
    let 
      hash =
           take 4 (stringToCharacters (builtins.hashString "md5" pos.p));
      move = {fst, snd}: 
        let 
          nx = pos.x + fst.x;
          ny = pos.y + fst.y;
        in
          if nx < 1 || nx > 4 || ny < 1 || ny > 4 || snd < "b" then [] else [ { x= nx; y=ny; p=pos.p + fst.n;}];
    in
      if isVault pos then [] else concatLists (map move (zipLists dirs hash));

  run = positions:
    if positions == [] then (-1)
    else if any isVault positions then findFirst isVault null positions 
    else run (concatLists (map step positions));

  run2 = positions: acc:
    if positions == [] then acc
    else run2 (concatLists (map step positions)) ((findFirst isVault acc positions));

  solve = str:
    let result = run [{x=1; y=1; p=str;}];
    in if isAttrs result then substring (stringLength str) (-1) result.p else result;

  solve2 = str:
    let result = run2 [{x=1; y=1; p=str;}] null;
    in (stringLength result.p) - (stringLength str);

  input = "pslxynzg";
in 
  {
    solutionEx = solve "hijkl";
    solution = solve input;
    solution2 = solve2 input;
    solution2Ex1 = solve2 "ihgpwlah";
    solution2Ex2 = solve2 "kglvqrro";
    solution2Ex3 = solve2 "ulqzkmiv";
  }
