package Rex::Flink;

# ABSTRACT: automate Flink tasks with Rex

use strict;
use warnings;

BEGIN {
    use Rex::Shared::Var;
    share qw($flink_dir $install_path);
}

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

$install_path = $flink->{install_path} // '~/flink';
$flink_dir = "$install_path/current";

desc 'Setup Flink from tarball';
task 'setup' => sub {
    my $params = shift;

    my $version = $params->{version} // $flink->{version} // '1.2.0';
    my $hadoop  = $params->{hadoop}  // $flink->{hadoop}  // '27';
    my $scala   = $params->{scala}   // $flink->{scala}   // '2.11';

    my $filename = "flink-${version}-bin-hadoop${hadoop}-scala_${scala}.tgz";
    my $url
      = "http://mirror.serversupportforum.de/apache/flink/flink-${version}/$filename";

    my $tmp_dir  = Rex::Config::get_tmp_dir();
    my $tmp_file = "$tmp_dir/$filename";

    run "curl --location $url --output $tmp_file", creates => $tmp_file;
    extract $tmp_file, to => $install_path;

    symlink "$install_path/flink-${version}", $flink_dir;

    needs 'configure';
};

desc 'Configure Flink from a template file';
task 'configure' => sub {
    file "$flink_dir/conf/flink-conf.yaml",
      content => template( $flink->{config_file} );
};

desc 'Start Flink in local mode';
task 'start' => sub {
    run 'bin/start-local.sh', cwd => $flink_dir;
};

desc 'Stop Flink in local mode';
task 'stop' => sub {
    run 'bin/stop-local.sh', cwd => $flink_dir;
};

1;

__END__

=for :stopwords CMDB CPAN Flink hadoop Hadoop libvirt scala VM YAML

=head1 SYNOPSIS

    # Rexfile
    use Rex::Flink;

    # CLI
    $ rex Flink:setup
    $ rex Flink:start
    $ rex Flink:stop

=head1 DESCRIPTION

This module automates Flink tasks with Rex.

B<Please note this is a work still heavily in progress, the interface might be subject to change before version 1.0.0.>

=task Flink:setup

Sets Flink up from binary tarball. The installation directory can be controlled from CMDB via C<install_path>. Default is C<~/flink>.

Supported options:

=begin :list

= --hadoop
Hadoop version (default: C<27>)

= --scala
Scala version (default: C<2.11>)

= --version
Flink version (default: C<1.2.0>)

=end :list

=task Flink:configure

Configures Flink from a file, which is treated as a standard Rex template. The name of the file to be deployed can be controlled from CMDB via C<config_file>. Default is C<templates/flink-conf.yaml>.

=task Flink:start

Starts Flink in local mode.

=task Flink:stop

Stops Flink in local mode.

=head1 DIAGNOSTICS

This module does not do any error checking (yet).

=head1 CONFIGURATION AND ENVIRONMENT

This module can use configuration specified under the C<flink> node in the CMDB. Example YAML structure:

 flink:
     config_file: templates/flink-conf.yaml
     hadoop: 27
     install_path: ~/flink
     scala: 2.11
     version: 1.2.0

This module does not use any environment variables. See also L<TESTING>.

=head1 DEPENDENCIES

This module depends on the modules detailed below.

CPAN modules:

=for :list
* Rex

=head1 INCOMPATIBILITIES

There are no known incompatibilities with other modules.

=head1 BUGS AND LIMITATIONS

There are no known bugs. Make sure they are reported.

=head1 TESTING

This module is capable to do testing with the help of the C<Rex::Test> module inside a VM via libvirt.

A URL pointing to a VM image to be used for the testing should be specified via the C<REX_FLINK_TEST_IMAGE> environment variable. For example:

 # CLI
 $ REX_FLINK_TEST_IMAGE='file:///var/lib/livirt/images/image.qcow2' rex Test:run
 $ REX_FLINK_TEST_IMAGE='https://domain.tld/image.qcow2' rex Test:run
