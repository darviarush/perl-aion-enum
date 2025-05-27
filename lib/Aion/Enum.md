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

&StatusEnum::Active->isa('StatusEnum')   # => 1
StatusEnum::Active()->does('Aion::Enum') # => 1

StatusEnum->Active->name  # => Active
StatusEnum->Passive->name # => Passive

[ StatusEnum->names ] # --> [qw/Active Passive/]
```

# DESCRIPTION

`Aion::Enum` позволяет создавать перечисления-объекты. Данные перечисления могут содержать дополнительные методы и свойства. В них можно добавлять роли (с помощью `with`) или использовать их самих как роли.

Важной особенностью является сохранение порядка перечисления.

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

```perl
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

# METHODS

## from ($value)



# AUTHOR

Yaroslav O. Kosmina [dart@cpan.org](mailto:dart@cpan.org)

# LICENSE

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.

⚖ **GPLv3**

# COPYRIGHT

The Aion::Enum module is copyright © 2025 Yaroslav O. Kosmina. Rusland. All rights reserved.
