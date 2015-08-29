package Go::Pov;
# Package for generating POV-Ray-Code which displays the Go-Board.
use Exporter;
@ISA = ('Exporter');
@EXPORT = qw(&first_pov &render_scene &save_scene);

use strict;
use warnings;

sub new{
    my ($class, %config) = @_;
    my $scene_ref = {
	name => $config{'name'} || 'first.pov',
	x => $config{'x'}, # board dimensions
	y => $config{'y'},
	board_ref => $config{'board_ref'}, # reference to the corresponding board object.
	includes => "",
	load_defs => { 'stones' =>'1',
		   }, # load definitions for objects?
	camera => {},
	background => "",	
	lightsources => {},
	stones_defs => [], # def(stones), not place(stones)
	stones => $config{'stones'}, # a hash-ref to stone{color}[list], list = x,y,x,y,x,y etc
	pov_numbering => $config{'pov_numbering'} || 0, # should the stones be numbered?
	numbering_x => $config{'numbering_x'},
	numbering_y => $config{'numbering_y'},
	no_render => $config{'no_render'},
	plane => "",
	board => "",
    };

    bless $scene_ref, $class;

    $scene_ref->init_scene();
    return $scene_ref;

    # A PerlGo-scene consists of the following elements:
    # 1. Include Files (for Textures etc)
    # 2. Camera
    # 3. Lightsources
    # 4. Background Plane
    # 5. Board
    # 6. Stone Definition
    # 7. Stone Placement
}

sub get_config{
    
}

sub get_board_ref{
    my ($scene) = @_;
    return $scene->{'board_ref'};
}

sub render_scene{
    my ($scene, %sys) = @_;
    
    my $execute = $sys{'path'}." -W".$sys{'width'}." -H".$sys{'height'}." +FT -P +A0.3 +O".$sys{'out_file'}.' +I'.$sys{'in_file'};
    $scene->save_scene( $sys{'in_file'} );
    if ($scene->no_render()){return 0}
    system($execute);

}

sub no_render{
    my ($scene) = @_;
    # only create first.pov, but do not render!
    return $scene->{'no_render'};
}

sub save_scene{
    my ($scene, $file) = @_;

    open(POV, ">$file");
    print POV $scene->get_includes_str();
    print POV $scene->get_camera_str();
    print POV $scene->get_lightsources_str();
    print POV $scene->get_background_str();
    print POV $scene->get_plane_str();
    print POV $scene->get_board_str();
    print POV $scene->get_board_lines();
    print POV $scene->get_stones_defs_str();
    print POV $scene->get_stones_str();
    close(POV);
}


sub load_defs{
    my ($scene, $type) = @_;
    return $scene->{'load_defs'}{ $type };
}

sub get_numbering_mode{
    my ($scene) = @_;
    return $scene->{'pov_numbering'};
}

sub get_stones_str{
    my ($scene) = @_;
    my %stones = %{ $scene->{'stones'} };
    my %pov_cols = (
		    0 => "bstone",
		    1 => "wstone",
		    -2 => "cstone",	      
		    );
    my $str = " "; # not empty to avoid warnings for the first image.
    my $board = $scene->get_board_ref();

    foreach(keys %stones){
	my @arr = @{ $stones{$_} };
	
	while($#arr > 0){
	    my ($x, $y) = splice(@arr, 0, 2);
	    if ( $board->get_board_shape() eq 'rectangle'){
		$str .= 'object{'.$pov_cols{$_}." translate <".($x-1).', 0,'. ($y-1).">}\n";
		if ($scene->get_numbering_mode() ){
		    my ($number, $color) = $board->get_stone_number($y,$x);
		    $color = $color == 1 ? 'Black' : 'White';
		    $str .= make_number_str($number, $x, 0.475, $y-0.4, $color);
		}
	    }
	    elsif( $board->get_board_shape() eq 'circles'){
		#$x = circle
		#$y = ray
		my ($circles, $rays) = $board->get_board_dimensions();
		$rays = 360/$rays;
		
		#$str .= 'object{ '.$pov_cols{$_}." translate <$x*sin($y*$rays)+1, 0, $x*cos($y*$rays)+1>}\n";
		$str .= 'object{'.$pov_cols{$_}."  translate <0,0,$x+1> ";
		$str .= "rotate <0,  $y * $rays, 0> }\n";
		
		if ($scene->get_numbering_mode() ){
		    my $rota = $y*$rays;
		    my ($number, $color) = $board->get_stone_number($y,$x);
		    $color = $color == 1 ? 'Black' : 'White';
		    $str .= <<"TEXT";
text{
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "$number" 1, 0
pigment { $color }
rotate <90,0,0>
scale <0.5,0.5,0.5>
rotate <0, -$rota,0>
translate <-0.15 , 0.5, $x+0.25>
rotate <0,$rota,0>}

TEXT
		}

	    }
	}

    }
    return $str;
}

