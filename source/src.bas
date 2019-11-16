//
//		Test.
//

' the ball demo
clear
1024 alloc ^ballmem 
32 ^count 
142 ^A $FFD2 sys
count for index ball.select ball.init next

repeat
	count for index ball.select ball.move next
0 until
end

:ball.select << << << << ballmem + ^ball  ;
:ball.init rnd abs 80 mod ^ball[0] rnd abs 60 mod ^ball[1] 
			random.sign ^ball[2] random.sign ^ball[3] rnd 7 and ++ ^ball[4] 81 ball.draw ;
:random.sign rnd 1 and if 1 else 1- endif ;

:ball.draw 
	ball[0] << $9f20 c!
	ball[1] $9f21 c!
	$10 $9f22 c! $9f23 c! ball[4] $9f23 c! ;	
:ball.move 
	32 ball.draw
	ball[0] ball[2] + dup ^ball[0] 
	dup 80 >= swap 0 < or if ball[2] negate ^ball[2] endif
	ball[1] ball[3] + dup ^ball[1] 
	dup 60 >= swap 0 < or if ball[3] negate ^ball[3] endif
	81 ball.draw 
;

:clear 0 $9f20 ! $10 $9f22 c!
128 6ri	0 * for
	32 $9f23 c! 1 $9f23 c!
next ;
