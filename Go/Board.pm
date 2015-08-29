package Go::Board;
use strict;
use Go::Node;
use Go::Pov;
use File::Copy;

# Nummern der Steine:
my %stones = (
	      black => 0,
	      white => 1,
	      free => -1,
	      captured => -2,
	      # strategic stones, ie free intersections, captured stones have a value < 0.
	      # Danger: this configuration is used hardcoded in Node.pm! [has to be changed sometime]
	      # Go::Node.pm - Methods using this: 
	      # set_node_color, get_captured_friends(), has_freedoms(), new(), set_node_color()
	      # Go::UI::Text.pm is using this also...

	      # Strategische Steine (Freie Flächen, Gefangene etc haben Wert < 0!
	      # Achtung: Liste muß auch in Go::Node.pm ->set_node_color beachtet werden!
	      );

# Die "Farbe" der Steine für die Textausgabe:
# The 'color' of stones for ASCII-output:
my %pieces = (
	      -1 => ".",
	      -2 => "*",
	      0 => "X",
	      1 => "O",
	      );
my %options;
my $current;

# Go-Board: x*y Nodes
# Node{ID = 0..360, neighbours: [2-4] refs to \Node. 

# array[0..x][0..y]
# Board-refs: 
# array[0..x*y] of Node-refs.

sub new{
    my ($class, %param) = @_;
    my $obj_ref = {
	x_size => $param{'x_size'},
	y_size => $param{'y_size'},
	board_nodes => [], #alternativer Zugriff über x,y
	board => [], # results of create_board_array [x][y], values: -1 (free) 0 (white) 1 (black)
	nodes => [], # array of all Nodes
	clusters => [],
	moves => [],
	board_history => [], # History-List for Undo - contains an anonymous array of colors[for each Node] for each move.
	player_history => [],
	current_move => 1, # record_move increases this each move.
	current_color => 0, # Black starts the game.
	ui => [], # List of User Interfaces
	captured => {}, # captured group-ids
	score => {},
	last_action => "start", # debugging option
	shape => $param{'shape'} || 'rectangle',   # shape of the board
	id_gruppen => 0,        # all groups.
	pictures => 0, # counter for rendered images. Is != moves because of images displaying 'captured' stones or animations
	captured_stones => {}, # hash{color} => number
	max_moves => $param{'x_size'} * $param{'y_size'} +1,
	
    };    
    
    bless $obj_ref, $class;
    
    $obj_ref->create_nodes();
    return $obj_ref;

}

sub set_options{    
    #no strict 'refs';
    %options = %{shift(@_)};
    print "options:\n";
    while(my ($a, $b) = each %options){
	print "$a $b\n";
    }
}

sub add_user_interface{
    my ($self, $ui) = @_;
    push @{ $self->{'ui'} }, $ui ;
}

sub get_ui_list{
    my ($self) = @_;
    return @{ $self->{'ui'} };
}

sub get_board_shape{
   my ($self) = @_;
   return $self->{'shape'};
}

