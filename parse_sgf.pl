#!/usr/bin/perl -w
#
# SGF - Parser
#

use strict;


# 1. Ziel: Den Haupt-Stamm ohne Variatonen.

my %options;
foreach( @ARGV ){
    my ($k,$v)  = split /=/, $_;
    $options{$k} = $v;    
    #print $k." = ".$v."\n";
}

$options{'outfile'} ||= 'game.dat';
$options{'file'} ||= 'game.sgf';
my $sgf_str; # = ${ load_sgf($options{"file"}) };



$sgf_str = <<'SGF';
(;US[JBvR]SO[My Friday Night Files]DT[2003-01-26]KM[6.5]RE[B+R]SZ[19]EV[2003 Ricoh Cup Pair Go Final]PB[Inori Yoko & Cho Chikun]PW[Yoshida Mika & Kobayashi Koichi];B[pd];W[dd];B[pq];W[dp];B[qk];W[lp];B[fq]
;W[hq];B[dn];W[fp];B[gp];W[gq];B[cp];W[eq];B[cq];W[cl];B[fr];W[er];B[fo];W[ep]
;B[bn];W[nc];B[pf];W[pb];B[qc];W[kc];B[np];W[cf];B[je];W[ne];B[jc];W[jd];B[id]
;W[kd];B[ie];W[ic];B[hc];W[jb];B[nf];W[ok];B[pm];W[qq];B[qr];W[pp];B[oq];W[rr]
;B[rq];W[qp];B[sr];W[rs];B[qs];W[no];B[mo];W[nn];B[mp];W[pn];B[om];W[qm];B[ql]
;W[rm];B[ml];W[nm];B[nl];W[ol];B[pl];W[ln];B[lo];W[ll];B[nj];W[rp];B[ss];W[oj]
;B[mj];W[pi];B[ri];W[og];B[pg];W[of];B[oh];W[rh];B[qi];W[ph];B[oi];W[qh];B[pj]
;W[pe];B[qe];W[oe];B[qf];W[ni];B[nh];W[mh];B[mi];W[ng];B[ni];W[di];B[on];W[oo]
;B[qn];W[rn];B[po];W[qo];B[pn];W[op];B[lm];W[km];B[mm];W[mn];B[kn];W[ko];B[jn]
;W[nq];B[mq];W[nr];B[sp];W[ro];B[or];W[os];B[pr];W[mr];B[lq];W[lr];B[kp];W[kr]
;B[jq];W[rr];B[rs];W[rl];B[rk];W[so];B[sl];W[sq];B[ce];W[rr];B[de];W[ps];B[ed]
;W[hb];B[dc];W[cm];B[cn];W[bf];B[eg];W[el];B[ei];W[dh];B[dg];W[cg];B[gc];W[li]
;B[lk];W[ds];B[cr];W[eh];B[fh];W[bd];B[be];W[ae];B[dj];W[cj];B[ch];W[ci];B[go]
;W[ip];B[jp];W[ir];B[lh];W[cd];B[ee];W[cc];B[lf];W[gj];B[fj];W[io];B[iq];W[hp]
;B[jo];W[gk];B[fk];W[gl];B[fl];W[gm];B[in];W[fm];B[dm];W[fg];B[gh])

SGF

    if ($options{'goip'}){
	
	load_goip();
    }
else
{
    sgf_parse($sgf_str);
}

sub sgf_parse{
    my ($sgf) = @_;
    my $tree;
    
    # Use single Games, no Collections.
    # print $sgf;

    $sgf =~ m/\((.+)\)/ms;
    $tree = $1;
          
    while($tree =~ m/(;|\(;)?(\w+\[[^\]]*\])/g){
	my $a = translate_points($2);
	if ($a ne "0"){
	    print $a."\n";
	}
    } 
}

sub translate_points{
    my ($prop) = @_;
    my $dim_y = $options{'y'} || "19";    
    my %stones = (
		  B => 0,
		  W => 1,
		  );
    my $color;
    my ($x, $y);
    if ($prop =~ m/(W|B)\[(\w)(\w)\]/){
	$color = $stones{$1};       
	$x = ord($2) - ord("a");
	$x++;
	$y = $dim_y - (ord($3) - ord('a') +1);
	$y++;
	
	return "$x $y $color";
       
    }
    return 0;
}

sub load_goip{
    # load go in perl

    open(GO, $options{'file'}) or die "Konnte goip-Datei nicht finden.\n";
    # FF[4] = File Format Version #4
    # GM[1] = Game Mode 1 = Go
    # SZ[19] = Size, \d+ für Quadrat, \d+:\d+ für Rechteck. max 52x52
    print "(;FF[4]GM[1]SZ[19]";
    while(<GO>){
	chomp;
	my ($x, $y, $color) = split / /, $_;
	my $col = $color ? "W" : "B";
	if ($x =~ m/\D/){
	    $x = ord($x) - ord('a') +1;
	}
	$x = chr($x+ord('a')-1);
	$y = chr($y+ord('a')-1);
	print ";".$col."[".$x.$y."]";
    }
    print ")";
    close(GO);
}

sub add_node{
    my ($node) = @_;
    
}

sub load_sgf{
    my ($file) = @_;
    my $str; 

    open(SGF, $file) or die "Konnte Datei $file nicht öffnen!\n";
    while(<SGF>){
	chomp;
	# remove new_lines;
	$str .= $_." ";
	
    }
    return \$str;
}
