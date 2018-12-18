//SQL 结构化查询语句

//Oracle（收费）   甲骨文
//Mysql （开源）   - 集群  Linux-Mysql-apache-php LAMP

//Sqlite3（重点，小型数据库，用在移动设备，小型数据库） 封装－－》FMDB，Coredata
//MongoDB

/*
 数据库：database   .db(后缀)
 表：table
 */

//增  删(delete from....where)改(up)  查
//主键 唯一标识一条记录
/*  主键
 1.创建表
 create table [if not exists](判断表格是否存在,不存在，则创建) 表名
 (
 属性名 类型(字符个数，可以省略) primary key（主键） autoincrement(自增＋＋，只能用于integer),
 属性名 类型(字符个数，可以省略) ,
 属性名 类型(字符个数，可以省略) ,
 属性名 类型(字符个数，可以省略)
 );
 注意类型有integer,real,text,blob等
 例如：
 create table if not exists Book
 (
 no integer primary key autoincrement,
 name text,
 url text,
 des text
 );
 Create Update Selecte Delete
 
 2.表中插入数据
 insert into 表名 (属性名2,属性名1) values ('','');
 例如
 insert into Book (name,url,des) values ('霍金全集','www.baidu.com','描述');
 
 3.查询
 select 字段名（*代表所有字段，如果有多个字段用英文的,分割） from 表名字 [where 字段名=‘’] [order by 字段名 desc|asc];
 
 注意：1,where判断 > , >= ,< , <=,between 字段 and 字段
      2,desc降序  asc升序
 
 
 //条件查询
 select * from stuent where stuname like '%张%'
 {
    select * from student where stuno in (1,9) 等价于
    select * from student where stuno=1 or stuno=9
 }
 select * from student where stuno between 1 and 9 范围查询
 select * from student limit 3  查询前3条
 select * from student order by stuno desc|asc  降序or升序
 select * from student order by stuno asc limit 3
 
 
 例如：
（1）查询表中所有字段数据
         select * from Book;
（2）查询判断的条件
        通过字段
         select * from Book where 字段名='';
          select name,url from Book where name = '钢铁是怎么炼成的'
 4.模糊查询
 select 字段名 from 表名 where  属性 like '%关键字%'; rangOfString
                                         %关键字       endWith
                                          关键字%      startWith
 
 例如
 select * from Book where  name like '%钢铁%';
 
 5.IN查询
 select 字段名 from 表名 where 字段名 in ('关键字','关键字');
 
 例如：
 select * from Book where name in ('我的青春','钢铁是怎么炼成的');
 
 6.更新
 update 表名 set 属性名 = '关键字' where 属性名 = 关键字
 例如：
 update Book set url='www.aaa.com' where id = 2
 
 
 7.删除数据
 delete from 表名
 
 例如：
 delete from Book where age = ‘18’ and name = '张三';
 
 8.删除整张表
 drop table 表名;
 
 9.添加属性(字段)
 alter table 表名 add column 属性名 类型;
 
 例如：
 alter table Book add column price integer;
 聚合函数
 10.求和
 select sum(属性名) from 表名
 
 例如：
 select sum(age) from User
 
 11.求平均值
 select avg(属性名) from 表名
 
 例如：
 select avg(age) from User
 
 12.求最大值
 select max(属性名) from 表名
 
 例如：
 select max(age) from User
 
 13.求最小值
 select min(属性名) from 表名
 
 例如：
 select min(age) from User
 
 14.求元组个数
 select count(*) from 表名
 select count(distinct|all 属性名) from 表名
 
 如果指定DISTINCT短语，则表示在计算时要取消指定列中的重复值。如果不指定DISTINCT短语或指定ALL短语（ALL为缺省值），则表示不取消重复值。
 
 
 例如：
 select count(*) from User
 select count(distinct name) from User;
 
 */



