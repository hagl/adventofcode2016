with (import <nixpkgs/lib>); 
with (import ./utils.nix); 
with (import ./utils2d.nix); 
let 
  utils = import ./utils.nix;

  read = acc: instr: 
    let 
      valIns = builtins.match "value ([0-9]+) goes to (bot [0-9]+)" instr;
      botIns= builtins.match "(bot [0-9]+) gives low to (bot [0-9]+|output [0-9]+) and high to (bot [0-9]+|output [0-9]+)" instr;
    in
     if (isList valIns) then
        let
          v = toInt(elemAt valIns 0);
          t = elemAt valIns 1;
        in addVal t v acc
      else if (isList botIns) then
        let
          t = elemAt botIns 0;
          toLow = elemAt botIns 1;
          toHigh = elemAt botIns 2;
          prev = if acc ? ${t} then acc.${t} else { l = [];};
          new = prev // { rule = [toLow toHigh]; };
        in acc // { ${t} = new;}
      else 
        # acc;
        builtins.trace (instruction) null;

  addVal = t: v: acc: 
    let
      prev = if acc ? ${t} then acc.${t} else { l = [];};
      new = prev // { l = sort (a: b: a < b) (prev.l ++ [ v ]); };
    in acc // {${t} = new;};


  simplify = acc: list:
    if (builtins.trace (list) list == []) then acc else 
      let
        name = head list;
        bot = acc.${name};
        # sorted = builtins.trace (bot.rule) sort (a: b: a < b) bot.l;
        sorted = sort (a: b: a < b) bot.l;
        low = elemAt sorted 0;
        high = elemAt sorted 1;
        tLow = elemAt bot.rule 0;
        tHigh = elemAt bot.rule 1;
        acc' = addVal tLow low acc;
        acc'' = addVal tHigh high acc';
      in simplify acc'' ((tail list) ++ (filter (n: builtins.trace(n) builtins.trace( acc''.${n}.l) length acc''.${n}.l == 2) bot.rule));

  solve = file:
    let
      instructions = lines (readFile file);
      parsed = foldl' read {} instructions;
      initial = filter (n: length parsed.${n}.l == 2) (builtins.attrNames parsed);
      simplified = simplify parsed initial;
    in
      builtins.trace("***") builtins.trace (head (tail parsed."bot 13".rule)) builtins.trace("***") 
        findFirst (n: simplified.${n}.l == [17 61]) 0 (builtins.attrNames simplified);

  solve2 = file:
    let
      instructions = lines (readFile file);
      parsed = foldl' read {} instructions;
      initial = filter (n: length parsed.${n}.l == 2) (builtins.attrNames parsed);
      simplified = simplify parsed initial;
    in
      utils.product (map head (map (n: simplified.${n}.l) ["output 0" "output 1" "output 2"]));

in 
  {
    solution = solve ./day10.txt;
    solution2 = solve2 ./day10.txt;
  }

