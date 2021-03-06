proc make_whole {mol sel frame num chn} { 
	molinfo $mol set frame $frame
	$sel frame $frame
	set allcoord [$sel get {x y z}]
	set num1 [expr {$num - 1}]
	set boxhalf [vecscale 0.5 [molinfo $mol get {a b c}]] ;#box dimension half;
	set newcoord {}
	set firstlen [expr $num*$chn]
	set lastcoord [lrange $allcoord $firstlen end]
	puts " [format "%8d" $frame]: length of lastcoord: [llength $lastcoord]"
	set allcoord [lrange $allcoord 0 [expr $firstlen-1]]
	while {[llength $allcoord] > 0} { ;# every num coor;
		set coord [lrange $allcoord 0 $num1] ;# [0,num-1] coors;
		set allcoord [lrange $allcoord $num end] ;# [num, end] coors for the next round;
		set ref [lindex $coord 0] ;#current ref. virtually 1st atom coor.
		lappend newcoord $ref 
		foreach atom [lrange $coord 1 end] {
			set newatom {} 
			set dist [vecsub $atom $ref]
			foreach d $dist b $boxhalf r $atom {
				if {$d < -$b} { set r [expr {$r + 2.0*$b}]}
				if {$d > $b} { set r [expr {$r - 2.0*$b}]} 
				lappend newatom $r 
			}
			lappend newcoord $newatom 
		}
	}
	#set ref [lindex $lastcoord 0] ;#current ref. virtually 1st atom coor.
	#lappend newcoord $ref 
	#foreach atom [lrange $lastcoord 1 end] {
	#	set newatom {} 
	#	set dist [vecsub $atom $ref]
	#	foreach d $dist b $boxhalf r $atom {
	#		if {$d < -$b} { set r [expr {$r + 2.0*$b}]}
	#		if {$d > $b} { set r [expr {$r - 2.0*$b}]} 
	#		lappend newatom $r 
	#	}
	#	lappend newcoord $newatom 
	#}
	foreach atom [lrange $lastcoord 1 end] {
		lappend newcoord $atom 
	}
	lappend newcoord $newatom 
	$sel set {x y z} $newcoord
}

set mol [molinfo top] 
set ring [atomselect $mol {all}] 
set nf [molinfo $mol get numframes] 
for {set i 0} {$i < $nf} {incr i} {
	make_whole $mol $ring $i 64 64;#if 100, the total number has to be 100N;
}
