package Aion::Enum;
use 5.22.0;
no strict; no warnings; no diagnostics;
use common::sense;

our $VERSION = "0.0.0-prealpha";

use constant;
use Aion -role;

# Импорт
sub import {
	my $pkg = caller;
	*{"${pkg}::issa"} = \&issa;
	*{"${pkg}::case"} = \&case;
	eval "package $pkg; use Aion -role; with 'Aion::Enum'; 1" or die
}

#@category Управленцы

my %ENUM;

# Создать перечисление
sub case(@) {
	my ($name, $value, $stash) = @_;
	
	die "The case name must by 1+ simbol!" unless length $name;
	
	my $pkg = caller;

	my $valisa = ${"${pkg}::__VALUE_ISA__"};
	$valisa && $valisa->validate($value, "$name value");
	
	my $staisa = ${"${pkg}::__STASH_ISA__"};
	$staisa && $staisa->validate($stash, "$name stash");
	
	my $case = bless {
        name => $name,
        defined($value)? (value => $value): (),
        defined($stash)? (stash => $stash): (),
    }, $pkg;

    constant->import("${pkg}::$name", $case);

    push @{$ENUM{$pkg}}, $case;

    eval "package $pkg { has name  => (is => 'ro') }; 1" or die;
    eval "package $pkg { has value => (is => 'ro') }; 1" or die;
    eval "package $pkg { has stash => (is => 'ro') }; 1" or die;
    eval "package $pkg { has alias => (is => 'ro', default => sub {
        my (\$self) = \@_;
        \$self->aliases;
        \$self->{alias}
    })}; 1" or die;

    return;
}

# Задаёт типы для value и stash
sub issa(@) {
	my ($valisa, $staisa) = @_;
	my $pkg = caller;
	${"${pkg}::__VALUE_ISA__"} = $valisa;
	${"${pkg}::__STASH_ISA__"} = $staisa;
	return;
}

#@category Перечисления

# Перечисления
sub cases {
	my ($cls) = @_;
	@{$ENUM{ref $cls || $cls}}
}

# Имена
sub names {
	my ($cls) = @_;
	map $_->{name}, $cls->cases
}

# Значения
sub values {
	my ($cls) = @_;
	map $_->{value}, $cls->cases
}

# Дополнения
sub stashes {
	my ($cls) = @_;
	map $_->{stash}, $cls->cases
}

