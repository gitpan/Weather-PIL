package Weather::PIL;
require 5.004;
require Exporter;

=head1 NAME

Weather::PIL - routines for parsing WMO header

=head1 DESCRIPTION

Weather::PIL is an object for parsing product identifier lines (headers)
in WMO weather products.

=head1 EXAMPLE

    require Weather::PIL;

    $line = "FPUS61 KOKX 171530";

    unless (Weather::PIL::valid($line)) {
        die "\'$line\' is not a valid header.\n";
    }

    $pil = new Weather::PIL($line);

    print "PIL\t", $pil->PIL, "\n";
    print "code\t", $pil->code, "\n";		# FPUS61
    print "station\t", $pil->station, "\n";	# KOKX
    print "time\t", $pil->time, "\n";		# "171530"

    # other constructors
    $pil = new Weather::PIL qw(FPUS51 KNYC 041200 PAA);

    $pil = new Weather::PIL;
    $pil->PIL="FPUS51 KNYC 041200 (PAA)";

=head1 AUTHOR

Robert Rothenberg <wlkngowl@unix.asb.com>

=cut

@ISA = qw(Exporter);
@EXPORT = qw();

use vars qw($VERSION $AUTOLOAD);
$VERSION = "1.0.5";

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

    my $pil, $code, $station, $time, $addendum;

    if (defined($self{PIL})) {
        croak "PIL already created";
    }

    if (@_) {
        if (@_==1) {
            $pil = shift;
            ($code, $station, $time, $addendum) = split(/ /, $pil);
            $addendum =~ s/\(((AA|CC|RR|P[A-X])[A-X])\)/$1/;
        } else {
            ($code, $station, $time, $addendum)=@_;
            $pil = "$code $station $time";
            if (defined($addendum)) {
                $pil .= " ($addendum)";
            }
        }
    }    

    if (defined($pil)) {
        $self->{PIL} = $pil;
        unless (valid($pil)) {
            croak "Invalid PIL: $pil";
        }
    }

    $self->{code} = $code;
    $self->{station} = $station;
    $self->{time} = $time;
    $self->{addendum} = $addendum;
}

sub valid {
    my $arg = shift;
    if ($arg =~ m/^[A-Z]{4}\d{2} [A-Z]{3,4} \d{4,6}( \((AA|CC|RR|P[A-X])[A-X]\))?$/) {
        return 1;
    } else {
        return 0;
    }
}


sub AUTOLOAD {
    my $self = shift;
    my $type = ref($self)
                or croak "$self is not an object";

    my $name = $AUTOLOAD;
    $name =~ s/.*://;   # strip fully-qualified portion

    if (grep(/^$name$/, qw(PIL code station time addendum))) {
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