sub get_includes_str{
    my ($scene) = @_;
    return $scene->{'includes'};
}

sub get_background_str{
    my ($scene) = @_;
    return $scene->{'background'};
}

sub init_scene{
    my ($scene) = @_;
    my $includes=<<'includes';
#include "colors.inc"
#include "stones.inc"
#include "textures.inc"
#include "shapes.inc"
#include "glass.inc"
#include "metals.inc"
#include "woods.inc"
#include "colors.inc"
includes

    $scene->{'includes'} = $includes;

    $scene->{'background'} = "background { color Cyan }\n";

    my ($x,$y) = $scene->get_board_dim();
    $scene->set_camera('xloc' => $x / 2,
		       'yloc' => $x+3,
		       'zloc' => ($y / 2)-1,
		       'xlook' => $x / 2,
		       'ylook' => 0,
		       'zlook' => $y / 2,
		       );

    if ($scene->get_board_ref()->get_board_shape() eq 'circles'){
	$scene->set_camera( 'yloc' => $x * 1.9 +5,
			    'xloc' => 0,
			    'zloc' => 0,
			    'xlook' => 0,
			    'ylook' => -1,
			    'zlook' => 0,
			    );
    }
    ##
    # Testing a different perspective:

    #$scene->set_camera('xloc' => -3,
#		       'yloc' => $x,
#		       'zloc' => -3
#		       );

    #
    ##
    $scene->set_board('T_Wood10');
    
    $scene->set_board_lines();
        
    my %light = (
		 name => 'sun',
		 color => 'White',
		 pos => [$x / 2, 50, $y / 2], # x,y,z
		 type => 'spotlight',
		 radius => '11', # could be tied to $x?
		 falloff => '20',
		 tightness => '10',
		 point_at => [$x / 2, 0, $y / 2]
		 );
    my %light2 = (
		  name => 'sun2',
		  color => 'White',
		  pos => [9,50,9],
		  );
    
    if ($scene->get_board_ref()->get_board_shape() eq 'circles'){
	$light{'pos'} = [0,50,0];
	$light{'point_at'} = [0,0,0];
	$light2{'pos'} = [0,50,0];
    }

    $scene->set_lightsources(\%light, \%light2);

    $scene->set_plane('pigment { Jade }');

    my %wstone = (
		  'name' => 'wstone',
		  'type' => 'sphere',
		  'pos' => [0, 0.5, 0],
		  'radius' => 0.475,
		  'texture' => "",
		  'pigment' => 'color White',
		  'scale' => [0.95, 0.5, 0.95],
		  );

    my %bstone = (
		  'name' => 'bstone',
		  'type' => 'sphere',
		  'pos' => [0, 0, 0],
		  'radius' => 0.475,
		  'texture' => "",
		  'pigment' => 'color Black',
		  'scale' => [1, 0.5, 1],
		  );

    my %cstone = (
		  'name' => 'cstone',
		  'type' => 'sphere',
		  'pos' => [0, 0, 0],
		  'radius' => 0.475,
		  'texture' => "",
		  'pigment' => 'color Red',
		  'scale' => [1, 0.5, 1],
		  );
    my %stone_defs = ( 'wstone' => \%wstone,
		       'bstone' => \%bstone,
		       'cstone' => \%cstone,);

    if ( $scene->load_defs('stones') ){	
	foreach my $stone ( keys %stone_defs ){
	    if (-e "pov_defs/$stone.def"){
		open( DEF, "pov_defs/$stone.def") or die "Could not open pov_defs/$stone.def\n";
		while(<DEF>){
		    next if $_ =~ m/^\#/;
		    my ($key, $value) = split /=/, $_;
		    ${ $stone_defs{ $stone } }{ $key } = $value;
		}
	    }
	}
    }
    
    $scene->set_stone_defs( values %stone_defs  );
    
    # $scene->put_stones();
    # not needed yet - $scene is generated new each time
    # with the complete board-settings.
    
}

sub get_board_lines{
    # returns the lines which mark the intersections on the board.
    my ($scene) = @_;
    
    return $scene->{'board_lines'};
}

