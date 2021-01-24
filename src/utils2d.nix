let lib = (import <nixpkgs/lib>); 
in with lib;
let
  createArray = x: y: 
    genList (_: genList (_: 0) x) y;

  getColumn = arr: x:
    map (row: elemAt row x) arr;

  updateColumn = arr: x: col:
    zipListsWith (row: val: (take x row) ++ [val] ++ (drop (x + 1) row)) arr col;

  getRow = arr: y:
    elemAt arr y;

  updateRow = arr: y: row:
    (take y arr) ++ [row] ++ (drop (y + 1) arr);

  updatePos = arr: x: y: v:
    updateRow arr y (updateRow (getRow arr y) x v);

  printLine = row:
    concatStrings ((map (p: if p == 0 then "." else if p == -1 then "#" else ( toString p)) row) ++ ["\n"]);

  printArray = arr:
    concatStrings (map printLine arr);
    # concatStrings (map (row: (concatStrings (map (p: if p == 0 then " " else "X") row ++ ["\n"]) arr);

  rotate = arr: d:
    let
      l = length arr;
      d' = l - d;
    in (drop d' arr) ++ (take d' arr);

  rect = arr: dx: dy:
    let 
      rectRow = row: 
        (genList (_: 1) dx) ++ (drop dx row);
    in (map rectRow (take dy arr)) ++ (drop dy arr);

in {
  inherit updatePos createArray getColumn updateColumn getRow updateRow printLine printArray rotate rect;
}