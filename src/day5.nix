with (import <nixpkgs/lib>); 
let 
  utils = import ./utils.nix;

  blockSize = 1000000;

  solve = str:
    let
      find = ix: acc:
        if stringLength acc >= 8 then substring 0 8 acc else let
          result = filter (s: substring 0 5 s == "00000") (map (i: "${builtins.hashString "md5" "${str}${toString i}"}:${toString i}") (range ix (ix + blockSize)));
          chars = concatStrings (map (s: substring 5 1 s) result);
        in find (ix + blockSize) "${acc}${chars}";
    in find 0 "";

  solve2 = str:
    let
      addHash = acc: s:
        let 
          ix = substring 5 1 s;
          v = substring 6 1 s;
        in if "0" <= ix && ix < "8" && !builtins.hasAttr ix acc then acc // { ${ix} = v;} else acc;
      find = ix: acc:
        
        if length (attrNames acc) >= 8 then acc else let
          result = filter (s: substring 0 5 s == "00000") (map (i: "${builtins.hashString "md5" "${str}${toString i}"}:${toString i}") (range ix (ix + blockSize)));
          newAcc = foldl addHash acc result;
        in find (ix + blockSize) newAcc;
      codes = find 0 {};
    in concatStrings (attrValues codes); # attrValues are sorted by keys


in  
  {
    solution = solve "reyedfim";
    solutionEx = solve "abc";
    solution2 = solve2 "reyedfim";
    solution2Ex = solve2 "abc";
  }

