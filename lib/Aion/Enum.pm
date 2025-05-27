package Aion::Enum;
use 5.22.0;
no strict; no warnings; no diagnostics;
use common::sense;

our $VERSION = "0.0.0-prealpha";

use constant;
use Aion -role;

# Импорт
sub import {
	my ($cls, %arg) = @_;
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
	$valisa && $valisa->validate($value, $name);
	
	my $staisa = ${"${pkg}::__STASH_ISA__"};
	$staisa && $staisa->validate($stash, $name);
	
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
	my $case = $cls->tryFrom($value);
    die "Did not case with value `$value`!" unless defined $case;
	$case
}

# Получить case по значению
sub tryFromValue {
	my ($cls, $value) = @_;
	my ($case) = grep { $_->{value} ~~ $value } $cls->cases;
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

=head1 NAME

Aion::Enum - перечисления в стиле ООП, когда каждое перечсление является объектом

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

C<Aion::Enum> позволяет создавать перечисления-объекты. Данные перечисления могут содержать дополнительные методы и свойства. В них можно добавлять роли (с помощью C<with>) или использовать их самих как роли.

Важной особенностью является сохранение порядка перечисления.

=head1 SUBROUTINES

=head2 case ($name, [$value, [$stash]])

Создаёт перечисление: его константу.

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

Указывает тип (isa) значений и дополнений.

	eval << 'END';
	package StringEnum {
	    use Aion::Enum;
	
	    issa Int;
	
	    case Active => "active";
	}
	END
	$@ # ~> Active must have the type Int. The it is 'active'
	
	eval << 'END';
	package StringEnum {
	    use Aion::Enum;
	
	    issa Str, Int;
	
	    case Active => "active", "passive";
	}
	END
	$@ # ~> Active must have the type Int. The it is 'passive'

=head1 FEATURES

=head2 name

Свойство только для чтения.

	package NameEnum {
	    use Aion::Enum;
	
	    case 'Piter';
	}
	
	NameEnum->Piter->name # => Piter

=head2 value

Свойство только для чтения.

	package ValueEnum {
	    use Aion::Enum;
	
	    case Piter => 'Pan';
	}
	
	ValueEnum->Piter->value # => Pan

=head2 stash

Свойство только для чтения.

	package StashEnum {
	    use Aion::Enum;
	
	    case Piter => 'Pan', 123;
	}
	
	StashEnum->Piter->stash # => 123

=head2 alias

Свойство только для чтения.

Алиасы работают только если пакет находится в модуле, так как считывают комментарий перед кейсом за счёт рефлексии.

Файл lib/AliasEnum.pm:

	package AliasEnum;
	
	use Aion::Enum;
	
	# Piter Pan
	case 'Piter';
	
	1;



	require AliasEnum;
	AliasEnum->Piter->alias # => Piter Pan

=head1 METHODS

=head2 from ($value)

=head1 AUTHOR

Yaroslav O. Kosmina LL<mailto:dart@cpan.org>

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.

⚖ B<GPLv3>

=head1 COPYRIGHT

The Aion::Enum module is copyright © 2025 Yaroslav O. Kosmina. Rusland. All rights reserved.
