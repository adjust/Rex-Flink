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
sub is_running {
    my $regex = shift;

    return any { $_->{command} =~ /$regex/ } ps();
}

my $job_manager       = qr{java.*flink.*JobManager};
my $job_manager_local = qr{java.*flink.*JobManager.*--executionMode local};
my $job_manager_cluster
  = qr{java.*flink.*JobManager.*--executionMode cluster};
my $task_manager = qr{java.*flink.*TaskManager};

$t->ok( !is_running($job_manager),  'JobManager is not running' );
$t->ok( !is_running($task_manager), 'TaskManager is not running' );

# local mode
run_task 'Flink:start', on => $host;

$t->ok( is_running($job_manager_local),
    'JobManager has started in local mode' );

run_task 'Flink:stop', on => $host;

$t->ok( !is_running($job_manager_local),
    'JobManager has stopped in local mode' );

# cluster mode
run_task 'Flink:start',
  on     => $host,
  params => { mode => 'cluster' };

$t->ok(
    is_running($job_manager_cluster),
    'JobManager has started in cluster mode'
);

run_task 'Flink:stop', on => $host;

$t->ok(
    !is_running($job_manager_cluster),
    'JobManager has stopped in cluster mode'
);

# TaskManager
run_task 'Flink:start',
  on     => $host,
  params => { service => 'taskmanager' };

$t->ok( is_running($task_manager), 'TaskManager has started' );

run_task 'Flink:stop',
  on     => $host,
  params => { service => 'taskmanager' };

$t->ok( !is_running($task_manager), 'TaskManager has stopped' );

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

run_task 'Flink:start',
  on     => $host,
  params => { service => 'jobmanager', mode => 'local' };

unlink("$tmp_dir/wordcount.out");

run_task 'Flink:Pipeline:run',
  on     => $host,
  params => {
    file => '~/flink/current/pipelines/WordCount.jar',
    options =>
      "--input ~/flink/current/LICENSE --output $tmp_dir/wordcount.out"
  };

$t->has_file("$tmp_dir/wordcount.out");

run_task 'Flink:stop',
  on     => $host,
  params => { service => 'jobmanager' };

$t->finish;
