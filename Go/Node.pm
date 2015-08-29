package Go::Node;
use strict;
#@ISA = ("Go::Board"); #nötig?

sub new{
    my ($class, $xdim, $ydim) = @_;
    my $node_ref = {
	x => $xdim,
	y => $ydim,
	color => "-1",
	friends => [],
	group_id => "-1",
    };    
    bless $node_ref, $class;
}

sub add_friend{
    my ($self, $friend) = @_;
    push @{$self->{friends}}, ($friend);
    #my ($x, $y) = $self->get_node_pos();
    #my ($f1, $f2) = $friend->get_node_pos();
    #print "I am Node $x $y and my new friend is Node $f1 $f2\n";
}

sub get_friends{
    my ($self) = @_;
    return $self->{"friends"};
}

sub group_pos_str{    	
    my @nodes = @_;
    my $pos;
    foreach( @nodes ){
	$pos .= $_->get_node_pos_str();
    }
    return $pos;
}

sub get_captured_friends{
    # sind benachbarte Gruppen auch gefangen?
    my ($self, $boardref) = @_;
    my $captured = 0;

    foreach( @{$self->get_friends()} ){
	#print $_->get_group_id()." Gruppenid von $_\n";
	
	if (  Go::Board::get_group_freedoms( @{ ${$boardref->{"id_gruppen"}}{$_->get_group_id()} }) < 1 &&
	      # Farbkontrolle ist wichtig für Selbstmordkontrolle
	      $_->get_node_color() != $self->get_node_color())
	{
	    $captured++;
	}
    }
    return $captured;

}

sub get_group_id{
    my ($self) = @_;
    return $self->{"group_id"};
}

sub set_group_id{
    my ($self, $id) = @_;
    $self->{"group_id"} = $id;
}

sub get_node_pos{
    my ($self) = @_;
    return $self->{x}, $self->{y};
}
sub get_node_pos_str{
    my ($self) = @_;
    return " $self->{y} $self->{x} ";
}

sub get_node_color{
    my ($self) = @_;
    return $self->{"color"};
}

sub distribute_low_id{
    my ($self, $id) = @_;
    foreach( @{$self->get_friends()}){
	if ($_->get_group_id > $id && $_->get_node_color() == $self->get_node_color()){
	    $_->set_group_id($id);
	    $_->distribute_low_id($id);
	}
    }
}

sub has_friends{
    my ($self) = @_;
    my $friends = 0;
    foreach( @{$self->get_friends()} ){
	if ($_->get_node_color() == $self->get_node_color()){
	    $friends++;
	}
    }
    return $friends;
}

sub has_freedoms{
    my ($self) = @_;
    my $freedom = 0;
    foreach( @{$self->get_friends()} ){
	if ($_->get_node_color() == "-1"){
	    $freedom++;
	}
    }
    return $freedom;
}


sub set_node_color{
    # Im Moment werden nur 2 Farben akzeptiert. 5-Farben-Go kann ja später kommen.
    my ($self, $col) = @_;
    if ( ($col > -3) && ($col < 2) ){
	$self->{"color"} = $col;
    }
    else{
	warn("! Stein von undefinierter Farbe kann nicht gesetzt werden !\n");
    }
}

1;
__END__
# Followin: Go::Node POD

=head1 NAME

Go::Node - A subclass for Go::Board.

=head1 SYNOPSIS

use Go::Node;

=head1 DESCRIPTION

Go::Node manages the internal representation of the stones and determines who and what color their neighbours are etc.
This module is only used by Go::Board. A node represents the intersection upon the game board where one stone can be placed. The nodes have references to their neighbours and in this way enable quick checking if a group of stones has any freedoms left.

=head1 METHODS

=head2 new( $x, $y )

Creates a new Node. $x and $y are information for the node about its position on the board. This method is called by Go::Board::create_nodes().

=head2 set_node_color( $color )

This sets the color of a node. All values below 0 are used for special stones, eg. -1 denotes a free node. The value of a specific color is defined by Go::Board, currently they are: 

=over

=item *

black : 0

=item *

white : 1

=item *

free : -1

=item *

captured : -1

=back

=head2 get_node_color()

Returns the color of the node according to the codes defined above in set_node_color.

=head2 has_friends()

Returns the number of adjacent nodes with the same color.

=head2 has_freedoms()

Returns the number of free adjacent intersections. 

=head2 get_node_pos_str()

Returns a string with the node's position (x, y) on the board. Useful for debugging only.

=head2 group_pos_str()

Returns a string with the positions of a single group (ie, nodes having the same id). Useful for debugging.

=head2 distribute_low_id()

A recursive method of grouping nodes. Each node is given the lowest possible id and adjacent nodes of the
same color get the same id. In this way you can easily determine wether a couple of stones are part of the same group.
This method is used to determine captured stones - you can use Go::Board::get_group_freedoms to see if a group is still alive.
Submethods are:

=head3 set_group_id( $id )

A node is told to which group_id it belongs.

=head3 get_group_id( $id )

Returns a node's group_id.

=head2 add_friend()

Only used during initialisation. The node upon which this method is used now 'remembers' the friend as an adjacent node.

=head2 get_friends()

Returns an array of adjacent Node objects.

=head2 get_captured_friends()

Returns the number of groups also captured in this move. Used for suicide detection or 'false suicide':
If a stone is placed upon a single free intersection, thereby endangering it's own life as well as capturing an enemy
group, only the enemy group is captured. By determining which groups of what color are no longer alife after a proposed move,
one can see if a move will 

=over

=item *

result in the capture of one or more enemy groups -> call Go::Board::remove_stones etc.

=item *

result in the capture of a friendly group -> return 0 and ask for another move - suicide moves are forbidden!

=item *

result in the capture of both my group as well as the opponents -> remove enemy stones! 

=item *

result in no group being lost or captured.

=back

=cut

=head1 TODO

Fix the hard-coded parts of stones/colors.

=head1 BUGS

unknown

=head1 SEE ALSO

Go::Board, Go::Pov

=head1 LICENSE

Distrubuted under the terms of the Perl Artistic License.

=head1 AUTHOR

(C) Ingo Wiarda 2003
