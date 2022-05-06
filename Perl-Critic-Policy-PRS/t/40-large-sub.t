#!perl

use utf8;

use 5.010;

use strict;
use warnings;

our $VERSION = '0.01';

use Readonly;

use Perl::Critic;

use Test::More;

Readonly::Scalar my $POLICY_NAME => 'Perl::Critic::Policy::PRS::ProhibitLargeSub';

Readonly::Scalar my $STATEMENT_COUNT_LIMIT_VALUE_99 => 99;

plan 'tests' => 6;

#####

sub _get_perl_critic_object
{
    my @configs = @_;

    my $pc = Perl::Critic->new(
        '-profile'  => 'NONE',
        '-only'     => 1,
        '-severity' => 1,
        '-force'    => 0
    );

    $pc->add_policy( '-policy' => $POLICY_NAME, @configs );

    return $pc;
}

#####

sub _check_perl_critic
{
    my ( $code_ref, $statement_count_limit ) = @_;

    my @params;
    if ( $statement_count_limit ) {
        @params = ( '-params' => { 'statement_count_limit' => $statement_count_limit } );
    }

    my $pc = _get_perl_critic_object( @params );

    return $pc->critique( $code_ref );
}

#####

{
    my $code = <<'END_OF_STRING';
        # empty code
END_OF_STRING

    my @violations = _check_perl_critic( \$code );

    ok !@violations, 'no violation with empty code';
}

#####

{
    my $code = <<'END_OF_STRING';
        sub my_test {
            # empty sub
        }
END_OF_STRING

    my @violations = _check_perl_critic( \$code );

    ok !@violations, 'no violation with only comment in sub';
}

#####

{
    my $code = <<'END_OF_STRING';
        sub my_test {
            return 1;
        }
END_OF_STRING

    my @violations = _check_perl_critic( \$code );

    ok !@violations, 'no violation with single return sub';
}

#####

{
    my $code = <<'END_OF_STRING';
        sub my_test {
            my $x = 1;
            return $x;
        }
END_OF_STRING

    my @violations = _check_perl_critic( \$code );

    ok !@violations, 'no violation with two statements in sub';
}

#####

{
    my $code = <<'END_OF_STRING';
        sub my_test {
            # some first stuff
            print "DEBUG: " . __LINE__;
            my $x = 1;

            $x+=1;
            $x+=2;
            $x+=3;
            $x+=5;

            # some other stuff
            print "DEBUG: " . __LINE__;
            my $y = 1;

            $y+=1;
            $y+=2;
            $y+=3;
            $y+=5;

            $x *= $y;

            # some more other stuff
            print "DEBUG: " . __LINE__;
            my $z = 1.1;

            $z+=1.1;
            $z+=2.2;
            $z+=3.3;
            $z+=5.5;

            $x *= $z;

            if(0) {
                # not happen
                print "DEBUG: " . __LINE__;
                $x = 0;
            }

            # return something
            print "DEBUG: " . __LINE__;
            return $x;
        }
END_OF_STRING

    my @violations = _check_perl_critic( \$code );

    ok @violations, 'violation with some large sub';
}

#####

{
    my $code = <<'END_OF_STRING';
        sub my_test {
            # some first stuff
            print "DEBUG: " . __LINE__;
            my $x = 1;

            $x+=1;
            $x+=2;
            $x+=3;
            $x+=5;

            # some other stuff
            print "DEBUG: " . __LINE__;
            my $y = 1;

            $y+=1;
            $y+=2;
            $y+=3;
            $y+=5;

            $x *= $y;

            # some more other stuff
            print "DEBUG: " . __LINE__;
            my $z = 1.1;

            $z+=1.1;
            $z+=2.2;
            $z+=3.3;
            $z+=5.5;

            $x *= $z;

            if(0) {
                # not happen
                print "DEBUG: " . __LINE__;
                $x = 0;
            }

            # return something
            print "DEBUG: " . __LINE__;
            return $x;
        }
END_OF_STRING

    my @violations = _check_perl_critic( \$code, $STATEMENT_COUNT_LIMIT_VALUE_99 );

    ok !@violations, 'not violation with some large sub when 99 statements allowed via config';
}

#####

done_testing();