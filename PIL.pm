package Weather::PIL;
require 5.004;
require Exporter;

=head1 NAME

Weather::PIL - 

=head1 DESCRIPTION

=head1 EXAMPLE

=head1 AUTHOR

Robert Rothenberg <wlkngowl@unix.asb.com>

=cut

@ISA = qw(Exporter);
@EXPORT = qw();

use vars qw($VERSION $AUTOLOAD);
$VERSION = "1.1.0";

use Carp;

sub initialize {
    my $self = shift;
    $self->{PIL} = undef;
}

sub new {
    my $this = shift;
    my $class = ref($this) || $this;
    my $self = {};
    bless $self, $class;
    $self->initialize();
    $self->import(@_);
    return $self;
}

sub import {
    my $self = shift;
    export $self;

    my $PIL;

    if (defined($self{PIL})) {
        croak "PIL already created";
    }

    if (@_) {
        if (@_==1) {
            $PIL = shift;
        } else {
        }
    }    

    if (defined($PIL)) {
        unless (valid($PIL)) {
            croak "Invalid PIL: $PIL";
        }
        $self->{PIL} = $PIL;
    }

    $self->{NNN} = substr($PIL, 0, 3);
    $self->{ccc} = substr($PIL, 4);
}

sub valid {
    my $arg = shift;
    if ($arg =~ m/^[A-Z0-9]{4,6}$/) {
        return 1;
    } else {
        return 0;
    }
}

sub cmp {
    my $self = shift;
    my $another = shift;

    my $type = ref($another) or croak "$another is not an object";
    return ($self->NNN eq $another->NNN);
}

sub AUTOLOAD {
    my $self = shift;
    my $type = ref($self)
                or croak "$self is not an object";

    my $name = $AUTOLOAD;
    $name =~ s/.*://;   # strip fully-qualified portion

    if (grep(/^$name$/,
        qw(PIL NNN ccc)
    )) {
        if (@_) {
            if ($name eq "PIL") {
                $self->import(@_);
            } else {
                croak "`$name' field in class $type is read-only"
            }
        } else {
            return $self->{$name};
        }
    } else {
        croak "Can't access `$name' field in class $type"
    }

}

1;
