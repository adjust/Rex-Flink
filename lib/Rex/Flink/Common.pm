package Rex::Flink::Common;

# ABSTRACT: common code for Rex::Flink automation

use strict;
use warnings;

our $VERSION = '9999';

use File::ShareDir 'dist_dir';
use Rex -base;
use Rex::CMDB;

my $dist_share_dir = dist_dir('Rex-Flink');

if ( !-d 'cmdb' ) {    # if there is no local CMDB
    my $cmdb_path;
    if ( -d 'share/cmdb' ) {
        $cmdb_path = 'share/cmdb';    # use the CMDB under share if exists
    }
    else {
        # use the installed CMDB otherwise
        $cmdb_path = "$dist_share_dir/cmdb";
    }

    set cmdb => { type => 'YAML', path => $cmdb_path };
}

set path_map => { 'templates/' =>
      [ 'templates/', "$dist_share_dir/templates", 'share/templates' ], };

my $flink = get cmdb 'flink';

my $install_path = $flink->{install_path} // '~/flink';
my $flink_dir = "$install_path/current";

set flink => {
    cmdb         => $flink,
    install_path => $install_path,
    flink_dir    => $flink_dir,
};

1;

__END__

=for :stopwords CMDB namespace

=head1 SYNOPSIS

    use Rex::Flink::Common;

    my $flink = get 'flink';

=head1 DESCRIPTION

This module contains common code for the various modules in the Rex::Flink namespace.

It sets CMDB path and C<path_map>, and also registers the C<flink> configuration parameter.

=head1 DIAGNOSTICS

This module does not do any error checking (yet).

=head1 CONFIGURATION AND ENVIRONMENT

See L<Rex::Flink/CONFIGURATION AND ENVIRONMENT>.

=head1 DEPENDENCIES

See L<Rex::Flink/DEPENDENCIES>.

=head1 INCOMPATIBILITIES

There are no known incompatibilities with other modules.

=head1 BUGS AND LIMITATIONS

There are no known bugs. Make sure they are reported.
