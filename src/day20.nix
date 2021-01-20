with (import <nixpkgs/lib>);
with (import ./utils.nix);

let
  parse = line: 
    let matches = builtins.match "^([0-9]+)-([0-9]+)$" line;
  in {
    from = toInt (elemAt matches 0);
    to = toInt (elemAt matches 1);
  };

  maximum = default: list: 
    foldl' max default list;

  minimum = default: list: 
    foldl' min default list;

  findMinimal = rules: n:
    let
      matchingRules = filter (r: r.from <= n && n <= r.to) rules;
      remainingRules = filter (r: r.from > n) rules;
      newN = 1 + (maximum (-2) (map (r: r.to) matchingRules));
    in if (matchingRules == []) then n else findMinimal remainingRules newN; 

  countIPs = rules: n: acc:
    if (n > 4294967295) then acc else
    let
      matchingRules = filter (r: r.from <= n && n <= r.to) rules;
      remainingRules = filter (r: r.from > n) rules;
      newN = 1 + (maximum (-2) (map (r: r.to) matchingRules));
      nextBlocked = minimum 4294967296 (map (r: r.from) remainingRules);
    in 
      if (matchingRules != []) then countIPs remainingRules newN acc
      else countIPs remainingRules nextBlocked (acc + (nextBlocked - n));


  solve = file:
    let
      rules = map parse (lines (readFile file));
    in {
      minIp = findMinimal rules 0;
      count = countIPs rules 0 0;
    };
in
  {
    solutionEx = solve ./day20ex.txt;
    solution = solve ./day20.txt;
  }