sub create_nodes{
# für jeden Gitterpunkt wird ein Knoten =/Node/ erzeugt.
# jeder Knoten bekommt 2-4 Freunde =/benachbarte Punkte/.
    my ($self) = @_;
    my ($dim_x, $dim_y) = $self->get_board_dimensions();
    my $shape = $self->get_board_shape();
    my $x = 0;
    my $y = 0;

    for $y (1..$dim_y){
	for $x (1..$dim_x){
	    my $node = Go::Node->new($x, $y);
	    push @{$self->{nodes}}, $node;
	    $self->{"board_nodes"}[$x][$y] = \$node;	    
	}
	
    }

    if ($shape eq 'rectangle'){
	for my $count (0..$#{$self->{nodes}}){
	    ($x, $y) = $self->{nodes}[$count]->get_node_pos();
	    #print "Nodepos: $x / $y\n";
	    if ($x < $dim_x){
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$count+1]);
	    }
	    if ($x > 1){
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$count-1]);
	    }
	    if ($y < $dim_y){
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$count+$dim_x]);
	    }
	    if ($y > 1){
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$count-$dim_x]);
	    }
	    
	}
    }
    elsif($shape eq 'toroid'){
	for my $count (0..$#{$self->{nodes}}){
	    ($x, $y) = $self->{nodes}[$count]->get_node_pos();
	    #print "Nodepos: $x / $y\n";
	    if ($x < $dim_x){
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$count+1]);
	    }
	    else{
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$count-$dim_x+1]);
	    }
	    if ($x > 1){
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$count-1]);
	    }
	    else{
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$count+$dim_y-1]);
	    }

	    if ($y < $dim_y){
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$count+$dim_x]);
	    }
	    else{
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$x-1]);
	    }

	    if ($y > 1){
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$count-$dim_x]);
	    }
	    else{
		$self->{nodes}[$count]->add_friend( $self->{nodes}[($dim_x*$dim_y)-$x]);
	    }
	    
	}
    }
    elsif( $shape eq 'circles'){
	for my $count (0..$#{$self->{nodes}}){
	    ($x, $y) = $self->{nodes}[$count]->get_node_pos();
	    #print "Nodepos: $x / $y\n";
	    if ($x < $dim_x){
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$count+1]);
	    }
	    else{
		# the last node points to the first of this row (= circle)
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$count-$dim_x+1]);
	    }
	    if ($x > 1){
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$count-1]);
	    }
	    else{
		# the first node points to the last one of this row (= circle)
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$count+$dim_x-1]);
	    }
	    if ($y < $dim_y){
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$count+$dim_x]);
	    }
	    if ($y > 1){
		$self->{nodes}[$count]->add_friend( $self->{nodes}[$count-$dim_x]);
	    }		
	    
	}
    }
    
}

sub get_board_dimensions{
    my ($self) = @_;
    return $self->{x_size}, $self->{y_size};
}

sub get_current_player{
    my ($self) = @_;
    return $self->{'current_player'};
}

sub set_current_player{
    my ($self, $player) = @_;
    $self->{'current_player'} = $player;
    $self->{'player_history'}[ $self->get_current_move() ] = $player;
}

sub get_player_of_move{
    my ($self, $move) = @_;
    return $self->{'player_history'}[ $move ];
}

sub get_last_action{
    my ($self) = @_;
    return $self->{'last_action'};
}

sub set_last_action{
    my ($self, $action) = @_;
    $self->{'last_action'} = $action;
} 

