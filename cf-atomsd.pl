#!/usr/bin/perl

use strict;
use warnings;
use Crypt::OpenSSL::RSA;
use ZeroMQ qw/:all/;
my $addr = 'tcp://*:5555';

my $cxt = ZeroMQ::Context->new;
my $sock = $cxt->socket(ZMQ_REP);
$sock->bind($addr);

my $msg;
while (1) {
         $msg = $sock->recv();
         print "Received:". $msg->data."\n";
         $sock->send("Got: ".$msg->data);
          }


my $privkey_passphrase = 'Cfengine passphrase';
my $f_privkey = '/home/jarle/.cfagent/ppkeys/localhost.priv';
# The private key is in PEM format with a _very_ secret passphrase
my $priv_key_stripped = `openssl rsa -inform PEM -in $f_privkey -passin pass:"$privkey_passphrase" 2>/dev/null`;

# Make private key object based on decoded PEM key text. 
my $privkey = Crypt::OpenSSL::RSA->new_private_key(
             $priv_key_stripped
             );
# Make public key object based on pubkey file directly. 
my $pubkey = Crypt::OpenSSL::RSA->new_public_key(
             readfile('/home/jarle/.cfagent/ppkeys/localhost.pub')
             );


my $foo = $pubkey->encrypt('Fjompenisse');
my $bar = $privkey->decrypt($foo);
print $bar;

sub readfile {
 my $f = shift;
 my $chop = shift;
 my $ret;
 open(F, $f) or die "Can't open $f for read: $!\n";
 while (<F>) {
   chomp if $chop;
   $ret .= $_;
 }
 close(F);
 return $ret;
}