sub get_stones_defs_str{
    my ($scene) = @_;
    my $str;

    foreach ( @{ $scene->{'stones_defs'} } ){
	my %stone = %{ $_ };
        $str .= '#declare '.$stone{'name'}.'='.$stone{'type'}."{\n";
	$str .= "<".join(", ", @{ $stone{'pos'} })."> ";

	if ($stone{'type'} eq 'sphere'){
	    # you can define other stones-shapes, like "cube"
	    $str .= $stone{'radius'}."\n";
	}
	if ($stone{'texture'} ){
	    if ($stone{'pigment'}){
		$str .= 'texture { pigment {'.$stone{'pigment'}.'} '.$stone{'texture'}." }\n";
	    }
	    else{
		$str .= 'texture { '.$stone{'texture'}." }\n";
	    }
	}
	else{
	    $str .= 'pigment { '.$stone{'pigment'}." }\n";
	}
	$str .= 'scale <'.join(", ", @{ $stone{'scale'} }).">";

	# insert: phong, finish etc here.

	$str .= "}\n";

    }
    return $str;
}

sub set_stone_defs{
    my ($scene, @stones) = @_;
    @{ $scene->{'stones_defs'} } = @stones;    
}

sub set_board{
    # future versions may include options for dots=on/off etc.
    my ($scene, $texture) = @_;

    my ($x, $y) = $scene->get_board_dim();
    my $str;
    if ( $scene->get_board_ref()->get_board_shape() eq 'circles'){
	# circular boards need more space.
	$str=<<"BRETT";
    box{<-($x+2),-0.5,-($y+2)>,
	<$x+2,0,$y+2>
	    texture { $texture } 
    }
BRETT
    }
    else{
	$str=<<"BRETT";
	box{<-2,-0.5,-2>,
	    <$x+1,0,$y+1>
		texture { $texture } 
	}
BRETT
	}
    $scene->{'board'} = $str;

}

sub get_numbering{
    my ($scene, $axis) = @_;
    if ($axis eq 'x'){
	return $scene->{'numbering_x'};
    }
    elsif($axis eq 'y'){
	return $scene->{'numbering_y'};
    }
    return 0;
}

sub make_number_str{
# remember, $y is z-coordinate in PovRay, $z = y-coordinate!
    my ($number, $x, $y, $z, $color) = @_;
    $color ||= 'Black';
    my $str =<<"TEXT";
 	    text {
ttf "ttf-bitstream-vera-1.10/Vera.ttf" "$number" 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>      
translate <$x-1.1, $y+0.025, $z-0.75>
}

TEXT

    return $str;
   
}

sub set_board_lines{
    my ($scene) = @_;
    my $str;
    my ($x, $y) = $scene->get_board_dim();
    my $board = $scene->get_board_ref();

    if ( $board->get_board_shape() eq 'rectangle' ){
	$str .=<<'MORE';
#declare boardx=x;
#declare boardy=y;
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

MORE

    my $numbering = $scene->get_numbering('x');

# Numbering-Code taken from UI::Text.pm:
    my $start = ord("A");
    my $end = $start+$x-1;
    my @aleph = map { chr($_) } ($start..$end);
 
    # 'gnugo' : the board is numbered A..Z, skipping I. get_moves must consider this, too...
    if ($numbering eq 'gnugo'){
	splice( @aleph, ord('I')-$start, 1);
    }
	
    if ($numbering =~ m/^az$|^gnugo$/ ){
	my $count = 1;
	foreach(@aleph){
	    $str .= make_number_str($_, $count, 0, $y+0.4);
	    $str .= make_number_str($_, $count, 0, -0.4);
	    $count++; 
	}
    }
	elsif($numbering eq '09'){
	    foreach(1..$x){
		$str .= make_number_str($_, $_, 0, $y+0.4);
		$str .= make_number_str($_, $_, 0, -0.4);
	    }
	}
    
	
    $numbering = $scene->get_numbering('y') || 0;

    $start = ord("A");
    $end = $start+$y-1;
    @aleph = map { chr($_) } ($start..$end);
 
    # 'gnugo' : the board is numbered A..Z, skipping I. get_moves must consider this, too...
    if ($numbering eq 'gnugo'){
	splice( @aleph, ord('I')-$start, 1);
    }
	
    if ($numbering =~ m/^az$|^gnugo$/ ){
	my $count = 1;
	foreach(@aleph){
	    $str .= make_number_str($_, 0.25, 0, $count-0.25);
	    $str .= make_number_str($_, 0.25, 0, $count-0.25);
	    $count++; 
	}
    }
    elsif($numbering eq '09'){
	foreach(1..$x){
	    $str .= make_number_str($_, 0, 0, $_-0.25);
	    $str .= make_number_str($_, $x+0.75, 0, $_-0.25);
	}
    }

}    
   elsif( $board->get_board_shape() eq 'circles'){
	$str =<<'CIRCLE';
#declare boardx=x;
#declare boardy=y;

#declare vline=box{<0,0,2><0.025,0.025,boardx+1> pigment {color Black}}

#declare index=1;
#while (index <boardy+1)
#declare rota= index * 360 / boardy;

object{vline rotate <0,rota,0> }
#declare tobj=text{
ttf "ttf-bitstream-vera-1.10/Vera.ttf" str(index,0,0) 1, 0
pigment { Black }
rotate <90,0,0>
scale <0.5,0.5,0.5>
rotate <0, -rota,0>
translate <0 , 0.25, 1.15>
}
    object{tobj rotate <0,rota,0>}
    object{tobj translate <0, -0.2, boardy+0.5> rotate <0,rota,0>}
//*translate <sin(rota)*2, 0.25, cos(rota)*2>

#declare index= index+1;
#end

#declare index=2;
#while (index <= boardx+1)

object{ difference{
	 cylinder{<0,0,0><0,0.01,0> index pigment{ color Black }}
	 cylinder{<0,-1,0><0,2,0> index-(index*2/150) pigment {color Black} }

	 }
}
#declare index=index+1;
#end

CIRCLE

    } 

    $str =~ s/x=x/x=$x/g;
    $str =~ s/y=y/y=$y/g;

    $scene->{'board_lines'} = $str;
		  
}