sub place_stone{
    my ($self, $x, $y, $color) = @_;
    my ($xdim, $ydim) = $self->get_board_dimensions();
    my (%vor, %danach);
    my $old_color;

    $self->create_board_array();
    # test: in board_dim?
    if ($x > $xdim || $x <1 || $y > $ydim || $y < 1){
	if ($x == 0 && $y == 0){
	    # Pass / Aussetzen
	    # Should have a graphical / text-mode message.
	    $self->record_move(0,0,$color);
	    return 1;
	}
	print "Feld außerhalb des Brettes\n";
	return 0;
    }
    # test: already occupied?
    if ($self->{"board"}[$x][$y] > -1){
	print "Feld schon belegt!\n";
	return 0;
    }

    # Wiederholung verboten:
    if ($self->count_moves())
    {
	my ($old_x, $old_y) = $self->get_last_move();	
	if ($x == $old_x && $y == $old_y){
	    print "Wiederholung verboten!\n";
	    return 0;
	}
    }
    # test: legal? -> a: selbstmord
    %vor = %{ $self->eval_board() };
    
    $old_color = ${$self->{"board_nodes"}[$x][$y]}->get_node_color();
    ${$self->{"board_nodes"}[$x][$y]}->set_node_color($color);
    %danach = %{ $self->eval_board()};
 

    # Wer profitiert?

    my $node = ${$self->{"board_nodes"}[$x][$y]};

    $current="place_stone b\n";

    if ( # A: meine Gruppe == keine Freiheiten.
	 # B: captured_friends of my color > 1

	 # $node->has_freedoms() == 0 &&
	 # der Punkt hatte keine Freiheiten.
	 # dieser Test war wohl Unfug - es geht ja immer um die Gruppe, nicht um 1 Punkt.

	 get_group_freedoms( @{ ${$self->{"id_gruppen"}}{$node->get_group_id()} } ) < 1 &&

	 # die neue Gruppe ist sofort gefangen worden
	 
	 $node->get_captured_friends($self) == 0
	 # hat aber keine eigenen Gefangenen 
	 )	
    {
	# Selbstmord verboten!
	# Alter Zustand wird wieder hergestellt.
	print "Selbstmord verboten!\n"; # id ".$self->{"captured"}{$node->get_group_id()}."\n";
	#print "pos: ".join(" ",$node->get_node_pos())."\n";
	#print $self->{"captured"}{$node->get_group_id()}." captured!\n";
	#print $node->get_node_color." = Farbe\n";	
	#print $node->get_group_id." = id\n";
	#print ${$self->{"board_nodes"}[1][2]}->get_group_id." id-1.2\n";
	#print ${$self->{"board_nodes"}[2][1]}->get_group_id." id-2.1\n";
	#print ${$self->{"board_nodes"}[2][1]}->has_freedoms()."\n";
	#print ${$self->{"board_nodes"}[2][1]}->has_freedoms()."\n";
	${$self->{"board_nodes"}[$x][$y]}->set_node_color($old_color);
	return 0; 
    }

    ${$self->{"board_nodes"}[$x][$y]}->set_node_color($color);

    foreach( other_colors($color) ){
	my $other = $_;

	if ( # $danach{ $color } >= $vor{ $color } &&
	     
	     $danach{ $other } < $vor{ $other } && 
	     # Opponnent looses stones. 
	     # important.

	     $danach{ $stones{"free"} } <= $vor{ $stones{"free"} })   # Freie Flächen == oder -1
	{
	    # Der Spieler am Zug schlägt eine gegnerische Gruppe,
	    # indem er auf ein einzelnes freies Feld setzt.
	    foreach my $ui ( $self->get_ui_list() ){
		$ui->show_board();
	    }

	    $self->dump_board("print" => 0,
			      "pov" => $options{'pov'}
			      );
	    $self->display_changes($color);
	    $self->remove_stones($color);
	}
    }
  
    $self->compute_score();
    $self->record_move($x, $y, $color);
    
    return 1;

}

sub display_changes{
    my ($board, $color) = @_;
    my %freiheit; my %groups;

    foreach my $node ( @{ $board->{"nodes"} } ){
	
	my $my_col = $node->get_node_color();
	my $my_id = $node->get_group_id();
	
	next if ($my_col == $color || $my_col == $stones{ "free" });
	
	if (exists $board->{"captured"}->{$my_id}){
	    $node->set_node_color( $stones{'captured'} );
	}
    }
    # indem er auf ein einzelnes freies Feld setzt.
    foreach my $ui ( $board->get_ui_list() ){
	$ui->show_board();
    }
    $board->dump_board("pov" => $options{'pov'});
     
}

sub remove_stones{
    my ($board, $color) = @_;
    #my @groups;
    my $prisoners = 0;

    foreach my $node ( @{ $board->{"nodes"} } ){
	
	if ($node->get_node_color == $stones{'captured'}){
	    
	    # Counting prisoners:
	    $prisoners++;

	    $node->set_node_color( $stones{'free'} );
	    #push @groups, ($node->get_group_id());
	    $node->set_group_id( -1 );
	}
    }
    
    $board->{'captured_stones'}{ $color } += $prisoners;

}

sub record_move{
    my ($board, $x, $y, $col) = @_;
    push @{ $board->{"moves"} }, [$x, $y, $col];

    # record board status
    my @color_list = ();
    foreach my $node ( @{ $board->{'nodes'} } ){
	push @color_list, ($node->get_node_color() );
    }

    my $move = $board->get_current_move();
    # print "Recording move $move\n";
    $board->{'board_history'}[ $move ] = [@color_list];

    # record current player
    # print "Recording player ".$board->get_current_player()." on Move $move\n";
    # $board->{'player_history'}[$move] = $board->get_current_player();
    $board->set_current_player( $board->get_current_player() );

    $board->inc_current_move();
    $board->set_last_action('record_move');

}

