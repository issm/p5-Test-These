package Test::These;
use strict;
use warnings;
use 5.008_001;
use Carp;
use Try::Tiny;
use Test::More;

our $VERSION = '0.00_07';


sub import {
    my $class  = shift;
    my $caller = caller;

    no strict 'refs';
    no warnings 'redefine';

    # Test::More's EXPORTED functions
    for my $f (@Test::More::EXPORT) {
        *{"$caller\::$f"} = *{"Test::More::$f"};
    }

    *{"$caller\::test_these"}   = _build($class);
    *{"$caller\::case"}         = sub ($) { goto &cases };
    *{"$caller\::cases"}        = sub ($) { goto &cases };
    *{"$caller\::code"}         = sub (&) { goto &code };
    *{"$caller\::success"}      = sub (&) { goto &success };
    *{"$caller\::error"}        = sub (&) { goto &error };
    *{"$caller\::success_each"} = sub ($) { goto &success_each };
    *{"$caller\::error_each"}   = sub ($) { goto &error_each };
}


sub _build {
    my ($class) = @_;

    return sub (&) {
        my ($block) = @_;
        my $self = bless {
            block         => $block,
            cases         => [],
            _sub_code     => sub {},
            _sub_success  => sub {},
            _sub_error    => sub {},
            _subs_success => undef,
            _subs_error   => undef,
        }, $class;
        $self->_go;
        return $self;
    };
}


sub _go {
    my ($self) = @_;

    no warnings 'redefine';
    local *cases        = __x_cases($self);
    local *code         = __x_code($self);
    local *success      = __x_success($self);
    local *error        = __x_error($self);
    local *success_each = __x_success_each($self);
    local *error_each   = __x_error_each($self);

    $self->{block}();

    my $cases = $self->{cases};

    # $cases as arrayref
    if (ref $cases eq 'ARRAY') {
        my $i = 0;
        for my $case ( @{$self->{cases}} ) {
            try {
                my $v = $self->{_sub_code}($case);

                # success_each 指定
                if ( defined (my $subs = $self->{_subs_success}) ) {
                    my $ref = ref $subs;
                    my $sub;
                    # $subs as arrayref
                    if ($ref eq 'ARRAY') {
                        $sub = $subs->[$i];
                        $sub = $subs->[$sub]  if (ref $sub eq '');  # $sub がスカラ値 -> 別の sub へのエイリアス
                    }
                    # $subs as hashref
                    elsif ($ref eq 'HASH') {
                        $sub = $subs->{$i};
                        $sub = $subs->{$sub}  if (ref $sub eq '');  # $sub がスカラ値 -> 別の sub へのエイリアス
                    }
                    $sub->($v, $i);
                }
                # success_each 未指定
                else {
                    $self->{_sub_success}($v, $i);
                }
            }
            catch {
                my $msg = shift;

                # error_each 指定
                if ( defined (my $subs = $self->{_subs_error}) ) {
                    my $ref = ref $subs;
                    my $sub;
                    # $subs as arrayref
                    if ($ref eq 'ARRAY') {
                        $sub = $subs->[$i];
                        $sub = $subs->[$sub]  if (ref $sub eq '');  # $sub がスカラ値 -> 別の sub へのエイリアス
                    }
                    # $subs as hashref
                    elsif ($ref eq 'HASH') {
                        $sub = $subs->{$i};
                        $sub = $subs->{$sub}  if (ref $sub eq '');  # $sub がスカラ値 -> 別の sub へのエイリアス
                    }
                    $sub->($msg, $i);
                }
                # error_each 未指定
                else {
                    $self->{_sub_error}($msg, $i);
                }
            };
            $i++;
        }
    }
    # $cases as hashref
    elsif (ref $cases eq 'HASH') {
        while ( my ($case_k, $case_v) = each %$cases ) {
            try {
                my $v = $self->{_sub_code}($case_v);
                # success_each 指定
                if ( defined (my $subs = $self->{_subs_success}) ) {
                    my $sub = $subs->{$case_k};
                    $sub = $subs->{$sub}  if (ref $sub eq '');  # $sub がスカラ値 -> 別の sub へのエイリアス
                    $sub->($v, $case_k);
                }
                # success
                else {
                    $self->{_sub_success}($v, $case_k);
                }
            }
            catch {
                my $msg = shift;
                # error_each 指定
                if ( defined (my $subs = $self->{_subs_error}) ) {
                    my $sub = $subs->{$case_k};
                    $sub = $subs->{$sub}  if (ref $sub eq '');  # $sub がスカラ値 -> 別の sub へのエイリアス
                    $sub->($msg, $case_k);
                }
                # error
                else {
                    $self->{_sub_error}($msg, $case_k);
                }
            };
        }
    }
}


