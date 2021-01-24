with (import <nixpkgs/lib>); 
with (import ./utils.nix); 
with (import ./utils2d.nix); 

let 
  neighbors = {x, y}:
    [{x=x - 1; y=y;} {x=x + 1; y=y;} {x=x; y=y - 1;} {x=x; y=y + 1;}];

  update = grid: nbs: n: acc: 
    let 
      go = acc@{g, a, ps}: p: 
        let v = elemAt (elemAt g p.y) p.x;
        in
          if v == "#" then acc
          else if v == "." then {
            g= updatePos g p.x p.y "#";
            a=a;
            ps = [p] ++ ps;
          }
          else let 
            num = toInt v;
          in {
            g= updatePos g p.x p.y "#";
            a= updateRow a num n;
            ps = [p] ++ ps;
          };
    in foldl' go {g = grid; a=acc; ps=[];} nbs;

  step = acc@{g, a, ps}: n:
    if ps == [] then acc
    else let
      nbs = unique (concatLists (map neighbors ps));
    in deepSeq (nbs) (update g nbs n a);

  findDistances = grid: count: start: j:
    let
      a = genList (x: 0) count;
      g = updatePos grid start.x start.y "#";
      acc = {inherit g a; ps=[ start ];};
    in
      (foldl' step acc (range 1 10000)).a;

  solve = file: maxNum:
    let
      count = maxNum + 1;
      grid = map stringToCharacters (lines (readFile file));
      posLineOf = l: j: findFirst (x: x > -1) (-1) (zipListsWith (v: ix: if v == j then ix else -1) l (range 0 (length l)));
      posOf = grid: j: findFirst (p: p != -1) (-1) (zipListsWith (v: ix: let x = posLineOf v j; in if x == -1 then -1 else {y = ix; x=x;}) grid (range 0 (length grid)));
      positions = map (posOf grid) (map toString (range 0 maxNum));
      distances = map (j: findDistances grid count (elemAt positions j)  j) (range 0 maxNum);
      perms = permutations (range 1 maxNum);
      result = minimum 99999 (map (cost distances) perms);
      result2 = minimum 99999 (map (cost2 distances) perms);
    in
      {
        inherit positions distances result result2;
        # test = findDistances grid count (elemAt positions maxNum)  count;
      };

  cost = distances: perm:
    let go = ds: acc: ps:
      if ps == [] then acc
      else let h = head ps;
      in go (elemAt distances h) (acc + (elemAt ds h)) (tail ps);
    in go (head distances) 0 perm;

  cost2 = distances: perm:
    (cost distances perm) + (head (elemAt distances (last perm)));

in 
  {
    solutionEx = solve ./day24ex.txt 4;
    solution = solve ./day24.txt 7;
  }
