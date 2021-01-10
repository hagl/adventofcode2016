with (import <nixpkgs/lib>); 

let
    solve = file: first:
     let
      decode = str: acc:
        let 
          result = builtins.match "([A-Z]*)\\(([0-9]*)x([0-9]*)\\)(.*)" str;
        in 
          if (isList result) then let
            prefix = elemAt result 0;
            c = toInt(elemAt result 1);
            r = toInt(elemAt result 2);
            rest = elemAt result 3;
            sub = substring 0 c rest;
            next = substring c (-1) rest;
            in if first 
                then decode next (acc + (stringLength prefix) + r * c)
                else decode next (acc + (stringLength prefix) + r * (decode sub 0))
          else acc + (stringLength str);
      compressed = readFile file;
    in
      decode compressed 0;

in 
  {
    solution = solve ./day9.txt true;
    solution2 = solve ./day9.txt false;
  }

