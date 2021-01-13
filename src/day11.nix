with (import <nixpkgs/lib>); 
with (import ./utils.nix); 
let 
  utils = import ./utils.nix;

  start = { e=1; l=[ { g=1; m=1;} { g=1; m=1;} { g=2; m=2;} { g=2; m=2;} { g=2; m=3;} ]; };

  isSolution = {e, l}:
    e == 4 && all (p: p.g == 4 && p.m == 4) l;

  comparePairs = p1: p2: 
    p1.g < p2.g || p1.g==p2.g && p1.m < p2.m;

  nextOptions = pos:
    let
      downs = if (pos.e == 1) then [] else nextOptionsDir pos (- 1);
      ups = if (pos.e == 4) then [] else nextOptionsDir pos 1;
    in
       unique (map canonicalize (downs ++ ups));

  posToString = pos: let
    lString = concatStrings (map (p: "_${toString p.g}${toString p.m}") pos.l);
    in "${toString pos.e}${lString}";

  nextOptionsDir = pos: dir:
    let
      newE = pos.e + dir;
    # G
      oneG = i: let
        pi = elemAt pos.l i;
      in if pi.g == pos.e then [ (pos // {e = newE; l = utils.updateList pos.l i (pi // {g = newE;});})] else [];
      glist = concatLists (map oneG (range 0 4));
    # M
      oneM = i: let
        pi = elemAt pos.l i;
      in if pi.m == pos.e then [(pos // {e = newE; l = utils.updateList pos.l i (pi // {m = newE;});})] else [];
      mlist = concatLists (map oneM (range 0 4));
    # GM
      oneGM = i: let
        pi = elemAt pos.l i;
      in if pi.g == pos.e && pi.m == pos.e then [(pos // {e = newE; l = utils.updateList pos.l i ({g = newE; m = newE;});})] else [];
      gmlist = concatLists (map oneGM (range 0 4));
    # G,G
      oneGG = i: j: let
        pi = elemAt pos.l i;
        pj = elemAt pos.l j;
      in if pi.g == pos.e && pj.g == pos.e then [(pos // {e = newE; l = utils.updateList (utils.updateList pos.l i (pi // {g = newE;})) j (pj // {g = newE;});})] else [];
      gglist = concatLists (map (i: concatLists (map (oneGG i) (range (i + 1) 4))) (range 0 4));
    # M,M
      oneMM = i: j: let
        pi = elemAt pos.l i;
        pj = elemAt pos.l j;
      in if pi.m == pos.e && pj.m == pos.e then [(pos // {e = newE; l = utils.updateList (utils.updateList pos.l i (pi // {m = newE;})) j (pj // {m = newE;});})] else [];
      mmlist = concatLists (map (i: concatLists (map (oneMM i) (range (i + 1) 4))) (range 0 4));
    in glist ++ mlist ++ gmlist ++ gglist ++ mmlist;

  canonicalize = pos:
    pos // {l = sort comparePairs pos.l;};

  isValidFloor = pos: i: let
    hasSingleG = any (p: p.g == i && p.m != i) pos.l;
    hasSingleM = any (p: p.g != i && p.m == i) pos.l;
  in !(hasSingleG && hasSingleM);

  isValidPos = pos:
    all (isValidFloor pos) (range 1 4);

  step = visited: options: n:
    let
      newVisited = foldl' (c: p: c // {${posToString p} = true;}) visited options;
      next = unique (concatLists (map nextOptions options));
      filtered = filter (p: !visited ? ${posToString p}) next;
    in if any isSolution filtered then n + 1 else
      step newVisited filtered (n+1);
in 
  {
    # very slow but will find the solution
    solution = step {} [start] 0;
    # for each of the additional (4) items on floor 1 
    # go down (3 steps) with a helper item and bring it up (3 steps)
    solution2 = solution + (4 * 6);
  }

