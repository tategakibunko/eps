# eps

extended prepared statement language.

## Summary

Labeled argument with type and default value are enabled in prepared statement.

```sql
/* test.sql */
prepare foo(age:int, name:text = "no name") as select * from people where age = {age} and name = {name};
```

## Output

You can output SQL or OCaml code.

1. SQL

```sql
/* eps.exe -input test.sql -format sql */
prepare foo(int, text) as select * from people where age = $1 and name = $2;
```

2. OCaml code

```ocaml
/* eps.exe -input test.sql -format ocaml */

let prep_foo =
  "prepare foo(int, text) as select * from people where age = $1 and name = $2;"

let exec_foo ~age ?(name="no name") () =
  Printf.sprintf "execute foo(%d, '%s');" age name
```

## Prerequisite

1. OCaml(>= 3.12)
2. pcre(pcre-ocaml)

## Build

Just `make` and `eps.exe` is generated.

## License

MIT

