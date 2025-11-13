!ru:en,badges
# NAME

Aion::Enum - перечисления в стиле ООП, когда каждое перечсление является объектом

# VERSION

0.0.0-prealpha

# SYNOPSIS

```perl
package StatusEnum {
    use Aion::Enum;

    case 'Active';
    case 'Passive';
}

&StatusEnum::Active->does('Aion::Enum') # => 1

StatusEnum->Active->name  # => Active
StatusEnum->Passive->name # => Passive

[ StatusEnum->names ] # --> [qw/Active Passive/]
```

# DESCRIPTION

`Aion::Enum` позволяет создавать перечисления-объекты. Данные перечисления могут содержать дополнительные методы и свойства. В них можно добавлять роли (с помощью `with`) или использовать их самих как роли.

Важной особенностью является сохранение порядка перечисления.

`Aion::Enum` подобен перечислениям из php8, но имеет дополнительные свойства `alias` и `stash`.

# SUBROUTINES

## case ($name, [$value, [$stash]])

Создаёт перечисление: его константу.

```perl
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
```

## issa ($valisa, [$staisa])

Указывает тип (isa) значений и дополнений.

Её название – отсылка к богине Иссе из повести «Под лунами Марса» Берроуза.

```perl
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
```

# CLASS METHODS

## cases ($cls)

Список перечислений.

```perl
[ OrderEnum->cases ] # --> [OrderEnum->First, OrderEnum->Second, OrderEnum->Other]
```

## names ($cls)

Имена перечислений.

```perl
[ OrderEnum->names ] # --> [qw/First Second Other/]
```

## values ($cls)

Значения перечислений.

```perl
[ OrderEnum->values ] # --> [undef, 2, 3]
```

## stashes ($cls)

Дополнения перечислений.

```perl
[ OrderEnum->stashes ] # --> [undef, undef, {data => 123}]
```

## aliases ($cls)

Псевдонимы перечислений.

Файл lib/AuthorEnum.pm:
```perl
package AuthorEnum;

use Aion::Enum;

# Pushkin Aleksandr Sergeevich
case 'Pushkin';

# Yacheykin Uriy
case 'Yacheykin';

case 'Nouname';

1;
```

```perl
require AuthorEnum;
[ AuthorEnum->aliases ] # --> ['Pushkin Aleksandr Sergeevich', 'Yacheykin Uriy', undef]
```

## fromName ($cls, $name)

Получить case по имени c исключением.

```perl
OrderEnum->fromName('First') # -> OrderEnum->First
eval { OrderEnum->fromName('not_exists') }; $@ # ~> Did not case with name `not_exists`!
```

## tryFromName ($cls, $name)

Получить case по имени.

```perl
OrderEnum->tryFromName('First')      # -> OrderEnum->First
OrderEnum->tryFromName('not_exists') # -> undef
```

## fromValue ($cls, $value)

Получить case по значению c исключением.

```perl
OrderEnum->fromValue(undef) # -> OrderEnum->First
eval { OrderEnum->fromValue('not-exists') }; $@ # ~> Did not case with value `not-exists`!
```

## tryFromValue ($cls, $value)

Получить case по значению.

```perl
OrderEnum->tryFromValue(undef)        # -> OrderEnum->First
OrderEnum->tryFromValue('not-exists') # -> undef
```

## fromStash ($cls, $stash)

Получить case по дополнению c исключением.

```perl
OrderEnum->fromStash(undef) # -> OrderEnum->First
eval { OrderEnum->fromStash('not-exists') }; $@ # ~> Did not case with stash `not-exists`!
```

## tryFromStash ($cls, $value)

Получить case по дополнению.

```perl
OrderEnum->tryFromStash({data => 123}) # -> OrderEnum->Other
OrderEnum->tryFromStash('not-exists')  # -> undef
```

## fromAlias ($cls, $alias)

Получить case по псевдониму c исключением.

```perl
AuthorEnum->fromAlias('Yacheykin Uriy') # -> AuthorEnum->Yacheykin
eval { AuthorEnum->fromAlias('not-exists') }; $@ # ~> Did not case with alias `not-exists`!
```

## tryFromAlias ($cls, $alias)

Получить case по псевдониму

```perl
AuthorEnum->tryFromAlias('Yacheykin Uriy') # -> AuthorEnum->Yacheykin
AuthorEnum->tryFromAlias('not-exists')     # -> undef
```

# FEATURES

## name

Свойство только для чтения.

```perl
package NameEnum {
    use Aion::Enum;

    case 'Piter';
}

NameEnum->Piter->name # => Piter
```

## value

Свойство только для чтения.

```perl
package ValueEnum {
    use Aion::Enum;

    case Piter => 'Pan';
}

ValueEnum->Piter->value # => Pan
```

## stash

Свойство только для чтения.

```perl
package StashEnum {
    use Aion::Enum;

    case Piter => 'Pan', 123;
}

StashEnum->Piter->stash # => 123
```

## alias

Свойство только для чтения.

Алиасы работают только если пакет находится в модуле, так как считывают комментарий перед кейсом за счёт рефлексии.

Файл lib/AliasEnum.pm:
```perl
package AliasEnum;

use Aion::Enum;

# Piter Pan
case 'Piter';

1;
```

```perl
require AliasEnum;
AliasEnum->Piter->alias # => Piter Pan
```

# SEE ALSO

1. [enum](https://metacpan.org/pod/enum).
2. [Class::Enum](https://metacpan.org/pod/Class::Enum).

# AUTHOR

Yaroslav O. Kosmina [dart@cpan.org](mailto:dart@cpan.org)

# LICENSE

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.

⚖ **GPLv3**

# COPYRIGHT

The Aion::Enum module is copyright © 2025 Yaroslav O. Kosmina. Rusland. All rights reserved.
