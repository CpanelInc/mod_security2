#!/usr/local/cpanel/3drparty/bin/perl -w

# cpanel - t/mod_security2.conf.t                 Copyright(c) 2016 cPanel, Inc.
#                                                           All rights reserved.
# copyright@cpanel.net                                         http://cpanel.net
# This code is subject to the cPanel license. Unauthorized copying is prohibited

package t::mod_security2_conf;

use strict;
use warnings;
use FindBin;

use Try::Tiny;

use lib "$FindBin::Bin/lib";

use Test::More tests => 20;
use Test::NoWarnings;

use Cpanel::Apache::Module ();

{
  note("Testing presence of modsec2.user.conf");
  # one test per testcase
  my @testcases = (
    {
       input_file => 'data/nested_too_deep_modsec2_cpanel_include.conf',
    },
    {
       input_file => 'data/nested_too_deep_modsec2_user_include.conf',
       expected_failure => 'modsec2.user.conf directive not in the IfModule directive for security2_module'
    },
    {
       input_file => 'data/no_modsec2_cpanel_include.conf',
    },
    {
       input_file => 'data/no_modsec2_user_include.conf',
       expected_failure => 'modsec2.user.conf directive not in the IfModule directive for security2_module'
    },
    {
       input_file => 'data/out_of_module_modsec2_cpanel_include.conf',
    },
    {
       input_file => 'data/out_of_module_modsec2_user_include.conf',
       expected_failure => 'modsec2.user.conf directive not in the IfModule directive for security2_module'
    },
    {
       input_file => 'data/out_of_order_modsec2_includes.conf',
    },
    {
       input_file => '../SOURCES/modsec2.conf',
    },
  );
    foreach my $testcase_ref (@testcases) {
      my $input_file = "$FindBin::Bin/$testcase_ref->{'input_file'}";

      my $config = undef;
      try {
         $config = Cpanel::Apache::Module::parse($input_file);
      }
      catch {
         my $ex = $_;
         if ( defined $testcase_ref->{'expected_failure'} ) {
           is("file not found", $testcase_ref->{'expected_failure'},
              "test on $input_file failed for the wrong reason");
         } else {
           fail("unexpected file not found in test on $input_file");
         }
         next;
      };
      my @sec2IfModules = $config->getNodes("node", "\<IfModule[ ]+security2_module>");
      if ( (!@sec2IfModules || scalar(@sec2IfModules) != 1) && defined $testcase_ref->{'expected_failure'} ) {
        is("Wrong number of IfModule directives for security2_module", $testcase_ref->{'expected_failure'},
           "checking modsec IfModule directives are wrong in $input_file");
        next;
      }
      my $ifModule = $sec2IfModules[0];
      
      my @items = $config->getNodesWithin($ifModule, 'text', 'Include[ ]+@HTTPD_CONFDIR@/modsec/modsec2.user.conf');
      if ( (!@items || scalar(@items) != 1) && defined $testcase_ref->{'expected_failure'} ) {
        is("modsec2.user.conf directive not in the IfModule directive for security2_module", $testcase_ref->{'expected_failure'},
          "checking modsec2 user entries are wrong in $input_file");
        next;
      }
      is(scalar @items, 1, "checking count of modsec2 user entries in $input_file");
    }
}

