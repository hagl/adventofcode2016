with (import <nixpkgs/lib>); 
with (import ./utils.nix); 
with (import ./utils2d.nix); 
let 

  swapPosition = x: y:
    l: zipListsWith (c: i: if i == x then elemAt l y else if i == y then elemAt l x else c) l (range 0 (length l - 1));

  swapLetter = x: y:
    l: map (c: if c == x then y else if c == y then x else c) l;

  rotate = inverse: dir: c: l:
    let d = if ((dir == "left") == !inverse) then c else (length l) - c;
    in (drop d l) ++ (take d l);

  rotateL = c: l:
    let 
      find = cs: if (head cs == c) then 0 else 1 + find (tail cs);
      ix = find l;
    in rotate false "right" (mod (if ix > 3 then ix + 2 else ix + 1) (length l))l;

  rotateLInv = c: l:
    let
      go = s: let r = rotate false "left" 1 s; in if rotateL c r == l then r else go r;
    in go l;

  movePos = x: y: l:
    let 
      c = elemAt l x;
      newList = (take x l) ++ (drop (x + 1) l);
    in (take y newList) ++ [ c ] ++ (drop y newList);

  reversePos = x: y: l:
    (take x l) ++ (reverseList (sublist x ((y+1) - x) l)) ++ (drop (y + 1) l);


  parse = inverse: instr:  
    let 
      swapP = builtins.match "swap position ([0-9]+) with position ([0-9]+)" instr;
      swapL = builtins.match "swap letter ([a-z]) with letter ([a-z])" instr;
      rot = builtins.match "rotate (left|right) ([0-9]+) steps?" instr;
      rotL = builtins.match "rotate based on position of letter ([a-z])" instr;
      rev = builtins.match "reverse positions ([0-9]+) through ([0-9]+)" instr;
      move = builtins.match "move position ([0-9]+) to position ([0-9]+)" instr;
    in
     if (isList swapP) then 
      swapPosition (toInt (elemAt swapP 0)) (toInt (elemAt swapP 1))
    else if (isList swapL) then 
      swapLetter (elemAt swapL 0) (elemAt swapL 1)
    else if (isList rot) then 
      rotate inverse (elemAt rot 0) (toInt (elemAt rot 1))
    else if (isList rotL) then 
      if inverse then rotateLInv (elemAt rotL 0)
        else rotateL (elemAt rotL 0)
    else if (isList rev) then 
      reversePos (toInt (elemAt rev 0)) (toInt (elemAt rev 1))
    else if (isList move) then 
      if inverse then movePos (toInt (elemAt move 1)) (toInt (elemAt move 0))
      else movePos (toInt (elemAt move 0)) (toInt (elemAt move 1))
    else 
      builtins.trace (instr) instr;

  solve = file: start: inverse:
    let
      instructions' = map (parse inverse) (lines (readFile file));
      instructions = if inverse then reverseList instructions' else instructions';
    in
      # instructions;
      concatStrings (foldl' (acc: rule: builtins.trace (deepSeq acc acc) (rule acc)) (stringToCharacters start) instructions);
 
in  {
    solutionEx = solve ./day21ex.txt "abcde" false;
    solution = solve ./day21.txt "abcdefgh" false;
    solution2 = solve ./day21.txt "fbgdceah" true;

    test1 = swapPosition 4 0 (stringToCharacters "abcde");
    test2 = swapLetter "d" "b" (stringToCharacters "ebcda");
    test3 = rot "left" 1  (stringToCharacters "abcde");
    test3b = rot "right" 1  (stringToCharacters "abcde");
    test4 = reversePos 0 4 (stringToCharacters "edcba");
    test5 = rotateL "b" (stringToCharacters "abdec");
    test6 = movePos 1 4 (stringToCharacters "bcdea");

    check = solve ./day21.txt "aefgbcdh" true;
  }