sub get_board_str{
    my ($scene) = @_;
    return $scene->{'board'};
}
sub set_plane{
    # simple version for PerlGo:
    my ($scene, $pigment) = @_;
    $scene->{'plane'} = 'plane{y,-0.5 '.$pigment."}\n";
}

sub get_plane_str{
    my ($scene) = @_;
    return $scene->{'plane'};
}


sub set_lightsources{
    my ($scene, @lights) = @_;
    for my $x (0..$#lights ){
	$scene->{'lightsources'}{ $lights[$x]{'name'} } = $lights[$x];
    }
}

sub get_lightsources_str{
    my ($scene) = @_;
    my $str;

    foreach my $candle ( keys %{ $scene->{'lightsources'} } ){
	my %light = %{ $scene->{'lightsources'}{ $candle } };
	$str .= "light_source { <".join(", ", @{ $light{'pos'}  }).">\n";
	$str .= "color ".$light{'color'}."\n";
	$str .= $light{'type'} || "";
	$str .= "\n";
	foreach my $key ( 'radius', 'falloff', 'tightness' ){
	    if (exists $light{ $key }){
		$str .= $key." ".$light{ $key }."\n";
	    }
	}
	if(exists $light{'point_at'}){
	    $str .= "point_at <".join(", ", @{ $light{'point_at'}  }).">\n";
	}
	$str .= "}\n";
    }
   
    return $str;
}

sub set_camera{
    my ($scene, %ops) = @_;
    foreach( keys %ops ){
	$scene->{'camera'}{$_} = $ops{$_};
    }    
}

sub get_board_dim{
    my ($scene) = @_;
    return $scene->{'x'}, $scene->{'y'};
}

sub get_camera_pos{
    my ($scene) = @_;
    return $scene->{'camera'}{'xloc'},
    $scene->{'camera'}{'yloc'},
    $scene->{'camera'}{'zloc'};    
}

sub get_camera_looks{
    my ($scene) = @_;
    return $scene->{'camera'}{'xlook'},
    $scene->{'camera'}{'ylook'},
    $scene->{'camera'}{'zlook'};
}

sub get_camera_str{
    my ($scene) = @_;
    my $str = "camera{ location <".join(", ", $scene->get_camera_pos()).">\n";
    $str .= "look_at <".join(", ", $scene->get_camera_looks()).">\n}\n";    
}

1;

__END__

# Documentation: POD

=head1 NAME Go::Pov.pm

A module for rendering go boards with POV-Ray

=head1 SYNOPSIS

use Go::Pov;

This module is used only by Go::Board.

=head1 DESCRIPTION

Go::Pov is supposed to handle all things concerning rendering of the game board.

=head1 METHODS

=head2 new( %options )

Creates a new Scene object.

The %options hash should contain the following:

=over

=item name

The name of the scene. Defaults to first.pov

=item x => number

The width of the board measured in intersections / grid points. (9x9, 19x19 etc)