sub get_stone_number{
    my ($board, $x, $y) = @_;
    
    my $move = $board->get_current_move();
    my @moves = @{ $board->get_moves() };

    # in case of undo etc remove unplayed moves:
    #splice(@moves, $board->get_current_move());

    my $count = 1;
    foreach(reverse @moves){
	my ($x1, $y1, $color) = @{ $_ };
	if ($x == $x1 && $y == $y1){
	    return ($move - $count), $color;
	}
	$count++;
    }
    return 0;
}

sub inc_current_move{
    my ($board) = @_;
    $board->{'current_move'}++;
}

sub goto_move{
    # We assume that the interface will check with count_moves if the target move is
    # available. [moving to -1 or 500 will otherwise crash the game]

    my ($board, $move) = @_;

    # The board displayed is the one  at the start of the current move.
    
    my $display = $move-1;
   
    my @color_list = @{ $board->{'board_history'}[ $display || 1 ] }; 
    foreach my $node ( @{ $board->{'nodes'} } ){
	my $color = shift( @color_list );
	if ($display != 0){
	    $node->set_node_color( $color );
	}
	else{
	    $node->set_node_color( $stones{'free'} );
	}
    }
   
    $board->set_current_move($move);
    $board->set_current_player( $board->get_player_of_move($move) );

    #print "Move: $move Player ".$board->get_player_of_move($move)."\n";

}

sub set_current_move{
    my ($board, $move) = @_;
    $board->{'current_move'} = $move;
}

sub get_current_move{
    my ($board) = @_;
    return $board->{'current_move'};
}

sub other_colors{
    my ($col) = @_;
    my @others;

    foreach(keys %stones){
	next if ($stones{$_} < 0 || # keine freien oder gefangenen Farben
		 $stones{$_} eq $col); # und keine der eigenen Farbe
	push @others, ($stones{$_});
    }
    return @others;
}

sub clear_group_ids{
    my ($self, $new_id) = @_;
    foreach( @{$self->{'nodes'}} ){
	$_->set_group_id($new_id);
    }
}


sub compute_score{
    my ($board) = @_;
    my @group_ids = keys %{ $board->{'id_gruppen'} };
    my %free_groups = ();
    my @nodes;

    $board->clear_score();
    
    # find all groups of free grid points.
    foreach my $id ( @group_ids ){
	@nodes = @{ $board->{'id_gruppen'}{$id} };	
	if ( $nodes[0]->get_node_color() == $stones{'free'} ){
	    my @colors = get_surrounding_colors( \@nodes );
	    if ( $#colors == 0 ){
		$board->add_group_to_score( $colors[0], $id );

		# if a territory has only one type of stones surrounding it, it belongs to this group.
		# note that this can result in strange scores if applied after black's first move.

	    }
	    else{
		$free_groups{$id}++;
	    }

	}
    }
    
    # check for neighbours of those groups:
    foreach my $id ( keys %free_groups ){
    }
}

sub get_surrounding_colors{
    my @group = @{ $_[0] };
    my %colors = ();

    foreach my $node (@group){
	foreach my $friend ( @{ $node->get_friends() }){
	    $colors{ $friend->get_node_color() }++;
	}
    }
    return keys %colors;
}

sub clear_score{
    my ($self) = @_;
    $self->{'score'} = ();
}

sub add_group_to_score{
    # adds a whole group of nodes to a color's score.

    my ($board, $color, $id) = @_;
    
    # $score == number of 
    my $score = $#{ $board->{'id_gruppen'}{$id} }+1;
    $board->{'score'}{ $color } += $score;
}

sub get_captured_stones{
    my ($self, $color) = @_;
    return $self->{'captured_stones'}{ $color } || 0;
}

sub get_score{
    my ($self, $color) = @_;

    my $score = $self->get_captured_stones();
    $score += $self->{'score'}{ $color } || 0;
    return  $score;
}

