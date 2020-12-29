package Koha::Plugin::No::Libriotech::CapturePW;

use Modern::Perl;
use Digest::MD5 qw( md5_hex );

## Required for all plugins
use base qw(Koha::Plugins::Base);

our $VERSION = "0.0.1";

## Here is our metadata, some keys are required, some are optional
our $metadata = {
    name            => 'CapturePW TEST',
    author          => 'Magnus Enger',
    date_authored   => '2020-12-29',
    date_updated    => '2020-12-29',
    minimum_version => '20.11',
    maximum_version => undef,
    version         => $VERSION,
    description     => 'Test the capture_raw_password plugin hook. DO NOT apply to a production system.',
};

=head1 new()

Standard for all plugins.

=cut

sub new {
    my ( $class, $args ) = @_;

    ## We need to add our metadata here so our base class can access it
    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    ## Here, we call the 'new' method for our base class
    ## This runs some additional magic and checking
    ## and returns our actual $self
    my $self = $class->SUPER::new($args);

    return $self;
}

=head1 capture_raw_password()

This is the plugin subroutine that gets called from inside the Koha code.

=cut

sub capture_raw_password {

    my ( $self, $args ) = @_;

    my $borrowernumber = $args->{'borrowernumber'};
    my $password       = $args->{'password'};
    my $md5            = md5_hex( $password );

    my $dbh = C4::Context->dbh;

    my $table = $self->get_qualified_table_name('capturepw');

    $dbh->do( "INSERT INTO $table ( borrowernumber, pw ) VALUES ( ?, ? )",
        undef, ( $borrowernumber, $md5 ) );

}

## This is the 'install' method. Any database tables or other setup that should
## be done when the plugin if first installed should be executed in this method.
## The installation method should always return true if the installation succeeded
## or false if it failed.
sub install() {
    my ( $self, $args ) = @_;

    my $table = $self->get_qualified_table_name('capturepw');

    return C4::Context->dbh->do( "
        CREATE TABLE IF NOT EXISTS $table (
            `borrowernumber` INT( 11 ) NOT NULL,
            `pw` CHAR( 32 ) NOT NULL
        ) ENGINE = INNODB;
    " );
}

## This method will be run just before the plugin files are deleted
## when a plugin is uninstalled. It is good practice to clean up
## after ourselves!
sub uninstall() {
    my ( $self, $args ) = @_;

    my $table = $self->get_qualified_table_name('capturepw');

    return C4::Context->dbh->do("DROP TABLE IF EXISTS $table");
}

1;

=head1 AUTHOR

Magnus Enger <magnus@libriotech.no>

=head1 COPYRIGHT

Copyright 2019 Libriotech AS

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the terms
of the GNU General Public License as published by the Free Software Foundation;
either version 3 of the License, or (at your option) any later version.

You should have received a copy of the GNU General Public License along with
Koha; if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
Fifth Floor, Boston, MA 02110-1301 USA.

=cut