=item y => number

The height of the board measured in grid points.

=item stones

 stones is a \%hash ref, which contains
 %stones = (
    black => [x,y,x,y,...] # list of stones.
    white => []
    captured => []
 );

=back

=head2 render_scene( %options )

This will start povray via system().

%options should contain:

=over

=item path => path_to_povray_executable

Eg, C:\bin\povray.exe or (Linux:) povray

=item width => number

Width of the image in pixels.

=item height => number

Height of the image in pixels. Note that unusual dimensions will result in distorted images (400x300 or multiples are good for normal screens, it seems).

=item in_file => file_name

The name of the file where POV-Ray will find the code for the scene. Choose one. render_scene() will save the pov-code of the object the method is performed upon in this file and then call system() to render the scene.    

=back

=head2 save_scene( $filename )

Will save the pov-code in the filename specified. At the moment, no checks are performed...
save_scene will call the following, each of which returns a string with dynamically generated pov-code.

=over

=item *

get_includes_str() returns the include-files for POV-Ray.

=item *

get_camera_str() returns the camera code.

=item *

get_lightsources_str() returns the light_sources.

=item *

get_background_str() returns the code for the background of the image (ie, Cyan at the moment)

=item *

get_plane_str() returns the code for generating a plane upon which the board rests.

=item *

get_board_str() returns the code for the go board.

=item *

get_stones_defs_str() returns the code defining the stone objects.

=item *

get_stones_str() returns the code which places the stone objects upon the board.

=back

=head2 init_scene()

Creates the default code for the whole scene.

=head2 get_board_dim()

Returns the board dimensions ($x, $y)

=head2 set_board( $texture )

You can define a board texture here, like the default 'T_Wood10' or 'color White'.

=head2 set_camera( %options )

Define the camera:

=over

=item xloc => x_position

The first stone should lie at point <0, 0, 0>.

=item yloc => y_position

=item zloc => z_position

Remember: if you look at the board from above, x is width and z is height of the board. y determines the direction up from the board.

=item xlook, ylook, zlook => ...

Those define where the camera looks to. At the moment, it starts looking at <$x/2, 0, $y/2>, hovering at <$x/2, $x+3, ($y/2 -1)>

=back

=head2 set_lightsources( \%light1, \%light2, ...)

The \%light-hash is defined thus:

=over

=item name => 'choose a name'

=item color => 'a color like White'

=item pos => [$x, $y, $z]

=item type => 'spotlight' #optional

Spotlight needs you to give additional arguments: radius, falloff, tightness, point_at. Each takes a number, except point_at, which wants [$x,$y,$z] where the spotlight should point to. See the POV-Ray documentation about what those variables will do.

=back

=head2 set_plane( 'color or pigment' )

Sets at color or pigment for the plane upon which the board rests. Default: 'pigment { Jade }'

=head2 set_stone_defs( \%wstone, \%bstone, \%cstone )

Sets the definitions for the stones to be placed upon the board. The Hashes are made up this way:

=over

=item name => 'str'

Hashes with the names wstone, bstone and cstone for white, black and captured stones are expected.

=item 'type' => 'object_type'

Default is a sphere, an POV-Ray object type. Of course, you can define cylinders or boxes, just make sure that
get_stones_defs_str() can output those new objects.

=item pos => [x, y, z]

Where to place it initially. This is important! All stones are expected to start around <0,0,0> (or, like the white sphere, slightly above the board with <0, 0.5, 0>. Each stone object is created at this point and then translated towards its destination. You can use this for putting stones slightly off the intersections, but don't overdo it.

=item radius => number

A floating point number. Radius is used only with sphere (or cylinder, should someone define it). Default is 0.475

=item pigment => str

A pigment like '{ Jade }' used for the board, or a 'color Black' for simple stones.

=item scale => [x,y,z]

How you want to scale the stone. <1, 1, 1> will leave it the same. Those numbers will used to expand or contract all objects of this class in the given direction. <1, 0.5, 1> will give small stones which are somewhat flat - a sphere with only 50% height. Default for white sones [wstone] is <0.95, 0.5, 0.95> whereas black is somewhat larger <1, 0.5, 1> ** or should it be the other way round?**

=back

=head1 TODO

Implement more scene-control methods, like update_camera or move_camera etc.

=head1 BUGS

unknown.

=head1 LICENSE

Distributed under the terms of the Perl Artistic License.

=head1 AUTHOR

(C) Ingo Wiarda 2003

=head1 SEE ALSO

Go::Board, Go::Node

=cut
