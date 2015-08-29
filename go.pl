#!/usr/bin/perl -w
# PerlGo - available under the Perl Artistic License
# a Go programm. (C) Ingo Wiarda 2002
use strict;
use Go::Board;
use Go::UI;

my $version = "0.1.7";

my %stones = (
	      black => 0,
	      white => 1,
	      free => -1,
	      captured => -2,
	      ); #also used in Go::UI::Text.pm

my %options;

import_config('default.config', 'my.config');

foreach( @ARGV ){
    my ($key, $value)  = split /=/, $_;
    $options{$key} = $value;    
}

export_config('my.config') unless $options{'save_config'} eq 'no';

@ARGV = (); #??

print "This is PerlGo, version $version. (C) Ingo Wiarda 2003\n";
print "Availalbe under the (Perl) Artistic License\n";
print "Options are passed like this: foo=bar, eg: go.pl os=linux (default) sets os to Linux.\n";
print "Options:\n print=0|1: print ASCII-Board (default 1)\n pov=1|0 : use PovRay (default: 1)\n x=number y=number: set Board Size. Default is 9x9\n";
print " ask=1|0: Ask for moves (debugging option, default 0)\n";
print " filename=name: filename of saved game (default: game.dat)\n\n";
print "Options will be saved to my.config and reused next time.\n";

my $go = Go::Board->new(x_size => $options{'x'},
			y_size => $options{'y'},
			shape => $options{'shape'},
			);
print "Go Board successfully created!\n";
my ($x, $y) = $go->get_board_dimensions();
print "Board Dimensions $x x $y\n";
Go::Board::set_options(\%options);

# $go->dump_board('print');
my $ui = choose_ui( 'type' => $options{'user_interface'},
		    'numbering_x' => $options{'numbering_x'},
		    'numbering_y' => $options{'numbering_y'},
		    'score' => $options{'score'},
		    'board' => $go );

if ( $ui == 0 ){ 
    die ("Could not find a User Interface!\n");
}

$go->add_user_interface($ui); # theoretically, we can have more than one UI.


if ($options{'autoplay'}){
    autoplay($go, $options{'filename'});
}
else{
    play($go);
}

play($go);

sub play{
    my ($board) = @_;
    
    my ($x, $y);

    #$board->place_stone(1,1,0);
    #$board->dump_board("print" => 1, "pov"=>1,);
    #$board->place_stone(1,2,1);
    #$board->dump_board("print" => 1, "pov"=>1,);
    #$board->place_stone(3,3,0);
    #$board->dump_board("print" => 1, "pov"=>1,);
    #$board->place_stone(2,1,1);

  
    while( $board->get_current_move() < $board->get_max_moves() ){

      BLACK:{

	  $board->dump_board("pov" => $options{'pov'});
	  $ui->show_board();
	  $board->set_current_player( $stones{'black'});

	  $ui->display_move_number();

	  ($x, $y) = $ui->get_move();

	  if ($x =~ m/redo|goto|undo/){
	      if ($board->get_current_player() eq $stones{'black'} ){
		  redo BLACK;
	      }
	      else{
		  goto WHITE;
	      }
	  }
	  else{
	      $board->place_stone($x, $y, $stones{"black"} ) or redo BLACK;
	  }

      }

      WHITE:{

	  $board->dump_board("pov" => $options{'pov'});
	  $ui->show_board();
	  $board->set_current_player( $stones{'white'});

	  $ui->display_move_number();

	  ($x, $y) = $ui->get_move();
	  if ($x =~ m/redo|goto|undo/){
	      if ($board->get_current_player() eq $stones{'white'} ){
		  redo WHITE;
	      }
	      else{
		  goto BLACK;
	      }
	  }
	  else{
	      $board->place_stone($x, $y, $stones{"white"} ) or redo WHITE;
	  }

      }


	# print "Züge bisher: ";

    }
    print "\nGame finished. Thank you for playing.\n";
    print "Game will be saves as $options{'filename'}\n";
    # $filename should be checked for validity.
    $board->dump_board('print' => 1,
		       'save' => 1,
		       'filename' => $options{'filename'},
		       );
    exit;
}

sub autoplay{
    my ($self, $filename) = @_;
    
    open(GAME, $filename) or die "Konnte Datei $filename mit den Spieldaten nicht öffnen.\n";

    $ui->show_board();
    $self->dump_board("pov" => $options{'pov'});

    my $moves = 0;

    while(<GAME>){
	chomp;
	my $ask = -1;
	my ($x, $y, $color) = split / /, $_;

	# go.pl expects the moves to be y, x.

	last unless $_;

	$self->set_current_player($color);
	$ask = $self->place_stone($x,$y,$color);

	$ui->show_board();
	$ui->display_move_number();

	$self->dump_board("pov" => $options{'pov'});

	if ($options{'ask'} eq 2 || ( $ask == 0 && $options{'ask'} eq 1) ){
	    print "Weiter?\n";
	    $ask = <>;	    
	    if (length($ask) > 0){
		last;
	    }
	}
    }
}


sub import_config{
=head1 import_config( @config_filenames )

Load config files and set the values in %options according to the values.
The values in one file are superseeded by the following files. This way, 
'cascading configuration' is possible.

=cut

    my @conf_files = @_;
    my ($value, $key, $str);
    foreach( @conf_files ){
	open( CONF, "<$_") or 
	    warn("Could not open configuration file ".$_."\n") &&
	    next;
	
	print "Loading configuration file: ".$_."\n";

	while( <CONF> ){
	    chomp;
	    $str = $_;
	    next if $str =~ /^$|^\#/;
	    ($key, $value) = split /=/, $str;

	    $options{$key} = $value;	    
	}
    }
}

sub export_config{
=head1 export_config( $filename )

Save the current configuration to a file which is usable by other modules.

=cut

my ($filename) = @_;
open(CONF, ">$filename") or warn('Could not save configuration file '.$_."\n");
foreach my $key ( sort keys %options ){
    print CONF $key."=".$options{ $key }."\n";
}
close(CONF);
}