sub __x_cases {
    my ($self) = @_;
    return sub {
        my ($cases) = @_;

        # scalar
        $cases = [$cases]  if ref $cases eq '';

        # arrayref
        if (ref $cases eq 'ARRAY') {
            push @{$self->{cases}}, @$cases;
        }
        # hashref
        elsif (ref $cases eq 'HASH') {
            $self->{cases} = $cases;
        }
    };
}

sub __x_code {
    my ($self) = @_;
    return sub {
        my ($code) = @_;
        $self->{_sub_code} = $code;
    }
}

sub __x_success {
    my ($self) = @_;
    return sub (&) {
        my ($code) = @_;
        $self->{_sub_success} = $code;
    };
}

sub __x_error {
    my ($self) = @_;
    return sub {
        my ($code) = @_;
        $self->{_sub_error} = $code;
    };
}


sub __x_success_each {
    my ($self) = @_;
    return sub {
        my ($subs) = @_;

        if ( ref($self->{cases}) eq 'HASH'  &&  ref($subs) eq 'ARRAY' ) {
            die '"success_each" shoud be hashref, when "cases" is hashref.';
        }

        $self->{_subs_success} = $subs;
    };
}

sub __x_error_each {
    my ($self) = @_;
    return sub {
        my ($subs) = @_;

        if ( ref($self->{cases}) eq 'HASH'  &&  ref($subs) eq 'ARRAY' ) {
            die '"error_each" shoud be hashref, when "cases" is hashref.';
        }

        $self->{_subs_error} = $subs;
    };
}


sub __stub {
    my $func = shift;
    return sub {
        croak "Can't call $func() outside _go block.";
    };
}

*cases        = __stub 'cases';
*code         = __stub 'code';
*success      = __stub 'success';
*error        = __stub 'error';
*success_each = __stub 'success_each';
*error_each   = __stub 'error_each';


1;
__END__

=head1 NAME

Test::These - tests these cases in one or less code.

=head1 SYNOPSIS

  use Test::These;
  use Test::More ;

  ...

  test_these {
      # test cases
      cases \@test_cases;
      cases \@test_cases_more;
      ...

      # execute block for each @test_cases
      code {
          my $param = shift;
          do_something($param);
          ...
      };

      # no problem in "code" block
      success {
          my ($got, $i) = @_;  # result of "code" block, and index of case
          is $got, $expected;
          ...
      };

      # problem occured in "code" block
      error {
          my ($got, $i) = @_;  # "$@" value(?), and index of case
          is $got, $expedted;
          ...
      };
  };


  #
  test_these {
      cases +{
          case1 => \%params_case1,
          case2 => \%params_case2,
          case3 => \%params_case3,
          ...
      };

      code { do_something(shift) };

      success_each +{
          # executed when 'code' successes in case 'case1'
          case1 => sub {
              my $got = shift;
              ...
          },
          # executed when 'code' successes in case 'case2'
          case2 => sub {
              my $got = shift;
              ...
          },
          # executed (same as 'case1') when 'code' successes in case 'case3'
          case3 => 'case1',
          ...
      };

      error_each +{
          # executed when 'code' fails in case 'case1'
          case1 => sub {
              my $msg = shift;
              ...
          },
          ...
      };
  };

=head1 DESCRIPTION

Test::These is a module that tests in many parameter cases with one or less code.

=head1 CONSTRUCTOR

=over 4

=item $test = test_these I<BLOCK>;

Tests contents of I<BLOCK>;

=back

=head1 AUTHOR

issm E<lt>issmxx@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
