with (import <nixpkgs/lib>); 
let 
  str = readFile ./day1.txt;
  list = splitString ", " str;

  abs = x: if x < 0 then (-x) else x;

  turn = pos: c: with pos;
    if c == "L" then pos // { dx = dy; dy = - dx; } else pos // { dx = - dy; dy = dx; };

  move = pos: list: 
    if list == [] then pos // { d = (abs pos.x) + (abs pos.y);} else 
      let 
        m = head list;
        c = substring 0 1 m;
        d = toInt (substring 1 (-1) m);
        turned = turn pos c;
      in with turned; move (turned // { x = (x + d * dx); y = (y + d * dy);}) (tail list);

  step = c: pos: list: cache:
    if c == 0 then move2 pos list cache else
      with pos;
      let 
        nx = x + dx;
        ny = y + dy;
        newPos = pos // {x = nx; y = ny;};
        cacheEl = [nx ny];
      in
         if any (c: c == cacheEl) cache then newPos // { d = (abs nx) + (abs ny);} else
          step (c - 1) newPos list ([cacheEl] ++ cache);

  move2 = pos: list: cache:
    let
      m = head list;
      c = substring 0 1 m;
      d = toInt (substring 1 (-1) m);
      newPos = turn pos c;
    in 
      step d newPos (tail list) cache;

  start = {x =0; y= 0; dx= 0; dy =(- 1);};
in 
  {
    dist = move start list;
    dist2 = move2 start list [];
  }

