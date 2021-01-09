with (import <nixpkgs/lib>); 
let 
  utils = import ./utils.nix;

  parseLine = line:
    let 
      result = builtins.match "^([a-z-]*)-([0-9]+)\\[(.*)]$" line;
  in {
    name = elemAt result 0;
    sector = toInt (elemAt result 1);
    checksum = elemAt result 2;
  };

  lines = str:
     filter (s: s != "") (map head (filter isList (builtins.split "([^\n]*)" str)));

  parseFile = file: 
    let
      str = readFile file;
      list = lines str;
      parsed = map parseLine list;
    in parsed;

  compare = s1: s2:
    (s1.count > s2.count) || (s1.count == s2.count && s1.char < s2.char);

  validChecksum = p: 
    let
      chars = filter (c: c != "-") (stringToCharacters p.name);
      grouped = groupBy id chars;
      countedChars = map (c: {char=c; count = (length (getAttr c grouped));}) (attrNames grouped);
      sorted = sort compare countedChars;
      check = concatStrings (map (s: s.char) (take 5 sorted));
    in 
      # builtins.trace ("${check} - ${p.checksum}")
      check == p.checksum;

  alphabet = stringToCharacters "abcdefghijklmnopqrstuvwxyz";

  decryptChar = sector: char:
    let
      ix = utils.indexOf char alphabet;
      newIndex = mod (sector + ix) 26;
    in 
      if ix == -1 then " " else elemAt alphabet newIndex;

  decrypt = p: 
    let 
      decrypted = concatStrings (map (decryptChar (p.sector)) (stringToCharacters p.name));
    in {
      decrypted = decrypted;
      sector = p.sector;
    };

  solve = file: 
    let
      parsed = parseFile file;
      filtered = filter validChecksum parsed;
      sectors = map (p: p.sector) filtered;
    in
      utils.sum sectors;

  solve2 = file:
    let
      parsed = parseFile file;
      filtered = filter validChecksum parsed;
      decrypted = map decrypt filtered;
    in
      findFirst (p: p.decrypted == "northpole object storage") "" decrypted;

in 
  {
    solution = solve ./day4.txt;
    solution2 = solve2 ./day4.txt;
  }

