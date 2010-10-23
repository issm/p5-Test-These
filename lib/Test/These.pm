package Test::These;
use strict;
use warnings;
use 5.008_001;
use Carp;
use Try::Tiny;

our $VERSION = '0.00_04';


sub import {
    my $class  = shift;
    my $caller = caller;

    no strict 'refs';
    no warnings 'redefine';
    *{"$caller\::test_these"} = _build($class);
    *{"$caller\::case"}       = sub ($) { goto &cases };
    *{"$caller\::cases"}      = sub ($) { goto &cases };
    *{"$caller\::code"}       = sub (&) { goto &code };
    *{"$caller\::success"}    = sub (&) { goto &success };
    *{"$caller\::error"}      = sub (&) { goto &error };
}


sub _build {
    my ($class) = @_;

    return sub (&) {
        my ($block) = @_;
        my $self = bless {
            block       => $block,
            cases       => [],
            _sub_code    => sub {},
            _sub_success => sub {},
            _sub_error   => sub {},
        }, $class;
        $self->_go;
        return $self;
    };
}


sub _go {
    my ($self) = @_;

    no warnings 'redefine';
    local *cases   = __x_cases($self);
    local *code    = __x_code($self);
    local *success = __x_success($self);
    local *error   = __x_error($self);

    $self->{block}();


    my $i = 0;
    for my $case ( @{$self->{cases}} ) {
        try {
            my $v = $self->{_sub_code}($case);
            $self->{_sub_success}($v, $i);
        }
        catch {
            my $msg = shift;
            $self->{_sub_error}($msg, $i);
        };
        $i++;
    }
}


sub __x_cases {
    my ($self) = @_;
    return sub {
        my ($cases) = @_;
        push @{$self->{cases}}, @$cases;
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


sub __stub {
    my $func = shift;
    return sub {
        croak "Can't call $func() outside _go block.";
    };
}

*cases   = __stub 'cases';
*code    = __stub 'code';
*success = __stub 'success';
*error   = __stub 'error';


1;
__END__

=head1 NAME

Test::These - tests these.

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

=head1 DESCRIPTION

Test::These is hoge.

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
