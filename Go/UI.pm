package Go::UI;
# a package for managing all user-interface questions for perlgo.

# Go::UI should provide generic methods, eg.
# - providing a clock
# - checking for user privileges (may a remote_user save the game to your HD?)
#   a method like $ui->check_write_permission() may help here.
use Go::UI::Text;
use Exporter;
@ISA = ('Exporter');
@EXPORT = qw(&choose_ui);

use strict;

my %interfaces = (
		  text => "1",
		  );

sub choose_ui{
    my %options = @_;
    my $ui_ref;
    
    my $type = $options{'type'};

    if (exists $interfaces{ $type } ){
	if ($type eq 'text'){
	    $ui_ref = Go::UI::Text->new( \%options );
	    return $ui_ref;
	}
    }
    else{
	warn('You have choosen an invalid UserInterface!\n');
	return 0;
    }
}

sub undo{
    my ($self) = @_;
    my $board = $self->{'board'};

    my $current_move = $board->get_current_move();
    # print "Current Move: $current_move\n";
    
    if ( $current_move > 1 &&
	 $current_move < $board->get_max_moves()){

	$board->set_last_action('undo'); 
	$board->goto_move( $current_move - 1 );

	return 1;

    }
    else{
	return 0;
    }
}

sub redo_move{
    my ($self) = @_;
    my $board = $self->{'board'};
    my $next_move = $board->get_current_move() +1;

    #print "$next_move ".$board->count_moves()."\n";

    if ( $next_move <= $board->get_max_moves() &&
	 $next_move <= $board->count_moves()+1	 ){

	$board->set_last_action('redo');
	$board->goto_move( $next_move );
	return 1;

    }
    else{
	return 0;
    }

}

sub try_goto{
    my ($self, $steps) = @_;
    my $board = $self->{'board'};
    my $next_move = $board->get_current_move() + $steps;

    #print "$next_move ".$board->count_moves()."\n";
    $board->set_last_action('goto');

    if ( $next_move <= $board->get_max_moves() &&
	 $next_move <= $board->count_moves()+1 &&
	 $next_move >= 1
	 ){

	$board->goto_move( $next_move );
	return 1;

    }
    elsif( $next_move > $board->count_moves()+1 ){
	$board->goto_move( $board->count_moves()+1 );
	return 1;
    }
    elsif( $next_move < 1 ){
	$board->goto_move( 1 );
	return 1;
    }
    else{
	return 0;
    }
}

sub get_board_ref{
    my ($self) = @_;
    return $self->{'board'};
}

sub get_numbering_x{
    my ($self) = @_;
    return $self->{'numbering_x'};
}

1;

__END__


=head1 NAME Go::UI.pm

The User-Interface for PerlGo

=head1 SYNOPSIS

use Go::UI;

=head1 DESCRIPTION

UI.pm provides basic methods for all interfaces and lets go.pl choose the 'right' interface type.

=head1 FUNCIONS

=head2 choose_ui( %options )

The %options-hash should at least contain a ('type' => 'interface') like 'text'. Other keys/values are passed on to the UI-object created then.

=head1 METHODS

=head2 undo()

Sets the board back 1 move.

=head2 redo_move()

Sets the board forward 1 move. Returns 0 if this move has not been played yet, 1 otherwise.

=head2 try_goto( $number )

Go forward or backward $number moves, depending on wether it is a positive or negative number. Currently, if the number is too large, the maximum will be choose. Eg, trying to go for move 1000 will move the board to the last recorded move. Going for -1000 will display the board at move 1.

=head2 get_board_ref()

Returns a ref to the object's board.

=head2 get_numbering_x()

Returns the numbering-options for the current UI. At the moment, the text-interface supports 'az' and 'gnugo' as values for 'numbering_x'

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
