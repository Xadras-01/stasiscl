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

package Stasis::ExtensionRunner;

use strict;
use warnings;

sub new {
    my $class = shift;
    my %exts;
    my %handlers;
    
    $handlers{ALL} ||= [];

    foreach (@_) {
        my $ext = Stasis::Extension->factory($_);
        my @actions = $ext->actions();
        
        # Assign this to %exts
        $exts{$_} = $ext;
        
        if( @actions ) {
            # Only listening for certain actions.
            foreach my $action (@actions) {
                $handlers{$action} ||= [];
                push @{$handlers{$action}}, $ext;
            }
        } else {
            push @{$handlers{ALL}}, $ext;
        }
    }
    
    bless {
        exts => \%exts,
        handlers => \%handlers,
    }, $class;
}

sub start {
    foreach (values %{$_[0]->{exts}}) {
        $_->start();
    }
}

sub process {
    if( my $handlers = $_[0]->{handlers}{ $_[1]->{action} } ) {
        foreach my $h (@$handlers) {
            $h->process($_[1]);
        }
    }
    
    foreach my $h (@{$_[0]->{handlers}{ALL}}) {
        $h->process($_[1]);
    }
}

sub finish {
    foreach (values %{$_[0]->{exts}}) {
        $_->finish();
    }
}

1;
