package CPAN::IndexPod;
use strict;
use warnings;
use File::Find::Rule;
use Plucene::Simple;
use Pod::Simple;
use Pod::Simple::PullParser;
use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(unpacked plucene));

our $VERSION = '0.22';

sub new {
  my $class = shift;
  my $self = {};
  bless $self, $class;
  return $self;
}

sub search {
  my $self = shift;
  my $search = shift;
  my $plucypath = $self->plucene;

  my $plucy = Plucene::Simple->open($plucypath);
  return $plucy->search($search);
}

sub index {
  my $self = shift;
  my $unpacked = $self->unpacked;
  my $plucypath = $self->plucene;

  my $plucy = Plucene::Simple->open($plucypath);

  chdir($unpacked) || die "Could not chdir to $unpacked: $!";

  my $rule = File::Find::Rule->new;
  my @files = $rule->file->in(".");

  foreach my $filename (@files) {
    next if $filename =~ /\.svn/;
    eval {
      my $parser;
      $parser = Pod::Simple::PullParser->new;
      $parser->set_source($filename);

      my $title = $parser->get_title;
      return unless $title;

      my $synopsis = $parser->_get_titled_section(
       'SYNOPSIS',
        max_token => 400,
        max_content_length => 3_000,
        desperate => 1,
      );

      my $description = $parser->get_description;

      $plucy->index_document($filename => "$title $synopsis $description");
    };
  }

  $plucy->optimize;
}

1;

__END__


=head1 NAME

CPAN::IndexPod - Index the POD from an upacked CPAN

=head1 SYNOPSIS

  my $i = CPAN::IndexPod->new;
  $i->unpacked("/unpacked/cpan/); # use CPAN::Unpack
  $i->plucene("/plucene/index);   # must be absolute path
  $i->index;

  # Then search with Plucene / Plucene::Simple or:
  my @files = $i->search("vampire");

=head1 DESCRIPTION

The Comprehensive Perl Archive Network (CPAN) is a very useful
collection of Perl code. It has a whole lot of module
distributions. CPAN::Unpack unpacks CPAN distributions. This module
will analyse the unpacked CPAN, index the Pod it contains, and allow
you to search it.

Right now it allows simplistic searching of NAME, SYNOPSIS and
DESCRIPTION sections and returns a list of filenames.

=head1 AUTHOR

Leon Brocard <acme@astray.com>

=head1 COPYRIGHT

Copyright (C) 2004, Leon Brocard

This module is free software; you can redistribute it or modify it under
the same terms as Perl itself.
