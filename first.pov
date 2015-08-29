#include "colors.inc"
#include "stones.inc"
#include "textures.inc"
#include "shapes.inc"
#include "glass.inc"
#include "metals.inc"
#include "woods.inc"
#include "colors.inc"
camera{ location <4.5, 12, 3.5>
look_at <4.5, 0, 4.5>
}
light_source { <9, 50, 9>
color White

}
light_source { <4.5, 50, 4.5>
color White
spotlight
radius 11
falloff 20
tightness 10
point_at <4.5, 0, 4.5>
}
background { color Cyan }
plane{y,-0.5 pigment { Jade }}
	box{<-2,-0.5,-2>,
	    <9+1,0,9+1>
		texture { T_Wood10 } 
	}
#declare boardx=9;
#declare boardy=9;
#declare vline=box{<0,0,0><0.05, 0.05,boardx-1> pigment {color Black}}
#declare hline=box{<0,0,0><0.05, 0.05, boardy-1> pigment {color Black} rotate <0,90,0>}
#declare index=0;
#while (index<boardx)
	      object{vline translate <index,0,0>}
	      
#declare index= index+1;
#end
	      
#declare index=0;
#while (index<boardy)
	      
	      object{hline translate <0,0,index>}
#declare index= index+1;
#end

	      //at the moment dots are set only if board is 19x19.
#if (boardx = boardy)
#if (boardx=19)
#declare sdot=sphere{<0,0,0>0.15 pigment {color Black}}
	      object {sdot translate <3,0,3>}
	      object {sdot translate <15,0,15>}
	      object {sdot translate <3,0,15>}
	      object {sdot translate <9,0,9>}
	      object {sdot translate <9,0,3>}
	      object {sdot translate <3,0,9>}
	      object {sdot translate <15,0,3>}
	      object {sdot translate <15,0,9>}
	      object {sdot translate <9,0,15>}
#end
#end

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "A" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <1-1.1, 0+0.025, 9.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "A" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <1-1.1, 0+0.025, -0.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "B" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <2-1.1, 0+0.025, 9.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "B" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <2-1.1, 0+0.025, -0.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "C" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <3-1.1, 0+0.025, 9.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "C" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <3-1.1, 0+0.025, -0.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "D" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <4-1.1, 0+0.025, 9.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "D" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <4-1.1, 0+0.025, -0.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "E" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <5-1.1, 0+0.025, 9.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "E" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <5-1.1, 0+0.025, -0.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "F" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <6-1.1, 0+0.025, 9.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "F" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <6-1.1, 0+0.025, -0.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "G" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <7-1.1, 0+0.025, 9.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "G" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <7-1.1, 0+0.025, -0.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "H" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <8-1.1, 0+0.025, 9.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "H" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <8-1.1, 0+0.025, -0.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "I" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <9-1.1, 0+0.025, 9.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "I" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <9-1.1, 0+0.025, -0.4-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "1" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <0-1.1, 0+0.025, 0.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "1" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <9.75-1.1, 0+0.025, 0.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "2" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <0-1.1, 0+0.025, 1.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "2" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <9.75-1.1, 0+0.025, 1.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "3" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <0-1.1, 0+0.025, 2.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "3" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <9.75-1.1, 0+0.025, 2.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "4" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <0-1.1, 0+0.025, 3.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "4" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <9.75-1.1, 0+0.025, 3.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "5" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <0-1.1, 0+0.025, 4.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "5" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <9.75-1.1, 0+0.025, 4.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "6" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <0-1.1, 0+0.025, 5.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "6" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <9.75-1.1, 0+0.025, 5.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "7" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <0-1.1, 0+0.025, 6.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "7" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <9.75-1.1, 0+0.025, 6.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "8" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <0-1.1, 0+0.025, 7.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "8" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <9.75-1.1, 0+0.025, 7.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "9" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <0-1.1, 0+0.025, 8.75-0.75>
}

 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "9" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <9.75-1.1, 0+0.025, 8.75-0.75>
}

#declare bstone=sphere{
<0, 0, 0> 0.475
texture { pigment {color Black} finish {phong 0.3 diffuse 0.5} 
 }
scale <1, 0.5, 1>}
#declare wstone=sphere{
<0, 0.5, 0> 0.475
texture { pigment {bozo color_map{ [0.1 color Gray70] [0.2 color White] [0.3 color Gray70] [0.4 color White] [0.6 color Gray70] [0.8 color White] [0.9 color Gray60] [0.95 color White] } warp {turbulence <0.24, 0.21, 0.22>}} finish {phong 0.7}
 }
scale <0.95, 0.5, 0.95>}
#declare cstone=sphere{
<0, 0, 0> 0.475
pigment { color Red }
scale <1, 0.5, 1>}
 object{bstone translate <1, 0,1>}
 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "1" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <2-1.1, 0.475+0.025, 1.6-0.75>
}

object{bstone translate <2, 0,1>}
 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "3" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <3-1.1, 0.475+0.025, 1.6-0.75>
}

object{bstone translate <5, 0,3>}
 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "5" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <6-1.1, 0.475+0.025, 3.6-0.75>
}

object{bstone translate <6, 0,3>}
 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "7" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <7-1.1, 0.475+0.025, 3.6-0.75>
}

object{wstone translate <1, 0,7>}
 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "2" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <2-1.1, 0.475+0.025, 7.6-0.75>
}

object{wstone translate <3, 0,5>}
 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "6" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <4-1.1, 0.475+0.025, 5.6-0.75>
}

object{wstone translate <4, 0,1>}
 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "8" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <5-1.1, 0.475+0.025, 1.6-0.75>
}

object{wstone translate <7, 0,7>}
 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "4" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <8-1.1, 0.475+0.025, 7.6-0.75>
}