sub eval_board{
    my ($self) = @_;
    my @friends;
    my $new_id = 0;
    my ($x_dim, $y_dim) = $self->get_board_dimensions();
    my $max_id = $x_dim*$y_dim+1;

    #1. create groups/clusters.
    $self->clear_group_ids($max_id);
    $self->{"id_gruppen"} = ();

    # empty id_gruppen to prevent reuse of non-valid ids
    # sonst werden alte IDs weiter verwendet, die aufgrund neuer Gruppen
    # nicht mehr gültig sind.

    foreach( @{$self->{"nodes"}} ){
	my $node = $_;	
	my $my_col = $node->get_node_color();
	
	if ($node->get_group_id() == $max_id){
	    $node->set_group_id($new_id);
	    $node->distribute_low_id($new_id);
	    $new_id++;
	}	
	
	# Wenn die Freunde rundherum keine ID hergeben, erstellen wir eine neue Gruppe.

	#print "Pos: ".join(" ", $_->get_node_pos())." id ".$node->get_group_id()."\n";

    }
    
    # Count Groups & Freedoms
    my %groups;
    # init:
    foreach(keys %stones){ 
	if( $stones{$_} > -1){
	    $groups{ $stones{$_}} = 0;	
	}
    }

    my %freiheit;   
    my %ids;
    my %gruppen;
    
    foreach my $node ( @{ $self->{"nodes"} } ){
		
	# Gruppenbildung:
#	if ($node->get_node_color() > -1){

	push @{$gruppen{ $node->get_group_id() }} , ($node);

#	}
	# Jede ID soll nur einmal als Gruppenid vorkommen.

	$ids{$node->get_group_id()}++;
	no strict 'refs';
	$groups{$node->get_node_color()}++ unless $ids{$node->get_group_id()} > 1;		
    }
    
    ###Group-dump
    print "*"x 10 ."\n";
    
    $self->{'captured'} = ();
    # Alte "Gefangene" löschen!;

    foreach my $count (keys %gruppen){

	#print "ID: ".$gruppen{$count}[0]->get_group_id()." ";
        #print Go::Node::group_pos_str( @{ $gruppen{$count} } )." ";
	#print "Freiheiten: ".get_group_freedoms( @{$gruppen{$count}} )."\n";
	$current = "eval_board\n";
	if (get_group_freedoms( @{$gruppen{$count}} ) == 0 ){

	    #print "Captured:".$gruppen{$count}[0]->get_group_id()."\n";

	    $self->{"captured"}{ $gruppen{$count}[0]->get_group_id() } = 1;
	    $groups{  $gruppen{$count}[0]->get_node_color() }--;
	}
	
    }

    $self->{"id_gruppen"} = \%gruppen;

#    foreach ( keys %groups){	
#	print "$_ Gruppen: $groups{$_} \n";
#    }

    return \%groups;

}

sub get_group_freedoms{
    my (@nodes) = @_;
    my %visited;
    my $freedoms = 0;

    if ($#nodes == -1){
	warn "Leere Liste!\n";
	print "Aufruf durch $current\n";	
    }
    
    return 1 if $nodes[0]->get_node_color() == -1;
    # a free intersection is a free group in itself.

    foreach my $node (@nodes){
	
	foreach my $friend ( @{$node->get_friends()} ){
	    if ( $friend->get_node_color() == -1){
	#	print "Position: ".$node->get_node_pos_str();
	#	print " frei: ".$friend->get_node_pos_str()."\n";
		$visited{$friend}++;		
	    }
	}
	# print $node." has ".keys(%visited)." friends\n";
    }
 
    $freedoms = keys %visited;
    
    return $freedoms;
}


sub eval_move{
    my ($self) = @_;
    # 0: Das Brett sollte nicht jedesmal neu ausgewertet werden, wenn es lediglich darum geht, das
    # Spiel zu verfolgen. Bei Bewertungen der Spielsituation kommt man da wohl nicht drum rum.
    # 1. Stein kann nur 4 Cluster betreffen.
    # diese müssen untersucht werden auf:
    # a: delete_cluster? wird ein Cluster geschlagen?
    # b: join_cluster? werden 2 Gruppen zu einer zusammengefasst?    
}

sub create_board_array{
    my ($self) = @_;
    my ($x, $y) = $self->get_board_dimensions();     

    no strict 'refs'; # unusual?
    
    foreach(@{$self->{nodes}}){
	my ($a, $b) = $_->get_node_pos();
	my $color = $_->get_node_color();
	$self->{"board"}[$a][$b] = $color;
    } 
}

