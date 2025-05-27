use common::sense; use open qw/:std :utf8/;  use Carp qw//; use File::Basename qw//; use File::Find qw//; use File::Slurper qw//; use File::Spec qw//; use File::Path qw//; use Scalar::Util qw//;  use Test::More 0.98;  BEGIN {     $SIG{__DIE__} = sub {         my ($s) = @_;         if(ref $s) {             $s->{STACKTRACE} = Carp::longmess "?" if "HASH" eq Scalar::Util::reftype $s;             die $s;         } else {             die Carp::longmess defined($s)? $s: "undef"         }     };      my $t = File::Slurper::read_text(__FILE__);     my $s =  '/tmp/.liveman/perl-aion-enum/aion!enum'    ;     File::Find::find(sub { chmod 0700, $_ if !/^\.{1,2}\z/ }, $s), File::Path::rmtree($s) if -e $s;     File::Path::mkpath($s);     chdir $s or die "chdir $s: $!";      while($t =~ /^#\@> (.*)\n((#>> .*\n)*)#\@< EOF\n/gm) {         my ($file, $code) = ($1, $2);         $code =~ s/^#>> //mg;         File::Path::mkpath(File::Basename::dirname($file));         File::Slurper::write_text($file, $code);     }  } # # NAME
# 
# Aion::Enum - перечисления в стиле ООП, когда каждое перечсление является объектом
# 
# # VERSION
# 
# 0.0.0-prealpha
# 
# # SYNOPSIS
# 
subtest 'SYNOPSIS' => sub { 
package StatusEnum {
    use Aion::Enum;

    case 'Active';
    case 'Passive';
}

::is scalar do {&StatusEnum::Active->isa('StatusEnum')}, "1", '&StatusEnum::Active->isa(\'StatusEnum\')   # => 1';
::is scalar do {StatusEnum::Active()->does('Aion::Enum')}, "1", 'StatusEnum::Active()->does(\'Aion::Enum\') # => 1';

::is scalar do {StatusEnum->Active->name}, "Active", 'StatusEnum->Active->name  # => Active';
::is scalar do {StatusEnum->Passive->name}, "Passive", 'StatusEnum->Passive->name # => Passive';

::is_deeply scalar do {[ StatusEnum->names ]}, scalar do {[qw/Active Passive/]}, '[ StatusEnum->names ] # --> [qw/Active Passive/]';

# 
# # DESCRIPTION
# 
# `Aion::Enum` позволяет создавать перечисления-объекты. Данные перечисления могут содержать дополнительные методы и свойства. В них можно добавлять роли (с помощью `with`) или использовать их самих как роли.
# 
# Важной особенностью является сохранение порядка перечисления.
# 
# # SUBROUTINES
# 
# ## case ($name, [$value, [$stash]])
# 
# Создаёт перечисление: его константу.
# 
done_testing; }; subtest 'case ($name, [$value, [$stash]])' => sub { 
package OrderEnum {
    use Aion::Enum;

    case 'First';
    case Second => 2;
    case Other  => 3, {data => 123};
}

::is scalar do {&OrderEnum::First->name}, "First", '&OrderEnum::First->name  # => First';
::is scalar do {&OrderEnum::First->value}, scalar do{undef}, '&OrderEnum::First->value # -> undef';
::is scalar do {&OrderEnum::First->stash}, scalar do{undef}, '&OrderEnum::First->stash # -> undef';

::is scalar do {&OrderEnum::Second->name}, "Second", '&OrderEnum::Second->name  # => Second';
::is scalar do {&OrderEnum::Second->value}, scalar do{2}, '&OrderEnum::Second->value # -> 2';
::is scalar do {&OrderEnum::Second->stash}, scalar do{undef}, '&OrderEnum::Second->stash # -> undef';

::is scalar do {&OrderEnum::Other->name}, "Other", '&OrderEnum::Other->name  # => Other';
::is scalar do {&OrderEnum::Other->value}, scalar do{3}, '&OrderEnum::Other->value # -> 3';
::is_deeply scalar do {&OrderEnum::Other->stash}, scalar do {{data => 123}}, '&OrderEnum::Other->stash # --> {data => 123}';

# 
# ## issa ($valisa, [$staisa])
# 
# Указывает тип (isa) значений и дополнений.
# 
done_testing; }; subtest 'issa ($valisa, [$staisa])' => sub { 
eval << 'END';
package StringEnum {
    use Aion::Enum;

    issa Int;

    case Active => "active";
}
END
::like scalar do {$@}, qr!Active must have the type Int. The it is 'active'!, '$@ # ~> Active must have the type Int. The it is \'active\'';

eval << 'END';
package StringEnum {
    use Aion::Enum;

    issa Str, Int;

    case Active => "active", "passive";
}
END
::like scalar do {$@}, qr!Active must have the type Int. The it is 'passive'!, '$@ # ~> Active must have the type Int. The it is \'passive\'';

# 
# # FEATURES
# 
# ## name
# 
# Свойство только для чтения.
# 
done_testing; }; subtest 'name' => sub { 
package NameEnum {
    use Aion::Enum;

    case 'Piter';
}

::is scalar do {NameEnum->Piter->name}, "Piter", 'NameEnum->Piter->name # => Piter';

# 
# ## value
# 
# Свойство только для чтения.
# 
done_testing; }; subtest 'value' => sub { 
package ValueEnum {
    use Aion::Enum;

    case Piter => 'Pan';
}

::is scalar do {ValueEnum->Piter->value}, "Pan", 'ValueEnum->Piter->value # => Pan';

# 
# ## stash
# 
# Свойство только для чтения.
# 
done_testing; }; subtest 'stash' => sub { 
package StashEnum {
    use Aion::Enum;

    case Piter => 'Pan', 123;
}

::is scalar do {StashEnum->Piter->stash}, "123", 'StashEnum->Piter->stash # => 123';

# 
# ## alias
# 
# Свойство только для чтения.
# 
# Алиасы работают только если пакет находится в модуле, так как считывают комментарий перед кейсом за счёт рефлексии.
# 
# Файл lib/AliasEnum.pm:
#@> lib/AliasEnum.pm
#>> package AliasEnum;
#>> 
#>> use Aion::Enum;
#>> 
#>> # Piter Pan
#>> case 'Piter';
#>> 
#>> 1;
#@< EOF
# 
done_testing; }; subtest 'alias' => sub { 
require AliasEnum;
::is scalar do {AliasEnum->Piter->alias}, "Piter Pan", 'AliasEnum->Piter->alias # => Piter Pan';

# 
# # METHODS
# 
# ## from ($value)
# 
# 
# 
# # AUTHOR
# 
# Yaroslav O. Kosmina [dart@cpan.org](mailto:dart@cpan.org)
# 
# # LICENSE
# 
# This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.
# 
# ⚖ **GPLv3**
# 
# # COPYRIGHT
# 
# The Aion::Enum module is copyright © 2025 Yaroslav O. Kosmina. Rusland. All rights reserved.

	done_testing;
};

done_testing;
