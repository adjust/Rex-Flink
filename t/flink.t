#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(any none);

use Rex -base;
use Rex::Test::Base;
use Rex::Commands::Virtualization;

set box => 'KVM';

use Rex::Flink;

my $t = Rex::Test::Base->new;

my $vm_image = $ENV{REX_FLINK_TEST_IMAGE};
my $user     = Rex::Config::get_user();

$t->name('flink-test');
$t->base_vm($vm_image);
$t->vm_auth( user => $user, );

# install tests
$t->run_task('Flink:setup');
my $host = connection->server;

$t->has_file('/tmp/flink-1.2.0-bin-hadoop27-scala_2.11.tgz');
$t->has_dir('~/flink');
$t->has_dir('~/flink/flink-1.2.0');
$t->has_dir('~/flink/current');

# run tests
$t->ok( ( none { $_->{command} =~ /java.*flink.*JobManager/ } ps() ),
    'Flink is not running' );

run_task 'Flink:start', on => $host;

$t->ok( ( any { $_->{command} =~ /java.*flink.*JobManager/ } ps() ),
    'Flink has started' );

run_task 'Flink:stop', on => $host;

$t->ok( ( none { $_->{command} =~ /java.*flink.*JobManager/ } ps() ),
    'Flink has stopped' );

$t->finish;
