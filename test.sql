prepare foo(age:int = 10, name:text = 'hoge') as
select * from people
where name = {name} and age = {age}
;

prepare hoge(age:int, name:text) as
select age from people
where name = {name} and age = {age}
;

prepare hige(name:text = "hihihi") as
select age from people
where name = {name}
;

prepare hage(name:text, alive:bool = true) as
select age from people
where name = {name} and alive is {alive}
;

