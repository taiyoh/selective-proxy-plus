#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use Text::MicroTemplate;
use Config::Tiny;

my $conf_file = shift(@ARGV);
die('no conf file') unless ($conf_file);
die("Config file passed on command line ($conf_file) could not be read.\n") unless (-r $conf_file);

my %config = %{ Config::Tiny->read( $conf_file ) };

my $root_config = delete $config{_};

for my $host (keys %config) {
    my $list = $config{$host};
    for (keys %$list) {
        if (/\*/) {
            s/\*//;
            $list->{$_} = delete $list->{"$_*"};
        }
    }
    $config{$host} = $list;
}

my $mt = Text::MicroTemplate->new(
    template => do {
        open my $fh, '<:utf8', "$FindBin::Bin/proxy.pac.mt";
        my $data = do { local $/; <$fh> };
        close $fh;
        $data;
    },
);

my $code = $mt->code;
my $renderer = eval << "..." or die $@;
sub {
    my \$root_config = shift;
    my \$hosts = shift;
    $code->();
}
...

my $rendered = $renderer->($root_config, \%config);

my $output = $root_config->{pac_export};
if ($output) {
    open my $f, '>:utf8', $output;
    print $f $rendered;
    close $f;
}
else {
    print $rendered;
}

__END__

