with (import <nixpkgs/lib>);
with (import ./utils.nix);

let 
  step = { start, inc, end, first }:
    let
      newStart = if first then start else start + inc;
      newInc = inc * 2; 
      count = (end - start) / inc + (if first then 1 else 0);
      newFirst = mod count 2 == 0;
      newEnd = if newFirst then end - inc else end;
    in { start=newStart; inc = newInc; end= newEnd; first = newFirst;};


  run = acc:
    if acc.start == acc.end then acc else let
      newAcc = step acc;
    in run (deepSeq newAcc newAcc);

  solve = count:
    let
      initial = { start = 1; inc = 1; end = count; first=true;};
    in
      run initial;

  step2 = { start, inc, end, first }:
    let
      newStart = if first == 0 then start else if first == 1 then start + 2 * inc else start + inc;
      newInc = inc * 3; 
      count = (end - newStart) / inc + 1;
      newFirst = mod count 3;
      newEnd = if newFirst == 0 then end - 2 * inc  else if newFirst == 1 then end else end - inc;
    in { start = newStart; inc = newInc; end= newEnd; first = newFirst;};

  showArr = array: { start, inc, end, first }:
    let 
      count = (end - start) / inc;
      res =  sort (a: b: a<b) (map (n: elemAt array (start + n * inc - 1)) (range 0 count));
    in deepSeq res res;

  run2 = array: acc:
      (
        if acc.start == acc.end || acc.start + acc.inc == acc.end then acc else let
          newAcc = step2 acc;
        in
        deepSeq newAcc (run2 array newAcc));

  solve2 = count:
    let
      even = mod count 2 == 0;
      initial = { start = 1; inc = 1; end = count; first = 0;};
      array = (range (count / 2) count) ++ (range 1 (count / 2 - 1));
      result = run2 array (deepSeq initial initial);
      val = if (result.start == result.end) then result.start else 
                if (result.first == 0 || result.first == 2) then result.start else result.end;
    in
      elemAt array (val - 1);

in
  {
    solutionEx = solve 5;
    solution = solve 3001330;
    solution2Ex = solve2 5;
    solution2 = solve2 3001330;
  }
