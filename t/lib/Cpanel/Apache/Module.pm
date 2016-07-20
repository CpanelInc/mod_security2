# cpanel - Cpanel::Apache::Module                 Copyright(c) 2016 cPanel, Inc.
#                                                           All rights Reserved.
# copyright@cpanel.net                                         http://cpanel.net
# This code is subject to the cPanel license. Unauthorized copying is prohibited
package Cpanel::Apache::Module;

use strict;
use warnings;

use Carp;
use Tree::DAG_Node;

sub new {
    my $type = shift;
    my $class = ref($type) || $type;

    my $self = {};
    bless $self, $class;

    $self->{'root'} = Tree::DAG_Node->new();
    $self->{'root'}->name('root');

    return $self;
}

sub parse {
    my $filename  = shift;
    my $newModule = Cpanel::Apache::Module->new();
    open( my $handle, '<', $filename )
      or Carp::croak("Cannot read from $filename: $!");
    my $currentNode = $newModule->{'root'};
    while ( my $line = <$handle> ) {
        chomp $line;
        my $ifModuleBegin      = index( $line, "\<IfModule " );
        my $ifModuleCloseBegin = index( $line, "\</IfModule>" );
        if ( $ifModuleBegin == -1 && $ifModuleCloseBegin == -1 ) {
            my $newDaughter = $currentNode->new_daughter;
            $newDaughter->name('text');
            $newDaughter->attributes( { 'text' => $line } );
            $currentNode->add_daughter($newDaughter);
            next;
        }
        if ( $ifModuleCloseBegin != -1 ) {
            my $before = substr( $line, 0, $ifModuleCloseBegin );
            my $newDaughter = $currentNode->new_daughter;
            $newDaughter->name('text');
            $newDaughter->attributes( { 'text' => $before } );
            $currentNode->add_daughter($newDaughter);

            my $ifModule = substr( $line, $ifModuleCloseBegin, $ifModuleCloseBegin + 11 );
            $currentNode = $currentNode->mother();

            my $after = substr( $line, $ifModuleCloseBegin + 11 );
            $newDaughter = $currentNode->new_daughter;
            $newDaughter->name('text');
            $newDaughter->attributes( { 'text' => $after } );
            $currentNode->add_daughter($newDaughter);
            next;
        }
        my $ifModuleEnd = index( $line, ">", $ifModuleBegin );
        if ( $ifModuleEnd != -1 ) {
            my $before = substr( $line, 0, $ifModuleBegin );
            my $newDaughter = $currentNode->new_daughter;
            $newDaughter->name('text');
            $newDaughter->attributes( { 'text' => $before } );
            $currentNode->add_daughter($newDaughter);

            my $ifModule = substr( $line, $ifModuleBegin, $ifModuleEnd + 1 );
            $newDaughter = $currentNode->new_daughter;
            $newDaughter->name('node');
            $newDaughter->attributes( { 'text' => $ifModule } );
            $currentNode->add_daughter($newDaughter);
            $currentNode = $newDaughter;

            my $after = substr( $line, $ifModuleEnd + 1 );
            $newDaughter = $currentNode->new_daughter;
            $newDaughter->name('text');
            $newDaughter->attributes( { 'text' => $after } );
            $currentNode->add_daughter($newDaughter);
        }
    }

    #print map "$_\n", @{$newModule->{'root'}->tree2string};
    return $newModule;
}

sub getNodes {
    my $self    = shift;
    my $type    = shift;
    my $pattern = shift;

    my @modules = ();

    foreach my $daughter ( $self->{'root'}->descendants() ) {
        if ( $daughter->name eq $type && $daughter->attributes->{'text'} =~ /$pattern/ ) {
            push( @modules, $daughter );
        }
    }

    return @modules;
}

sub getNodesWithin {
    my $self    = shift;
    my $root    = shift;
    my $type    = shift;
    my $pattern = shift;

    my @nodes = ();
    foreach my $daughter ( $root->daughters() ) {
        if ( $daughter->name eq $type && $daughter->attributes->{'text'} =~ /$pattern/ ) {
            push( @nodes, $daughter );
        }
    }
    return @nodes;
}

1;