{
  note("Testing presence of modsec2.cpanel.conf");
  # one test per test case
  my @testcases = (
    {
       input_file => 'data/nested_too_deep_modsec2_cpanel_include.conf',
       expected_failure => 'modsec2.cpanel.conf directive not in the IfModule directive for security2_module'
    },
    {
       input_file => 'data/nested_too_deep_modsec2_user_include.conf',
    },
    {
       input_file => 'data/no_modsec2_cpanel_include.conf',
       expected_failure => 'modsec2.cpanel.conf directive not in the IfModule directive for security2_module'
    },
    {
       input_file => 'data/no_modsec2_user_include.conf',
    },
    {
       input_file => 'data/out_of_module_modsec2_cpanel_include.conf',
       expected_failure => 'modsec2.cpanel.conf directive not in the IfModule directive for security2_module'
    },
    {
       input_file => 'data/out_of_module_modsec2_user_include.conf',
    },
    {
       input_file => 'data/out_of_order_modsec2_includes.conf',
    },
    {
       input_file => '../SOURCES/modsec2.conf',
    },
  );
    foreach my $testcase_ref (@testcases) {
      my $input_file = "$FindBin::Bin/$testcase_ref->{'input_file'}";

      my $config = undef;
      try {
         $config = Cpanel::Apache::Module::parse($input_file);
      }
      catch {
         my $ex = $_;
         if ( defined $testcase_ref->{'expected_failure'} ) {
           is("file not found", $testcase_ref->{'expected_failure'},
              "test on $input_file failed for the wrong reason");
         } else {
           fail("unexpected file not found in test on $input_file");
         }
         next;
      };
      my @sec2IfModules = $config->getNodes("node", "\<IfModule[ ]+security2_module>");
      if ( (!@sec2IfModules || scalar(@sec2IfModules) != 1) && defined $testcase_ref->{'expected_failure'} ) {
        is("Wrong number of IfModule directives for security2_module", $testcase_ref->{'expected_failure'},
           "checking modsec IfModule directives are wrong in $input_file");
        next;
      }
      my $ifModule = $sec2IfModules[0];
      
      my @items = $config->getNodesWithin($ifModule, 'text', 'Include[ ]+@HTTPD_CONFDIR@/modsec/modsec2.cpanel.conf');
      if ( (!@items || scalar(@items) != 1) && defined $testcase_ref->{'expected_failure'} ) {
        is("modsec2.cpanel.conf directive not in the IfModule directive for security2_module", $testcase_ref->{'expected_failure'},
          "checking modsec2 cpanel entries are wrong in $input_file");
        next;
      }
      is(scalar @items, 1, "checking count of modsec2 cpanel entries in $input_file");
    }
}

{
  note("Testing order of modsec2.cpanel.conf and modsec2.user.conf");
  # two tests per test case, unless expecting failure
  # one test per test case, when expecting failure
  my @testcases = (
    {
       input_file => 'data/out_of_order_modsec2_includes.conf',
       expected_failure => 'directives are out of order',
    },
    {
       input_file => '../SOURCES/modsec2.conf',
    },
  );
    foreach my $testcase_ref (@testcases) {
      my $input_file = "$FindBin::Bin/$testcase_ref->{'input_file'}";

      my $config = undef;
      try {
         $config = Cpanel::Apache::Module::parse($input_file);
      }
      catch {
         my $ex = $_;
         if ( defined $testcase_ref->{'expected_failure'} ) {
           is("file not found", $testcase_ref->{'expected_failure'},
              "test on $input_file failed for the wrong reason");
         } else {
           fail("unexpected file not found in test on $input_file");
         }
         next;
      };
      my @sec2IfModules = $config->getNodes("node", "\<IfModule[ ]+security2_module>");
      if ( (!@sec2IfModules || scalar(@sec2IfModules) != 1) && defined $testcase_ref->{'expected_failure'} ) {
        is("Wrong number of IfModule directives for security2_module", $testcase_ref->{'expected_failure'},
           "checking modsec IfModule directives are wrong in $input_file");
        next;
      }
      my $ifModule = $sec2IfModules[0];
      
      my @items = $config->getNodesWithin($ifModule, 'text', 'Include[ ]+@HTTPD_CONFDIR@/modsec/modsec2.(user|cpanel).conf');
      if ( (!@items || scalar(@items) != 2) && defined $testcase_ref->{'expected_failure'} ) {
        is("wrong number of modsec2.cpanel.conf and modsec2.user.conf directives in the IfModule directive for security2_module", $testcase_ref->{'expected_failure'},
          "checking modsec2 cpanel entries are wrong in $input_file");
        next;
      }
      if ( defined $testcase_ref->{'expected_failure'} ) {
        if ($items[0]->{'attributes'}->{'text'} =~ qr'Include[ ]+@HTTPD_CONFDIR@/modsec/modsec2.user.conf' &&
            $items[1]->{'attributes'}->{'text'} =~ qr'Include[ ]+@HTTPD_CONFDIR@/modsec/modsec2.cpanel.conf') {
            fail("expected failure, but test on $input_file passed");
        } else {
            is("directives are out of order", $testcase_ref->{'expected_failure'}, 
               "checking out of order directives in $input_file");
        }
        next;
      } else {
        like($items[0]->{'attributes'}->{'text'}, qr'Include[ ]+@HTTPD_CONFDIR@/modsec/modsec2.user.conf', 
             "checking modsec2 user conf is first in $input_file");
        like($items[1]->{'attributes'}->{'text'}, qr'Include[ ]+@HTTPD_CONFDIR@/modsec/modsec2.cpanel.conf', 
             "checking modsec2 cpanel conf is second in $input_file");
      }
    }
}

