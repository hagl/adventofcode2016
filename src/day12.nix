with (import <nixpkgs/lib>); 
with (import ./utils.nix); 

let 
  registers = [ "a" "b" "c" "d"];
  parseInstruction = instr: 
    let 
      incIns = builtins.match "inc ([a-d])" instr;
      decIns = builtins.match "dec ([a-d])" instr;
      cpyIns = builtins.match "cpy ([a-d]|[-0-9]+) ([a-d])" instr;
      jnzIns = builtins.match "jnz ([a-d]|[-0-9]+) ([-0-9]+)" instr;
    in
     if (isList incIns) then
        let
          r = elemAt incIns 0;
        in (s: s // { ${r} = (s.${r} + 1); ip = s.ip + 1; })
      else if (isList decIns) then
        let
          r = elemAt decIns 0;
        in (s: s // { ${r} = (s.${r} - 1); ip = s.ip + 1; })
      else if (isList cpyIns) then
        let
          r = elemAt cpyIns 1;
          valOrReg = elemAt cpyIns 0;
        in if elem valOrReg registers 
          then (s: s // { ${r} = s.${valOrReg}; ip = s.ip + 1; })
          else (s: s // { ${r} = toInt valOrReg; ip = s.ip + 1; })
      else if (isList jnzIns) then
        let
          valOrReg = elemAt jnzIns 0;
          d = toInt (elemAt jnzIns 1);
        in if elem valOrReg registers 
          then (s: s // { ip =  s.ip + (if s.${valOrReg} == 0 then 1 else d); })
          else (s: s // { ip =  s.ip + (if valOrReg == "0" then 1 else d); })
      else 
        throw "unknown instruction ${instr}";

  run = instructions: initial: 
     let 
      go = s:
        if (s.ip >= length instructions) then s else
        let 
          instr = elemAt instructions s.ip;
          newS = instr s;
        in deepSeq newS newS;
    in (repeat 10000 (repeat 10000 go) initial);

  # recursion will cause a stack overflow
  run2 = instructions: initial: 
    let 
      go = s: n:
          if (s.ip >= length instructions) then s else
          let 
            instr = elemAt instructions s.ip;
            newS = instr s;
          in go (deepSeq newS newS) (n + 1);
    in go initial 0 ;

  solve = file: initial:
    let
      instructions = map parseInstruction (lines (readFile file));
    in
      run instructions initial;

  state = { a = 0; b = 0; c = 0; d = 0; ip = 0;};
  state2 = { a = 0; b = 0; c = 1; d = 0; ip = 0;};

in 
  {
    solutionEx = solve ./day12ex.txt state;
    solution = solve ./day12.txt state;
    solution2 = solve ./day12.txt state2;
  }

