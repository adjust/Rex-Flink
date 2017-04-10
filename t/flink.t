#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(any none);

use Const::Fast;
use Rex -base;
use Rex::Test::Base;
use Rex::Commands::Virtualization;

set box => 'KVM';

use Rex::Flink;

my $t = Rex::Test::Base->new;

my $vm_image = $ENV{REX_FLINK_TEST_IMAGE};
my $user     = Rex::Config::get_user();

const my $RAM => 1024;

$t->name('flink-test');
$t->base_vm($vm_image);
$t->vm_auth( user => $user, );
$t->memory($RAM);

# install tests
$t->run_task('Flink:setup');
my $host = connection->server;

$t->has_file('/tmp/flink-1.2.0-bin-hadoop27-scala_2.11.tgz');
$t->has_dir('~/flink');
$t->has_dir('~/flink/flink-1.2.0');
$t->has_dir('~/flink/current');

# configure tests
run_task 'Flink:configure', on => $host;

$t->has_file('~/flink/current/conf/flink-conf.yaml');

# run tests
$t->ok( ( none { $_->{command} =~ /java.*flink.*JobManager/ } ps() ),
    'Flink is not running' );

run_task 'Flink:start', on => $host;

$t->ok( ( any { $_->{command} =~ /java.*flink.*JobManager/ } ps() ),
    'Flink has started' );

run_task 'Flink:stop', on => $host;

$t->ok( ( none { $_->{command} =~ /java.*flink.*JobManager/ } ps() ),
    'Flink has stopped' );

# pipeline tests
my $tmp_dir;
LOCAL { $tmp_dir = Rex::Config::get_tmp_dir() };
my $pipeline_file = 'WordCount.jar';

download "/root/flink/current/examples/batch/$pipeline_file", "$tmp_dir/";
run_task 'Flink:Pipeline:upload',
  on     => $host,
  params => { file => "$tmp_dir/$pipeline_file" };

$t->has_dir('~/flink/current/pipelines');
$t->has_file('~/flink/current/pipelines/WordCount.jar');

run_task 'Flink:start', on => $host;

unlink("$tmp_dir/wordcount.out");

run_task 'Flink:Pipeline:run',
  on     => $host,
  params => {
    file => '~/flink/current/pipelines/WordCount.jar',
    options =>
      "--input ~/flink/current/LICENSE --output $tmp_dir/wordcount.out"
  };

$t->has_file("$tmp_dir/wordcount.out");

run_task 'Flink:stop', on => $host;

$t->finish;
