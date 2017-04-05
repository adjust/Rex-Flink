requires "Rex" => "0";
requires "strict" => "0";
requires "warnings" => "0";

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};

on 'develop' => sub {
  requires "English" => "0";
  requires "File::Spec" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Test::More" => "0";
  requires "Test::Pod" => "1.41";
  requires "blib" => "1.01";
  requires "perl" => "5.006";
};
