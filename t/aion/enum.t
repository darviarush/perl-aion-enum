use common::sense; use open qw/:std :utf8/;  use Carp qw//; use File::Basename qw//; use File::Find qw//; use File::Slurper qw//; use File::Spec qw//; use File::Path qw//; use Scalar::Util qw//;  use Test::More 0.98;  BEGIN {     $SIG{__DIE__} = sub {         my ($s) = @_;         if(ref $s) {             $s->{STACKTRACE} = Carp::longmess "?" if "HASH" eq Scalar::Util::reftype $s;             die $s;         } else {             die Carp::longmess defined($s)? $s: "undef"         }     };      my $t = File::Slurper::read_text(__FILE__);     my $s =  '/tmp/.liveman/perl-aion-enum/aion!enum'    ;     File::Find::find(sub { chmod 0700, $_ if !/^\.{1,2}\z/ }, $s), File::Path::rmtree($s) if -e $s;     File::Path::mkpath($s);     chdir $s or die "chdir $s: $!";     push @INC, "lib";      while($t =~ /^#\@> (.*)\n((#>> .*\n)*)#\@< EOF\n/gm) {         my ($file, $code) = ($1, $2);         $code =~ s/^#>> //mg;         File::Path::mkpath(File::Basename::dirname($file));         File::Slurper::write_text($file, $code);     }  } # 
# [![Coverage](https://raw.githubusercontent.com/darviarush/perl-aion-enum/master/doc/badges/total.svg?sanitize=true)](http://matrix.cpantesters.org/?dist=Aion::Enum)
# # NAME
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
# Её название – отсылка к богине Иссе из повести «Под лунами Марса» Берроуза.
# 
done_testing; }; subtest 'issa ($valisa, [$staisa])' => sub { 
eval << 'END';
package StringEnum {
    use Aion::Enum;

    issa Int;

    case Active => "active";
}
END
::like scalar do {$@}, qr!Active value must have the type Int. The it is 'active'!, '$@ # ~> Active value must have the type Int. The it is \'active\'';

eval << 'END';
package StringEnum {
    use Aion::Enum;

    issa Str, Int;

    case Active => "active", "passive";
}
END
::like scalar do {$@}, qr!Active stash must have the type Int. The it is 'passive'!, '$@ # ~> Active stash must have the type Int. The it is \'passive\'';

# 
# # CLASS METHODS
# 
# ## cases ($cls)
# 
# Список перечислений.
# 
done_testing; }; subtest 'cases ($cls)' => sub { 
::is_deeply scalar do {[ OrderEnum->cases ]}, scalar do {[OrderEnum->First, OrderEnum->Second, OrderEnum->Other]}, '[ OrderEnum->cases ] # --> [OrderEnum->First, OrderEnum->Second, OrderEnum->Other]';

# 
# ## names ($cls)
# 
# Имена перечислений.
# 
done_testing; }; subtest 'names ($cls)' => sub { 
::is_deeply scalar do {[ OrderEnum->names ]}, scalar do {[qw/First Second Other/]}, '[ OrderEnum->names ] # --> [qw/First Second Other/]';

# 
# ## values ($cls)
# 
# Значения перечислений.
# 
done_testing; }; subtest 'values ($cls)' => sub { 
::is_deeply scalar do {[ OrderEnum->values ]}, scalar do {[undef, 2, 3]}, '[ OrderEnum->values ] # --> [undef, 2, 3]';

# 
# ## stashes ($cls)
# 
# Дополнения перечислений.
# 
done_testing; }; subtest 'stashes ($cls)' => sub { 
::is_deeply scalar do {[ OrderEnum->stashes ]}, scalar do {[undef, undef, {data => 123}]}, '[ OrderEnum->stashes ] # --> [undef, undef, {data => 123}]';

# 
# ## aliases ($cls)
# 
# Псевдонимы перечислений.
# 
# Файл lib/AuthorEnum.pm:
#@> lib/AuthorEnum.pm
#>> package AuthorEnum;
#>> 
#>> use Aion::Enum;
#>> 
#>> # Pushkin Aleksandr Sergeevich
#>> case 'Pushkin';
#>> 
#>> # Yacheykin Uriy
#>> case 'Yacheykin';
#>> 
#>> case 'Nouname';
#>> 
#>> 1;
#@< EOF
# 
done_testing; }; subtest 'aliases ($cls)' => sub { 
require AuthorEnum;
::is_deeply scalar do {[ AuthorEnum->aliases ]}, scalar do {['Pushkin Aleksandr Sergeevich', 'Yacheykin Uriy', undef]}, '[ AuthorEnum->aliases ] # --> [\'Pushkin Aleksandr Sergeevich\', \'Yacheykin Uriy\', undef]';

# 
# ## fromName ($cls, $name)
# 
# Получить case по имени c исключением.
# 
done_testing; }; subtest 'fromName ($cls, $name)' => sub { 
::is scalar do {OrderEnum->fromName('First')}, scalar do{OrderEnum->First}, 'OrderEnum->fromName(\'First\') # -> OrderEnum->First';
::like scalar do {eval { OrderEnum->fromName('not_exists') }; $@}, qr!Did not case with name `not_exists`\!!, 'eval { OrderEnum->fromName(\'not_exists\') }; $@ # ~> Did not case with name `not_exists`!';

# 
# ## tryFromName ($cls, $name)
# 
# Получить case по имени.
# 
done_testing; }; subtest 'tryFromName ($cls, $name)' => sub { 
::is scalar do {OrderEnum->tryFromName('First')}, scalar do{OrderEnum->First}, 'OrderEnum->tryFromName(\'First\')      # -> OrderEnum->First';
::is scalar do {OrderEnum->tryFromName('not_exists')}, scalar do{undef}, 'OrderEnum->tryFromName(\'not_exists\') # -> undef';

# 
# ## fromValue ($cls, $value)
# 
# Получить case по значению c исключением.
# 
done_testing; }; subtest 'fromValue ($cls, $value)' => sub { 
::is scalar do {OrderEnum->fromValue(undef)}, scalar do{OrderEnum->First}, 'OrderEnum->fromValue(undef) # -> OrderEnum->First';
::like scalar do {eval { OrderEnum->fromValue('not-exists') }; $@}, qr!Did not case with value `not-exists`\!!, 'eval { OrderEnum->fromValue(\'not-exists\') }; $@ # ~> Did not case with value `not-exists`!';

# 
# ## tryFromValue ($cls, $value)
# 
# Получить case по значению.
# 
done_testing; }; subtest 'tryFromValue ($cls, $value)' => sub { 
::is scalar do {OrderEnum->tryFromValue(undef)}, scalar do{OrderEnum->First}, 'OrderEnum->tryFromValue(undef)        # -> OrderEnum->First';
::is scalar do {OrderEnum->tryFromValue('not-exists')}, scalar do{undef}, 'OrderEnum->tryFromValue(\'not-exists\') # -> undef';

# 
# ## fromStash ($cls, $stash)
# 
# Получить case по дополнению c исключением.
# 
done_testing; }; subtest 'fromStash ($cls, $stash)' => sub { 
::is scalar do {OrderEnum->fromStash(undef)}, scalar do{OrderEnum->First}, 'OrderEnum->fromStash(undef) # -> OrderEnum->First';
::like scalar do {eval { OrderEnum->fromStash('not-exists') }; $@}, qr!Did not case with stash `not-exists`\!!, 'eval { OrderEnum->fromStash(\'not-exists\') }; $@ # ~> Did not case with stash `not-exists`!';

# 
# ## tryFromStash ($cls, $value)
# 
# Получить case по дополнению.
# 
done_testing; }; subtest 'tryFromStash ($cls, $value)' => sub { 
::is scalar do {OrderEnum->tryFromStash({data => 123})}, scalar do{OrderEnum->Other}, 'OrderEnum->tryFromStash({data => 123}) # -> OrderEnum->Other';
::is scalar do {OrderEnum->tryFromStash('not-exists')}, scalar do{undef}, 'OrderEnum->tryFromStash(\'not-exists\')  # -> undef';

# 
# ## fromAlias ($cls, $alias)
# 
# Получить case по псевдониму c исключением.
# 
done_testing; }; subtest 'fromAlias ($cls, $alias)' => sub { 
::is scalar do {AuthorEnum->fromAlias('Yacheykin Uriy')}, scalar do{AuthorEnum->Yacheykin}, 'AuthorEnum->fromAlias(\'Yacheykin Uriy\') # -> AuthorEnum->Yacheykin';
::like scalar do {eval { AuthorEnum->fromAlias('not-exists') }; $@}, qr!Did not case with alias `not-exists`\!!, 'eval { AuthorEnum->fromAlias(\'not-exists\') }; $@ # ~> Did not case with alias `not-exists`!';

# 
# ## tryFromAlias ($cls, $alias)
# 
# Получить case по псевдониму
# 
done_testing; }; subtest 'tryFromAlias ($cls, $alias)' => sub { 
::is scalar do {AuthorEnum->tryFromAlias('Yacheykin Uriy')}, scalar do{AuthorEnum->Yacheykin}, 'AuthorEnum->tryFromAlias(\'Yacheykin Uriy\') # -> AuthorEnum->Yacheykin';
::is scalar do {AuthorEnum->tryFromAlias('not-exists')}, scalar do{undef}, 'AuthorEnum->tryFromAlias(\'not-exists\')     # -> undef';

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
# # SEE ALSO
# 
# 1. [enum](https://metacpan.org/pod/enum).
# 2. [Class::Enum](https://metacpan.org/pod/Class::Enum).
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
