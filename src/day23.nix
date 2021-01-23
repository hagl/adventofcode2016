with (import <nixpkgs/lib>); 
with (import ./utils.nix); 
let 

  registers = [ "a" "b" "c" "d"];

  incInstruction = r:
    {
      t = "inc";
      arg0 = r;
      ex = s: s // { ${r} = (s.${r} + 1); ip = s.ip + 1; };
    };

  decInstruction = r: 
   {
      t = "dec";
      arg0 = r;
      ex = s: s // { ${r} = (s.${r} - 1); ip = s.ip + 1; };
    };

  copyInstruction = valOrReg: r: 
    {
      t = "cpy";
      arg0 = valOrReg;
      arg1 = r;
      ex = if elem r registers
        then     
          if elem valOrReg registers 
          then (s: s // { ${r} = s.${valOrReg}; ip = s.ip + 1; })
          else (s: s // { ${r} = toInt valOrReg; ip = s.ip + 1; })
        else (s: s // { ip = s.ip + 1;});
    };

  jnzInstruction = vr0: vr1:
    {
      t = "jnz";
      arg0 = vr0;
      arg1 = vr1;
      ex = if elem vr0 registers 
        then
          if elem vr1 registers 
            then (s: s // { ip =  s.ip + (if s.${vr0} == 0 then 1 else s.${vr1}); })
            else let d = toInt vr1; in (s: s // { ip =  s.ip + (if s.${vr0} == 0 then 1 else d); })
        else
           if elem vr1 registers 
            then (s: s // { ip =  s.ip + (if vr0 == "0" then 1 else s.${vr1}); })
            else let d = toInt vr1; in (s: s // { ip =  s.ip + (if vr0 == "0" then 1 else d); });
    };

  tglInstruction = valOrReg:
    {
      t = "tgl";
      arg0 = valOrReg;
      ex = if elem valOrReg registers 
        then (s: s // { ins = toggleInstruction s.ins (s.ip + s.${valOrReg}) s; ip = s.ip + 1;})
        else (s: s // { ins = toggleInstruction s.ins (s.ip + valOrReg) s; ip = s.ip + 1;});
    };

  toggleInstruction = instructions: pos: s:
    builtins.trace ("tgl ${toString pos}") builtins.trace (printState s) (
    if (pos >= 0 && pos < length instructions) then
      let
        instr = elemAt instructions pos;
        newInstr = toggle instr;
      in
        (take pos instructions) ++ [newInstr] ++ (drop (pos + 1) instructions)
    else instructions);

  toggle = ins:
    if (ins.t == "inc") then decInstruction ins.arg0
    else if  (ins.t == "dec") then incInstruction ins.arg0
    else if  (ins.t == "tgl") then incInstruction ins.arg0
    else if (ins.t == "cpy") then jnzInstruction ins.arg0 ins.arg1
    else if (ins.t == "jnz") then copyInstruction ins.arg0 ins.arg1
    else throw "unknown instruction ${ins}";

  parseInstruction = instr: 
    let 
      incIns = builtins.match "inc ([a-d])" instr;
      decIns = builtins.match "dec ([a-d])" instr;
      cpyIns = builtins.match "cpy ([a-d]|[-0-9]+) ([a-d])" instr;
      jnzIns = builtins.match "jnz ([a-d]|[-0-9]+) ([a-d]|[-0-9]+)" instr;
      tglIns = builtins.match "tgl ([a-d]|[-0-9]+)" instr;
    in
     if (isList incIns) then incInstruction (elemAt incIns 0)
      else if (isList decIns) then decInstruction (elemAt decIns 0)
      else if (isList cpyIns) then copyInstruction (elemAt cpyIns 0) (elemAt cpyIns 1)
      else if (isList jnzIns) then jnzInstruction (elemAt jnzIns 0) (elemAt jnzIns 1)
      else if (isList tglIns) then tglInstruction (elemAt tglIns 0)
      else 
        throw "unknown instruction ${instr}";

    printState = s: 
      "a=${toString s.a} b=${toString s.b} c=${toString s.c} d=${toString s.c} ip=${toString s.ip}";

    printIns = instructions:
      let 
        print = ins: "${ins.t} ${toString ins.arg0} ${if hasAttr "arg1" ins then toString ins.arg1 else ""}";
        result = map print instructions;
      in deepSeq result result;

    run = instructions: initial: 
     let 
      go = s:
        if (s.ip >= length instructions) then s else 
        let 
          # instr = builtins.trace (printState s) builtins.trace (printIns s.ins) (elemAt s.ins s.ip);
          instr = elemAt s.ins s.ip;
          newS = instr.ex s;
        in deepSeq newS newS;
    # in (repeat 10000 (repeat 10000 go) initial);
    in (repeat 100 (repeat 10000 go) (initial // {ins = instructions;}));

  solve = file: initial:
    let
      instructions= map parseInstruction (lines (readFile file));
    in
      run instructions initial;
 
    state = { a = 0; b = 0; c = 0; d = 0; ip = 0;};

  # manually disassembling the program yielded the following formula for inputs >= 4:
  solve2 = input:
     product (range 1 input) + 89 * 77;

in  {
    solutionEx2 = solve ./day12ex.txt state;
    solutionEx = solve ./day23ex.txt state;
    solution = solve ./day23.txt (state // {a=7;});
    solution2 = solve2 12;
  }
