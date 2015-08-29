package Go::UI::Text;
# module to handle input & output for PerlGo in textmode.

use Exporter;
@ISA = ('Exporter', 'Go::UI');
@EXPORT = qw(&get_move);
use strict;

my %pieces = (
	      -1 => ".",
	      -2 => "*",
	      0 => "X",
	      1 => "O",
	      );

my %stones = (
	      black => 0,
	      white => 1,
	      free => -1,
	      captured => -2,
	      );

sub new{
    my ($class, $option_ref) = @_;
    my %options = %{ $option_ref };
    my $obj = {
	       board => $options{'board'}, # ref of a Go::Board-Object.
	       numbering_x => $options{'numbering_x'},
	       numbering_y => $options{'numbering_y'},
	       score => $options{'score'},
	       };

    bless $obj, $class;

}

sub get_move{
    my ($self) = @_;
    my ($move, $x, $y);
    my $board = $self->get_board_ref();

    $move = <>;
    if( $move =~ m/quit|exit|^$/ ){
	$self->{'board'}->dump_moves('print' => 0,
			'save' => 1);
	exit;
    }
    elsif( $move =~ m/^Undo$|^-1?$/){
	if ($self->undo()){
	    return 'undo';
	}
	else{
	    print "Undo not possible!\n";
	    $self->display_move_number();
	    return $self->get_move();
	}
    }
    elsif( $move =~ m/^Redo$|^\+1?$/){
	if ($self->redo_move()){
	    return 'redo';
	}
	else{
	    print "Redo / Advance not possible!\n";
	    $self->display_move_number();
	    return $self->get_move();
	}
    }
    elsif( $move =~ m/^(?:Goto\s+)?((?:\+|-)?\d+)$/){
	my $go = $1;
	if ($go =~ m/^\d+$/){
	    $go -= $board->get_current_move();
	}
	if ($self->try_goto($go)){
	    return 'goto';
	}
	else{
	    # this should not happen - 
	    # try_goto 'always' returns 1...
	    print "Move not possible!\n";
	    $self->display_move_number();
	    return $self->get_move();
	}
    }
    elsif ($move =~ m/(\d+|\w+)\s*(\d+|\w+)/){
	$x = $2;
	$y = $1;
	if ($y =~ m/\D/){
 	    $y = ord(uc($y)) - ord("A");
	    $y++;
	}
	if ($x =~ m/\D/){
 	    $x = ord(uc($x)) - ord("A");
	    $x++;
	}
	
	return ($x, $y);
    }
    else{
	return $self->get_move();
    }
}

sub display_move_number{
    my ($self) = @_;
    my $board = $self->get_board_ref();
    my $player = $board->get_current_player();
    my $move = $board->get_current_move();
   
    # print "display: player: $player\n";
    if ($board->get_board_shape eq 'rectangle' || $board->get_board_shape eq 'toroid'){
	print $move.($player eq $stones{'white'} ? " White (O):" : " Black (X):");
    }
    elsif($board->get_board_shape eq 'circles'){
	print $move.($player eq $stones{'white'} ? " White (O):" : " Black (X): [circle, ray]");
    }

}

sub show_board{
    my ($self) = @_;    
    my $board = $self->get_board_ref();
    
    $board->create_board_array();

    my $x_axis;
    my ($x, $y) = $board->get_board_dimensions();
    my $start = ord("A");
    my $end = $start+$x-1;

    my $pcount;

    my %pov_cols = (
		    0 => "Black",
		    1 => "White",
		    -2 => "Captured",	      
		    );

    # a line feed:
    print "\n";

    # Numbering the board:

    my @aleph = map { chr($_) } ($start..$end);

    # 'az' : the board is numbered with letters (A..Z), not skipping 'I'
    if ($self->get_numbering_x() eq 'az'){ 
	$x_axis = "   ".join(" ", @aleph)."\n";
    }
    
    # 'gnugo' : the board is numbered A..Z, skipping I. get_moves must consider this, too...
    if ($self->get_numbering_x() eq 'gnugo'){

	splice( @aleph, ord('I')-$start, 1);
	$x_axis = "   ".join(" ", @aleph)."\n";
    }

    print $x_axis;

    for my $count (reverse 1..$x){
	
	$board->{"board"}[$count][0] = $count;
	
	my @stone = map { $pieces{$_} } @{$board->{"board"}[$count]};
	
	if ( $count < 10 ){ 
	    $pcount = " ".$count; 	       
	}
	else{
	    $pcount = $count;
	}
	
	$stone[0] = $pcount;	  

	print join(" ", (@stone, " ".$pcount))."\n";	    
	
    }

    print $x_axis;
    
    my @captured = sort keys %{ $board->{'captured_stones'} }; #breaking the clean OO-Design 
    
    if ($#captured > -1){
	print "\nStones captured by ";
	    foreach( @captured ){
		print $pov_cols{$_}.": ".$board->get_captured_stones($_)." ";
	    }
	print "\n";
    }
    
    if(  $self->{'score'} && $board->count_moves() > 1 ){
	print "Score: ";
	foreach('black', 'white'){
	    #unclean, unclean!
	    print " ".$_.": ".$board->get_score( $stones{ $_ });
	}
	print "\n";
    }
    
}


1;

__END__


=head1 NAME Go::UI::Text.pm

A user interface for text-mode.

=head1 SYNOPSIS

Used internally by Go::UI.pm

=head1 DESCRIPTION

Text.pm provides a text-based interface for PerlGo.

=head1 METHODS

=head2 new( \%options )

Creates a new UI object which inherits some methods from Go::UI.pm

=head2 get_move()

Gathers input from keyboard and will recognize 'exit', 'quit', 'Undo' or valid coordinates for the board.

=head2 display_move_number()

Prints a string "Move $number $color ($marker):n"

=head2 show_board()

Prints the board, numbered in GnuGo- or normal style.

=BUGS

unknown

=AUTHOR

Ingo Wiarda 2003

=LICENSE

You may use and distribute this script under the Perl Artistic License.

=cut
