package Rex::Flink;

# ABSTRACT: automate Flink tasks with Rex

use strict;
use warnings;

BEGIN {
    use Rex::Shared::Var;
    share qw($flink_dir $install_path);
}

our $VERSION = '9999';

use Rex -feature => [qw(1.4 exec_autodie)];
use Rex::CMDB;

my $flink = get cmdb 'flink';

$install_path = $flink->{install_path} // '~/flink';
$flink_dir = "$install_path/current";

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
};

task 'start' => sub {
    run 'bin/start-local.sh', cwd => $flink_dir;
};

task 'stop' => sub {
    run 'bin/stop-local.sh', cwd => $flink_dir;
};

1;

__END__

=for :stopwords CMDB CPAN Flink hadoop Hadoop scala YAML

=head1 SYNOPSIS

    # Rexfile
    use Rex::Flink;

    # CLI
    $ rex Flink:setup
    $ rex Flink:start
    $ rex Flink:stop

=head1 DESCRIPTION

This module automates Flink tasks with Rex.

=task setup

Sets Flink up from binary tarball.

Supported options:

=begin :list

= hadoop
Hadoop version (default: C<27>)

= scala
Scala version (default: C<2.11>)

= version
Flink version (default: C<1.2.0>)

=end :list

=task start

Starts Flink.

=task stop

Stops Flink.

=head1 DIAGNOSTICS

This module does not do any error checking (yet).

=head1 CONFIGURATION AND ENVIRONMENT

This module can use configuration specified under the C<flink> node in the CMDB. Example YAML structure:

 flink:
     hadoop: 27
     install_path: ~/flink
     scala: 2.11
     version: 1.2.0

This module does not use any environment variables.

=head1 DEPENDENCIES

This module depends on the modules detailed below.

CPAN modules:

=for :list
* Rex

=head1 INCOMPATIBILITIES

There are no known incompatibilities with other modules.

=head1 BUGS AND LIMITATIONS

There are no known bugs. Make sure they are reported.