# Псевдонимы
sub aliases {
	my ($cls) = @_;
	$cls = ref $cls || $cls;
	unless(exists $ENUM{$cls}[0]{alias}) {
        $_->{alias} = undef for $cls->cases;
	
        my $path = $INC{($cls =~ s!::!/!gr) . ".pm"};
        open my $f, "<:utf8", $path or die "$path: $!";
        my $alias;
        my $id = '[a-zA-Z_]\w*';
        while(<$f>) {
            $alias = $1 if /^# (\S.*?)\s*$/;

            UNIVERSAL::isa(&{"${cls}::$+{id}"}, $cls)
                && do {
                    (&{"${cls}::$+{id}"})->{alias} = $alias;
                    undef $alias;
                }
            if /^case \s+ (
                   (?<id>$id)
                | '(?<id>$id)'
                | "(?<id>$id)"
                | q[wq]? (?:
                      \{ (?<id>$id) \}
                    | \[ (?<id>$id) \]
                    | \( (?<id>$id) \)
                    | < (?<id>$id) >
                    | ([~!\@#$%^&*-+=\\\/|]) (?<id>$id) \2
                )
            )/x;
        }
        close $f;
	}
	map $_->{alias}, $cls->cases
}

#@category Конструкторы

# Получить case по имени c исключением
sub fromName {
	my ($cls, $name) = @_;
	my $case = $cls->tryFromName($name);
    die "Did not case with name `$name`!" unless defined $case;
	$case
}

# Получить case по имени
sub tryFromName {
	my ($cls, $name) = @_;
	my ($case) = grep { $_->{name} ~~ $name } $cls->cases;
	$case
}

# Получить case по значению c исключением
sub fromValue {
	my ($cls, $value) = @_;
	my $case = $cls->tryFromValue($value);
    die "Did not case with value `$value`!" unless defined $case;
	$case
}

# Получить case по значению
sub tryFromValue {
	my ($cls, $value) = @_;
	my ($case) = grep { $_->{value} ~~ $value } $cls->cases;
	$case
}

# Получить case по значению c исключением
sub fromStash {
	my ($cls, $stash) = @_;
	my $case = $cls->tryFromStash($stash);
    die "Did not case with stash `$stash`!" unless defined $case;
	$case
}

# Получить case по значению
sub tryFromStash {
	my ($cls, $stash) = @_;
	my ($case) = grep { $_->{stash} ~~ $stash } $cls->cases;
	$case
}

# Получить case по псевдониму c исключением
sub fromAlias {
	my ($cls, $alias) = @_;
	my $case = $cls->tryFromAlias($alias);
    die "Did not case with alias `$alias`!" unless defined $case;
	$case
}

# Получить case по псевдониму
sub tryFromAlias {
	my ($cls, $alias) = @_;
	my ($case) = grep { $_->{alias} ~~ $alias } $cls->cases;
	$case
}

1;

__END__

=encoding utf-8



=begin HTML

<img src="https://raw.githubusercontent.com/darviarush/perl-aion/master/doc/badges/total.svg?sanitize=true" alt="Coverage" />

=end HTML


=head1 NAME

Aion :: Enum - Listing in the style of OOP, when each renewal is an object

=head1 VERSION

0.0.0-prealpha

=head1 SYNOPSIS

	package StatusEnum {
	    use Aion::Enum;
	
	    case 'Active';
	    case 'Passive';
	}
	
	&StatusEnum::Active->isa('StatusEnum')   # => 1
	StatusEnum::Active()->does('Aion::Enum') # => 1
	
	StatusEnum->Active->name  # => Active
	StatusEnum->Passive->name # => Passive
	
	[ StatusEnum->names ] # --> [qw/Active Passive/]

=head1 DESCRIPTION

C<Aion :: Enum> allows you to create transfers-objects. These transfers may contain additional methods and properties. You can add roles to them (using C<with>) or use them as a role.

An important feature is the preservation of the procedure for listing.

=head1 SUBROUTINES

=head2 case ($name, [$value, [$stash]])

Creates a listing: his constant.

	package OrderEnum {
	    use Aion::Enum;
	
	    case 'First';
	    case Second => 2;
	    case Other  => 3, {data => 123};
	}
	
	&OrderEnum::First->name  # => First
	&OrderEnum::First->value # -> undef
	&OrderEnum::First->stash # -> undef
	
	&OrderEnum::Second->name  # => Second
	&OrderEnum::Second->value # -> 2
	&OrderEnum::Second->stash # -> undef
	
	&OrderEnum::Other->name  # => Other
	&OrderEnum::Other->value # -> 3
	&OrderEnum::Other->stash # --> {data => 123}

=head2 issa ($valisa, [$staisa])

Indicates the type (ISA) of meanings and additions.

Its name is a reference to the goddess Isse from the story “Under the Moles of Mars” Burrose.

	eval << 'END';
	package StringEnum {
	    use Aion::Enum;
	
	    issa Int;
	
	    case Active => "active";
	}
	END
	$@ # ~> Active value must have the type Int. The it is 'active'
	
	eval << 'END';
	package StringEnum {
	    use Aion::Enum;
	
	    issa Str, Int;
	
	    case Active => "active", "passive";
	}
	END
	$@ # ~> Active stash must have the type Int. The it is 'passive'

=head1 CLASS METHODS

=head2 cases ($cls)

List of transfers.

	[ OrderEnum->cases ] # --> [OrderEnum->First, OrderEnum->Second, OrderEnum->Other]

=head2 names ($cls)

Names of transfers.

	[ OrderEnum->names ] # --> [qw/First Second Other/]

=head2 values ($cls)

The values of the transfers.

	[ OrderEnum->values ] # --> [undef, 2, 3]

=head2 stashes ($cls)

Additions of transfers.

	[ OrderEnum->stashes ] # --> [undef, undef, {data => 123}]

=head2 aliases ($cls)

Pseudonyms of transfers.

LIB/authorenum.pm file:

	package AuthorEnum;
	
	use Aion::Enum;
	
	# Pushkin Aleksandr Sergeevich
	case 'Pushkin';
	
	# Yacheykin Uriy
	case 'Yacheykin';
	
	case 'Nouname';
	
	1;



	require AuthorEnum;
	[ AuthorEnum->aliases ] # --> ['Pushkin Aleksandr Sergeevich', 'Yacheykin Uriy', undef]

=head2 fromName ($cls, $name)

Get Case by name with exceptions.

	OrderEnum->fromName('First') # -> OrderEnum->First
	eval { OrderEnum->fromName('not_exists') }; $@ # ~> Did not case with name `not_exists`!

=head2 tryFromName ($cls, $name)

Get Case by name.

	OrderEnum->tryFromName('First')      # -> OrderEnum->First
	OrderEnum->tryFromName('not_exists') # -> undef

=head2 fromValue ($cls, $value)

Get Case by value with exceptions.

	OrderEnum->fromValue(undef) # -> OrderEnum->First
	eval { OrderEnum->fromValue('not-exists') }; $@ # ~> Did not case with value `not-exists`!

=head2 tryFromValue ($cls, $value)

Get Case by value.

	OrderEnum->tryFromValue(undef)        # -> OrderEnum->First
	OrderEnum->tryFromValue('not-exists') # -> undef

=head2 fromStash ($cls, $stash)

Get CASE on addition with exceptions.

	OrderEnum->fromStash(undef) # -> OrderEnum->First
	eval { OrderEnum->fromStash('not-exists') }; $@ # ~> Did not case with stash `not-exists`!

=head2 tryFromStash ($cls, $value)

Get Case for addition.

	OrderEnum->tryFromStash({data => 123}) # -> OrderEnum->Other
	OrderEnum->tryFromStash('not-exists')  # -> undef

=head2 fromAlias ($cls, $alias)

Get Case by pseudonym with exceptions.

	AuthorEnum->fromAlias('Yacheykin Uriy') # -> AuthorEnum->Yacheykin
	eval { AuthorEnum->fromAlias('not-exists') }; $@ # ~> Did not case with alias `not-exists`!

=head2 tryFromAlias ($cls, $alias)

Get Case by pseudonym

	AuthorEnum->tryFromAlias('Yacheykin Uriy') # -> AuthorEnum->Yacheykin
	AuthorEnum->tryFromAlias('not-exists')     # -> undef

=head1 FEATURES

=head2 name

Property only for reading.

	package NameEnum {
	    use Aion::Enum;
	
	    case 'Piter';
	}
	
	NameEnum->Piter->name # => Piter

=head2 value

Property only for reading.

	package ValueEnum {
	    use Aion::Enum;
	
	    case Piter => 'Pan';
	}
	
	ValueEnum->Piter->value # => Pan

=head2 stash

Property only for reading.

	package StashEnum {
	    use Aion::Enum;
	
	    case Piter => 'Pan', 123;
	}
	
	StashEnum->Piter->stash # => 123

=head2 alias

Property only for reading.

Aliases work only if the package is in the module, as they read the comment before the case due to reflection.

LIB/aliasenum.pm file:

	package AliasEnum;
	
	use Aion::Enum;
	
	# Piter Pan
	case 'Piter';
	
	1;



	require AliasEnum;
	AliasEnum->Piter->alias # => Piter Pan

=head1 SEE ALSO

=over

=item 1. L<enum>.

=item 2. L<Class::Enum>.

=back

=head1 AUTHOR

Yaroslav O. Kosmina LL<mailto:dart@cpan.org>

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.

⚖ I<* gplv3 *>

=head1 COPYRIGHT

The Aion :: Enum Module is Copyright © 2025 Yaroslav O. Kosmina. Rusland. All Rights Reserved.
