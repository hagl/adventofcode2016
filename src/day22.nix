with (import <nixpkgs/lib>); 
with (import ./utils.nix); 

let 
  parse = line:  
    let 
      #         Filesystem              Size  Used  Avail  Use%
      #  /dev/grid/node-x31-y25   87T   64T    23T   73%
      matches = map toInt (builtins.match "/dev/grid/node-x([0-9]+)-y([0-9]+) +([0-9]+)T +([0-9]+)T +([0-9]+)T +([0-9]+)%" line);
    in
      {
        x = elemAt matches 0;
        y = elemAt matches 1;
        size = elemAt matches 2;
        used = elemAt matches 3;
        avail = elemAt matches 4;
        useP = elemAt matches 5;
      };

  countWhile = p: list:
    let go = acc: l:
          if (l == []) then {acc=acc; rest = [];} 
          else if (p (head l)) then deepSeq (acc) (go (acc + 1) (tail l))
          else { inherit acc; rest=l;};
    in go 0 list;

  countViablePairs = list:
    let
      used = sort (a: b: b < a) (filter (u: u > 0) (map (n: n.used) list));
      avail = sort (a: b: b < a) (map (n: n.avail) list);
      go = sc: as: acc: l:
        if l == [] then acc else
        let 
          h = head l;
          cw = countWhile (c: c > h) as;
          nSc = deepSeq cw (sc + cw.acc);
        in 
          go nSc cw.rest (acc + nSc) (tail l);
    in go 0 avail 0 used;

  solve = file:
    let
      specs = map parse (drop 2 ((lines (readFile file))));
    in
      countViablePairs specs;
 
  printGrid = specs: width: maxFree:
    let
      sorted = sort (p: q: p.y < q.y || (p.y == q.y && p.x < q.x)) specs;
      chars = map (p: if p.avail == maxFree then "_" else if p.used > maxFree then "#" else ".") sorted;
      group = grouped chars width;
      print = map (p: builtins.trace(p) p) (zipListsWith (fst: snd: (if fst < 10 then " " else "") + (toString fst) + " " + snd) (range 0 100) (map (concatStrings) group));
    in deepSeq (print) 0;

  solve2 = file:
    let
      specs = map parse (drop 2 ((lines (readFile file))));
      width = (1+ foldl' max 0 (map (p: p.x) specs));
      maxFree = maximum 0 (map (p: p.avail) specs);
    # trace:  0 ................................
    # trace:  1 ................................
    # trace:  2 ................................
    # trace:  3 ................................
    # trace:  4 ................................
    # trace:  5 ................................
    # trace:  6 ................................
    # trace:  7 ................................
    # trace:  8 ................................
    # trace:  9 ................................
    # trace: 10 ................................
    # trace: 11 ................................
    # trace: 12 .........#######################
    # trace: 13 ................................
    # trace: 14 ................................
    # trace: 15 ................................
    # trace: 16 ................................
    # trace: 17 ................................
    # trace: 18 ................................
    # trace: 19 ................................
    # trace: 20 ................................
    # trace: 21 ................................
    # trace: 22 ........................_.......
    # trace: 23 ................................
    # trace: 24 ................................
    # trace: 25 ................................
    # trace: 26 ................................
    # trace: 27 ................................
      empty = deepSeq(printGrid specs width maxFree) (findFirst (p: p.avail > 73) null specs);
      maxX = width -1;
      blocks = minimum maxX (map (p: p.x) (filter (p: p.used > 86) specs));
      # bring empty field to the left to avoid the blocks
      stepsLeft = empty.x - (blocks - 1);
      # bring empty field to the top row
      stepsUp = empty.y;
      # bring empty field to the left of the goal
      stepsRight = (maxX - 1) - (blocks -1);
      # move goal to the left
      moveG = maxX - (maxX - 1);
      # do the 5 step procedure as in the example to bring G one step closer to (0,0)
      move_andG = 5 * (maxX -1);
    in
       stepsLeft + stepsUp + stepsRight + moveG + move_andG;
in {
  solution = solve ./day22.txt;
  solution2 = solve2 ./day22.txt;
}
