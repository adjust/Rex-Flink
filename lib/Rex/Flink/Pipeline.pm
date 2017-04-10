package Rex::Flink::Pipeline;

# ABSTRACT: pipeline management tasks for Rex::Flink

use strict;
use warnings;

our $VERSION = '9999';

use Carp;
use Rex -base;
use Rex::Commands::Upload;

use Rex::Flink::Common;

my $flink = get 'flink';

desc 'Upload a Flink pipeline';
task 'upload' => sub {
    my $params       = shift;
    my $file         = $params->{file};
    my $pipeline_dir = $flink->{pipeline_dir};

    file $pipeline_dir, ensure => 'directory';

    upload $file, $pipeline_dir;
};

desc 'Run a pipeline';
task 'run' => sub {
    my $params      = shift;
    my $file        = $params->{file};
    my $class       = $params->{class};
    my $parallelism = $params->{parallelism};
    my $job_options = $params->{options} // q{};

    my $pipeline_dir = $flink->{pipeline_dir};
    my $flink_bin    = $flink->{flink_bin};

    croak 'No pipeline file is specified' if !defined $file;

    # compile command
    my @command_parts = qq($flink_bin run);

    if ( defined $class ) {
        push @command_parts, qq(--class $class);
    }

    if ( defined $parallelism ) {
        push @command_parts, qq(--parallelism $parallelism);
    }

    push @command_parts, qq($file $job_options);
    my $command = join q{ }, @command_parts;

    run $command;
};

1;

__END__

=for :stopwords Flink

=head1 SYNOPSIS

    # Rexfile
    use Rex::Flink;

    # CLI
    $ rex Flink:Pipeline:upload --file=pipeline.jar
    $ rex Flink:Pipeline:run --file=remote/path/to/pipeline.jar

=head1 DESCRIPTION

This module contains tasks related to Flink pipeline management.

See L<Rex::Flink/TASKS> for more details.

=head1 DIAGNOSTICS

See L<Rex::Flink/DIAGNOSTICS>.

=head1 CONFIGURATION AND ENVIRONMENT

See L<Rex::Flink/CONFIGURATION AND ENVIRONMENT>.

=head1 DEPENDENCIES

See L<Rex::Flink/DEPENDENCIES>.

=head1 INCOMPATIBILITIES

There are no known incompatibilities with other modules.

=head1 BUGS AND LIMITATIONS

There are no known bugs. Make sure they are reported.