sub dump_board{
    my ($self, %mode) = @_;
    my ($x, $y) = $self->get_board_dimensions();     
    my ($a, $b);
    my $pcount;

    my %cols;
    my %pov_cols = (
		    0 => "Black",
		    1 => "White",
		    -2 => "Captured",	      
		    );
  
    no strict 'refs'; # ob ich weiß, was ich tue?
    
    foreach(@{$self->{nodes}}){
	($a, $b) = $_->get_node_pos();
	#print "Node: $a $b";	
	my $color = $_->get_node_color();
	$self->{"board"}[$a][$b] = $color;
	
	if ($mode{"pov"}){
	    if ($color != -1){
		push @{$cols{$color}}, ($b, $a);
	    }
	}	

	#print " Farbe".$_->get_node_color()."\n";
    }
    
    use strict 'refs';
    
    if ($mode{"pov"}){

	foreach(keys %cols){
	    my $file = $pov_cols{$_}.".txt";
	    open(GO, ">$file");	    
	    print GO join(",", @{$cols{$_}}).", -1, -1";	    
	    close(GO);
	}

	my $scene = Go::Pov->new('name' => 'first.pov',
				'x' => $options{'x'},
				'y' => $options{'y'},
				'stones' => \%cols,
				 'board_ref' => $self,
				 'pov_numbering' => $options{'pov_numbering'},
				 'numbering_x' => $options{'numbering_x'},
				 'numbering_y' => $options{'numbering_y'},
				 'no_render' => $options{'no_render'},
				);

	#print "moves: ".$self->count_moves()."\n";
	my $path;

	if ( $options{'os'} eq 'linux'){
	    $path = $options{'path_linux'};	    
	}
	elsif( $options{'os'} eq 'win'){
	    $path = $options{'path_windows'};
	    warn("POV-Ray not found. Please install or change default.config.")
		unless -e $path;
	}

	$scene->render_scene(
		       path => $path,
		       height => $options{'height'} || 300,
		       width => $options{'width'} || 400,
		       out_file => "go".pad_number($self->{'pictures'}).".tga",
		       in_file => 'first.pov',
		       );
		       

	my $final = $self->{'pictures'} + $options{'fpt'};
	my $source = "go".pad_number($self->{'pictures'}).".tga";

	while($self->{'pictures'} < $final){
	    my $dest = "go".pad_number(++$self->{'pictures'}).".tga";
	    # print "Source: $source Dest: $dest\n";
	    copy($source, $dest);
	}	
    }

    return 1;
}

sub pad_number{
    my ($nr) = @_;
    while(length($nr) < 6){
	$nr = "0".$nr;
    }
    return $nr;
}

sub count_moves{
    my ($board) = @_;
    return $#{$board->{"moves"}}+1;
}

sub get_max_moves{
    my ($game) = @_;
    return $game->{'max_moves'};
}

sub get_last_move{    
    my ($board) = @_;
    my $last_move =  $#{$board->{"moves"}};
    return $board->{"moves"}->[$last_move];    
}

sub get_moves{
    my ($self) = @_;
    return \@{ $self->{'moves'} };
}

sub load_game{
    my ($self, $filename) = @_;    

    open(GAME, $filename || "game.dat") or warn "Konnte Datei $filename nicht öffnen!\n" and
	return 0;
    
    while(<GAME>){
	chomp;
	my ($x, $y, $color) = split / /, $_;	
	$self->record_move($x, $y, $color);       
	${$self->{"board_nodes"}[$x][$y]}->set_node_color($color);
    }
    close(GAME) or warn "Konnte Datei $filename nicht schließen!\n";
    
    $self->eval_board(); 
    # Illegal moves will create captured groups.

    return 1;
}

sub dump_moves{
    my ($board, %mode) = @_;
    my $filename = 0;

    if ($mode{'save'}){
	# save moves
        $filename = $mode{'filename'} || "game.dat";
	open(GO, ">$filename");
    }
    
    
    my $count = 1;
    foreach( $board->get_moves() ){

	if ($mode{'print'} ){
	    print "Move:";
	    print join(" ", @{$_})."\n";
	}
	if ($mode{'save'} ){
	    foreach( @{$_} ){
		# prevent Undo'ed moves to be saved.
		last if $count == $board->get_current_move();
		$count++;

		print GO join(" ", @{$_})."\n";
	    }
	}	

    }

    if ($filename){
	close(GO);
    }
    
}

