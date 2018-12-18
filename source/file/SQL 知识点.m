
/* if not exists 判断person表是否存在,不存在则创建    */
/* 数据库中有一个主键的概念 primary key */
/*autoincrement 自增++ ,只能用在integer类型上 */
create table if not exists  Person (id integer primary key autoincrement, name text, age integer);

//数据插入
insert into Person (id, name, age) values (1, "张三", 18)
//如果是给所有属性赋值,values的顺序需要和建表顺序一致
insert into Person /*(id, name, age)*/ values(1, "张安", 18)

//更新数据
update Person set name="lisi",age=20 where id=3

//数据删除
delete from Person 删除所有数据
delete from Person where age=18 根据条件删除数据

//查询
select * from Person //查询所有字段
select name,age from Person //查询指定字段
select * from Person where name != "lisi" or/and age != 18 //条件查询,或者/并且
select * from Person where name like "%li%" //模糊查询
//以xx开头  li%
//以xx结尾  %li
//包含xx    %li%
select * from Person where name not like "li%" //模糊查询,与like结果相反
select * from Person where id between 50 and 200 //查询id在指定范围内的数据
select * from Person order by id asc //按照id升序排列,降序为desc


select sum(age) from Person //总和
select avg(age) from Person //平均
select max(age) from Person //最大
select min(age) from Person //最小



















