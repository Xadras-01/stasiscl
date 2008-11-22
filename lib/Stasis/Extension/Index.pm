# Copyright (c) 2008, Gian Merlino
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#    1. Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#    2. Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package Stasis::Extension::Index;

use strict;
use warnings;
use Stasis::SpellUtil;
use Stasis::Extension;
use Stasis::Parser;

our @ISA = "Stasis::Extension";

sub start {
    my $self = shift;
    $self->{actors} = {};
    $self->{spells} = {};
}

sub actions {
    map { $_ => \&process } keys %Stasis::Parser::action_map;
}

sub process {
    my ($self, $entry) = @_;
    
    # The purpose of this index is to associate IDs with names.
    
    # ACTOR INDEX: check actor
    if( $entry->{actor} ) {
        $self->{actors}{ $entry->{actor} } = $entry->{actor_name};
    }
    
    # ACTOR INDEX: check target
    if( $entry->{target} ) {
        $self->{actors}{ $entry->{target} } = $entry->{target_name};
    }
    
    # SPELL INDEX: check for spellid
    if( $entry->{spellid} ) {
        $self->{spells}{ $entry->{spellid} } = $entry->{spellname};
    }
    
    # SPELL INDEX: check for extraspellid
    if( $entry->{extraspellid} ) {
        $self->{spells}{ $entry->{extraspellid} } = $entry->{extraspellname};
    }
}

sub spellname {
    my ($self, $spell, $no_rank) = @_;
    if( $spell ) {
        if( $self->{spells}{$spell} ) {
            my $sd = Stasis::SpellUtil->spell($spell);
            my $r = !$no_rank && $sd && $sd->{rank};
            
            if( $r && $r =~ /^[0-9]+$/ ) {
                $r = "r$r";
            }
            
            if( wantarray ) {
                return ($self->{spells}{$spell}, $r);
            } else {
                return $self->{spells}{$spell} . ($r ? " ($r)" : "");
            }
        } else {
            return $spell;
        }
    } else {
        return "Melee";
    }
}

sub actorname {
    return $_[1] ? $_[0]->{actors}{ $_[1] } || $_[1] : "Environment";
}

sub spellid {
    my ($self, $wantname) = @_;
    
    $wantname = $self->{spells}{$wantname} if $wantname && $wantname =~ /^[0-9]+$/;
    
    if( wantarray ) {
        my @ret;
        while( my ( $id, $name ) = each (%{$self->{spells}}) ) {
            push @ret, $id if $name eq $wantname;
        }
        
        return @ret;
    } else {
        while( my ( $id, $name ) = each (%{$self->{spells}}) ) {
            return $id if $name eq $wantname;
        }
    }
}

1;