1;

__END__
# Pod-Documentation:

=head1 NAME

Go::Board is responsible for providing the normal game logic.

=head1 SYNOPSIS

 use Go::Board;
 my $go = Go::Board->new( x_size => 19, y_size => 19 );

 while(1){
     $go->dump_board( print => "1");
     my ($x,$y) = get_move();
     $go->place_stone($x,$y, "black");
     $go->dump_board( print => "1");
     ($x,$y) = get_move();
     $go­>place_stone($x,$y, "white");
 }

=head1 DESCRIPTION

Go::Board creates a board object and lets you place stones on it according to the Go rules. It can direct the renderer (Pov.pm) and print a representation of the board to the Console.

=head1 METHODS

=head2 new(%options)

Creates a new board object. %options hash should include x_size and y_size to determine the size of the board.

=head2 Information Gathering

=head3 get_board_dimensions()

Returns the board dimensions as ($x, $y).

=head3 get_captured_stones( $color )

Returns the number of stones caputred by this color's player.

=head3 get_max_moves()

Returns the number of possible stones you can set on this board. A 19x19 board would allow 361 moves.

=head3 get_current_move()

Returns the # of the current move.

=head3 get_current_player()

Return the color of the current player.

=head3 get_last_action()

Debugging option: Returns the last recorded action ie, undo or record_move.

=head3 get_player_of_move( $move )

Returns the color of the player who was active at move X.

=head2 create_board_array()

Generates a 2D array in $board->{'board'}, each cell containing the color of the given point.

=head2 dump_board(%options)

Generates a presentation of the game board according to the options. Currently implemented are

=over

=item print

print => "1" will display an ASCII-Version of the board, similiar to GnuGo.

=item pov

pov => "1" will cause Pov.pm to render an image of the current board and, if applicable, generate the configured amount of frames etc.

=back

=head2 goto_move( $move )

Will set each node to the color it had during the choosen move and uses set_current_move($move).

=head2 Setting Variables:

=head3 set_current_move( $move )

Sets the variable current_move to $move.

=head3 set_current_player( $player )

Sets the color of the current player, ie. who is to play now.

=head3 set_last_action( $action )

Debugging option. Set to the last thing the script has done.

=head3 inc_current_move()

Increase the variable current_move by 1. Used only by record_move.

=head2 place_stone( $y, $y, $color)

Place a stone on the board. Will return 0 if the move is illegal (suicide, outside of board dimensions, Ko, node already occupied).

=head2 compute_score()

This method currently counts free grid points surrounded by only one type of stones. In the long run, it should be able to make life-and-death decisions etc.

=head2 get_surrounding_colors( @nodes)

Returns an array of colors which are adjacent to the nodes the supplied. Ie, if a group of free points is surrounded by black stones, it would return '0', the number associated to 'black'. (via %stones).

=head2 add_group_to_score( $color, $id )

Add a group of free points with group_id of $id to the $color's score.

=head2 clear_score()

Prior to computing the new score, the old one should be deleted.

=head2 get_score( $color )

Returns the choosen color's score, includes the value generated by compute_score() as well as the number of stones captured by this color.

=head1 TODO

=over

=item *

Scoring should be better. Currently it is extremely simple.

=item *

Figure out how to do variations, comments etc, both in Board.pm and Pov.pm (how to render a variation?)

=item *

SGF->Import, Export, basically, all things SGF need to be done yet.

=back

=head1 BUGS

unknown.

=head1 LICENSE

Distributed under the terms of the Perl Artistic License. You may use this module under the same terms as Perl itself.

=head1 AUTHOR & Copyright

(C) Ingo Wiarda 2003.

=head1 SEE ALSO

http://dewarim.de/de/programme/go_en.html = Homepage

http://sourceforge.net/projects/perlgo = Sourceforge Project Site

http://www.povray.org = Persistence of Vision Raytracer

=cut
