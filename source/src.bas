//
//		Test.
//
4- 42 list
' this is a comment' "this is a string"
$6000 ^ballmem 
32 ^count 
142 ^A $FFD2 sys
count for index select ball.init next

repeat 
	count for index select ball.move next
	//? repeat 0 until
0 until

:select << << << << ballmem + ^ball  ;
:ball.init rnd abs 80 mod ^ball[0] rnd abs 60 mod ^ball[1] 
			rsgn ^ball[2] rsgn ^ball[3] rnd 7 and ++ ^ball[4] 81 ball.draw ;
:rsgn rnd 1 and if 1 else 1- endif ;
:ball.draw 
	ball[0] << $9f20 c!
	ball[1] $9f21 c!
	$10 $9f22 c! $9f23 c! ball[4] $9f23 c! ;	
:ball.move 
	32 ball.draw
	ball[0] ball[2] + dup ^ball[0] dup 80 >= swap 0 < or if ball[2] negate ^ball[2] endif
	ball[1] ball[3] + dup ^ball[1] dup 60 >= swap 0 < or if ball[3] negate ^ball[3] endif
	81 ball.draw 
;
