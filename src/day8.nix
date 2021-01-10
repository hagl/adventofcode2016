with (import <nixpkgs/lib>); 
with (import ./utils.nix); 
with (import ./utils2d.nix); 
let 
  step = arr: instr: 
    let 
      rectI = builtins.match "rect ([0-9]+)x([0-9]+)" instr;
      rotR = builtins.match "rotate row y=([0-9]+) by ([0-9]+)" instr;
      rotC = builtins.match "rotate column x=([0-9]+) by ([0-9]+)" instr;
    in
     if (isList rectI) then 
        rect arr (toInt (elemAt rectI 0)) (toInt (elemAt rectI 1))
      else if (isList rotR) then
        let
          y = toInt(elemAt rotR 0);
          d = toInt(elemAt rotR 1);
          row = getRow arr y;
          rotated = rotate row d;
        in updateRow arr y rotated
      else if (isList rotC) then
        let
          x = toInt (elemAt rotC 0);
          d = toInt (elemAt rotC 1);
          col = getColumn arr x;
          rotated = rotate col d;
        in updateColumn arr x rotated
      else 
        builtins.trace (instruction) null;

  solve = file: x: y:
    let
      instructions = lines (readFile file);
      start = createArray x y;
      end = foldl' step start instructions;
    in
      builtins.trace (concatStrings ["\n" (printArray end)])
        length (filter (v: v == 1) (concatLists end));

in 
  {
    solutionEx = solve ./day8ex.txt 7 3;
    solution = solve ./day8.txt 50 6;
  }

