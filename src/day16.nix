with (import <nixpkgs/lib>); 
with (import ./utils.nix); 

let 
  generate = input: len:
    if length input > len then input else generate (input ++ [ 0 ] ++ (map (n: 1 - n) (reverseList input))) len;

  checksum = input:
    if (mod (length input) 2 == 1) then input else checksum (map (l: if elemAt l 0 == elemAt l 1 then 1 else 0) (grouped input 2));

  solve = str: len:
    let
      chars = map toInt (stringToCharacters str);
      data = take len (generate chars len);
      check = concatStrings (map toString (checksum data));
    in
      check;

  # Part 2
  # the naive solution of creating the data and then calculating the checksum is too slow
  # as an optimization I try to calculate the checksum directly by observing
  # if len = (2^n) * m when m is not divisible by 2 then the checksum's lenght is m and each block of (2^n) digits
  # contributes to 1 digit in the checksum. This is calculated recursivly in checksum2 in O(log len)
  # In order to avoid creating the data in memory the function digitAt calculates a digit at a position in O(log len), it
  # uses the splits list of the points where the data was mirrored.

  solve2 = str: len:
    let
      chars = map toInt (stringToCharacters str);
      data = take len (generate chars len);
      splits = (findSplits (stringLength str) len);
      pow2div = findFirst (n: mod len n != 0) 0  (map (n: product (genList (_: 2) n)) (range 1 32)) / 2;
      limit = len / pow2div;
      check = map (n: builtins.trace(n) (checksum2 (digitAt chars splits) (pow2div * n) (pow2div / 2))) (range 0 (limit - 1));
    in
      concatStrings (map toString (check));

  checksum2 = f: start: blockSize:
    let
      a = if blockSize == 1 then (f start) else checksum2 f start (blockSize / 2);
      b = if blockSize == 1 then (f (start + 1)) else checksum2 f (start + blockSize) (blockSize / 2);
    in if a == b then 1 else 0;

  findSplits = s: limit: 
    let
      go = c: l:
        if c >= limit then l else go (2 * c + 1) ([ (c) ] ++ l);
    in go s [];

  digitAt = input: splits: n:
    if splits == [] then elemAt input n 
    else 
      let split = head splits;
      in
        if n == split then 0
        else if n < split then digitAt input (tail splits) n
        else 1 - (digitAt input (tail splits) (2 * split - n));

  input = "01000100010010111";

in 
  {
    solution = solve input 272;
    test = solve2 input 272;
    solution2 = solve2 input 35651584;
  }
