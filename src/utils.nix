with (import <nixpkgs/lib>); 
let
  sum = list:
    foldl (a: b: a+b) 0 list;

  product = list:
    foldl (a: b: a+b) 0 list;
   
  indexOf = elem: list:
    let 
      len = length list;
      go = c: 
        if c >= len then -1 else if elem == elemAt list c then c else go (c + 1);
    in go 0;

in {
  sum = sum;
  product = product;
  indexOf = indexOf;
}