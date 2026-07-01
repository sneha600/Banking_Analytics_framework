use Banking_Analysis

--null values 
--account

select * from account
where account_id is null
or district_id is null
or frequency is null
or date is null
or account_type is null

--card

select * from card
where card_id is null
or disp_id is null
or type is null
or issued is null

--client

select * from client
where client_id is null
or birth_number is null
or district_id is null

--disposition

select * from disp
where disp_id is null
or client_id is null
or account_id is null
or type is null

--district

-- there is no column names defined for the district table so we defined with the help of data dictionery

EXEC sp_rename 'district.A1', 'district_id', 'COLUMN'
EXEC sp_rename 'district.A2', 'district_name', 'COLUMN'
EXEC sp_rename 'district.A3', 'region', 'COLUMN'
EXEC sp_rename 'district.A4', 'population', 'COLUMN'
EXEC sp_rename 'district.A5', 'municipality_statistics1', 'COLUMN'
EXEC sp_rename 'district.A6', 'municipality_statistics2', 'COLUMN'
EXEC sp_rename 'district.A7', 'municipality_statistics3', 'COLUMN'
EXEC sp_rename 'district.A8', 'municipality_statistics4', 'COLUMN'
EXEC sp_rename 'district.A9', 'number_of_cities', 'COLUMN'
EXEC sp_rename 'district.A10', 'urban_population_ratio', 'COLUMN'
EXEC sp_rename 'district.A11', 'average_salary', 'COLUMN'
EXEC sp_rename 'district.A12', 'unemployment_rates1', 'COLUMN'
EXEC sp_rename 'district.A13', 'unemployment_rates2', 'COLUMN'
EXEC sp_rename 'district.A14', 'entrepreneurs_per_1000_resident', 'COLUMN'
EXEC sp_rename 'district.A15', 'crime_statistics1', 'COLUMN'
EXEC sp_rename 'district.A16', 'crime_statistics2', 'COLUMN'


---Check duplicates

--account

select account_id , count(*) from account
group by account_id
having count(*)>1

--card

select card_id, count(*) from card
group by card_id
having count(*)>1

--client

select client_id , count(*) from client
group by client_id
having count(*)>1

--dispositon

select disp_id , count(*) from disp
group by disp_id
having count(*)>1

--district

select district_id , count(*) from district
group by district_id
having count(*)>1

--loan

select loan_id , count(*) from loan
group by loan_id
having count(*)>1

--order

select order_id , count(*) from [order]
group by order_id
having count(*)>1

--master_transaction

select trans_id , count(*) from master_transaction
group by trans_id
having count(*)>1



--district contains null values in some column but we need to impute it because our district id is linked with it

select * from district
where district_id is null
or district_name is null
or region is null
or population is null
or municipality_statistics1 is null
or municipality_statistics2 is null
or municipality_statistics3 is null
or municipality_statistics4 is null
or number_of_cities is null
or urban_population_ratio is null
or average_salary is null
or unemployment_rates1 is null
or unemployment_rates2 is null
or entrepreneurs_per_1000_resident is null
or crime_statistics1 is null
or crime_statistics2 is null


--- IN North Moravia region the value of unemployment_rates and crime_statistics is null in one record
--- Imputed the unemployment_rates1 with avg of unemployment_rates1 within that region
--- Imputed the crime_statistics1 with avg of crime_statistics1 within that region
update district
set unemployment_rates1=(
select avg(unemployment_rates1) from district
where region='north Moravia'
and unemployment_rates1 is not null)
where district_name='Jesenik'
and
unemployment_rates1 is null


update district
set crime_statistics1=(
select avg(crime_statistics1) from district
where region='north Moravia'
and crime_statistics1 is not null)
where district_name='Jesenik'
and crime_statistics1 is null



--loan

select * from loan
where loan_id is null
or account_id is null
or date is null
or amount is null
or duration is null
or payments is null
or status is null

--- there are 6 transaction table we created one master transaction table of them
select * into master_transaction from(
select * from trnx_16
union all
select * from trnx_17
union all
select * from trnx_18
union all
select * from trnx_19_NEW
union all
select * from trnx_20_NEW
union all
select * from trnx_21_NEW
) as t

-- there are 870465 values are null in the master transaction table we need to deal with them

select count(*) from master_transaction 
where trans_id is null
or account_id is null
or date is null
or type is null
or operation is null
or amount is null
or balance is null
or purpose is null
or bank is null
or account_partern_id is null
-- the date column of tables like account , card , loan is inconsistent so corrrect the data type of that columns

select date from account
alter table account
alter column [date] date

select issued from card
alter table account
alter column issued date

select date from loan
alter table account
alter column [date] date

--- in client table birth_number is decoded so we encoded it by subtracting 50 from the month where month is >12 else remain as it is 
alter table client
add final_dob Date;
update client
set final_dob=datefromparts(

--added 1900 to year for consistent year 

 1900+cast(left(cast(birth_number as varchar(20)), 2 )as int ), 
 case 
 when cast(substring(cast(birth_number as varchar(20)), 3,2 )as int)>12-- where month is>12
 then cast(substring(cast(birth_number as varchar(20)), 3,2 )as int)-50 -- subtract 50
else cast(substring(cast(birth_number as varchar(20)), 3,2 )as int)-- else leve as it is 
end,
cast(right(cast(birth_number as varchar(20)) , 2 )as int))

--- there is inconssitency in age and eligibility for an account so we can that our data is of year 2016 to 2021 

alter table client
add age int 
update client
set age=datediff( year , final_dob, getdate())
- case when dateadd(year,datediff(year,final_dob,getdate()),final_dob)>getdate()
then 1
else 0 end;

-- some clients are not even eligibible for the account opening

select C.account_id,final_dob,type, [date],disp_id  from client as A
join disp as B
on A.client_id= B.client_id
join 
account as C
on 
B.account_id=C.account_id
where year(date)>1980
and year(final_dob)>=1980


--- we will continue with adding 23 to dates of client , card and loans

select final_date from account
select final_issued_date from card
select final_date from loan


--- Check whether all ditrict_id from account mapped to correct district code

select A.district_id , B.district_id  from account as A
left join
district as B
on A.district_id=B.district_id
where A.district_id is null

/*many accounts does not have same district in all the tables 
it is normal because in client's table the district is his residence 
and in account's table the district belongs to that branch in which he openedd his account*/

select A.client_id, C.account_id, A.district_id,B.type, C.district_id from client as A
join disp as B
on A.client_id= B.client_id
join 
account as C
on 
B.account_id=C.account_id
where A.district_id!=C.district_id


--- we have checked whether any client in same account hold both type user and owner but there is no one.

select client_id , account_id from disp
group by client_id , account_id
having count(distinct type)>1

-- checked whether loan status is correct or not 
-- loan status is correct for all the records
alter table loan 
add completion_date date
select * from loan
update loan
set completion_date=dateadd(month , duration , final_date) from loan
select * from loan
where year(completion_date)=2026
and status='B'and status='A'

---order table dont have any inconssitency all tha orders are unique 

select trans_id,  count(*) from master_transaction
group by trans_id
having count(*)>1



--- in master transaction table there are many bank information , account parner_id , purpose is missing 
--- we derived the master transaction table from the 6 different trsaction table which belongs to different years between 2016 to 2021
--- so to impute this we will check whther the transaction from same account id for same purpose with same bank has done in any other years or not
---if it is done we will fill out this
---In same way we will impute bank , purpose etc


select * from master_transaction
where account_partern_id  is not null

--- account_partener_id is null in many cases
--- when there is situation when type of transaction is withdrawal and operation is withdrawl in cash 
--- so in this case there is not any link with account partener id that's why account partener is null
--- there are 432377 records of this situation 
--- so we mark this valueto be not defined or null
select * from master_transaction

where Type ='withdrawal'
and operation='withdrawal in cash'

--- changed the datatype of account_parteren_id (int to varchar(50))
--- as in case of withdrawal in cash operation account_partern_id is not applibale
--- at the place of null i replced not applicable for better unerstanding
alter table master_transaction 
alter column account_partern_id varchar(50)
update master_transaction
set account_partern_id='Not applicable'
where Type ='withdrawal'
and operation='withdrawal in cash'


---- when the account is remitted to another bank then the account partener id is present 
---- In this case every transaction have account partener id 

select * from master_transaction
where Type= 'withdrawal'
and operation != 'withdrawal in cash'

--- there is one case in which purpose is loan payment and account partern id is null 
---impute it by finding the loan of previous month with same information
---Generally in loan purpose the account_partern_id is not applicable
---in previous loans the bank name is different so we will impute it with not aplicable

select * from master_transaction
where Type= 'withdrawal'
and operation != 'withdrawal in cash'
and purpose='Loan Payment'
and account_partern_id is null

update master_transaction
set account_partern_id='Not applicable'
where purpose='Loan Payment'
and operation !='withdrawal in cash'
and account_partern_id is null


---- some records in which operation is interest credit and credit in cash  and account parteren id and bank is missing
---- it is totally fine 
---- we will impute them with the value not applicable in both cases

select count(*) from master_transaction
where operation='Interest Credit'
and account_partern_id is null

update master_transaction
set account_partern_id='Not applicable'
where operation='Interest Credit'
and account_partern_id is null

--- in this operation the purpose is null so we will impute it with cash deposit 
select * from master_transaction
where operation='Credit in cash'
and account_partern_id is null

update master_transaction
set Purpose='cash deposit'
where operation='Credit in cash'
and account_partern_id is null


--- in credit card withdrawl operation the bank is mising 
--- this is totally fine we can impute with not applicable
--- account partern id is 0 it is also fine
---as purpose is not defined for the credit card withdrawal operation so impute it with not applicable
---bank is also not applicable in this operation
--- replaced account_partern_id with not applicable where it is 0

select * from master_transaction
where operation='Credit card withdrawal'
and account_partern_id is not  null

select * from master_transaction
where operation='Credit card withdrawal'
and bank is null
and Purpose is null

update master_transaction
set purpose='Not applicable'
where operation='Credit card withdrawal'



update master_transaction
set account_partern_id='Not applicable'
where operation='Credit card withdrawal'
and account_partern_id='0'


---in electronic funds transfer  account id not null
select * from master_transaction
where operation='Electronic funds transfer'
and account_partern_id is null

---- in electronic funds operation there is some null values in purpose 
----impute them by checking from previous year or month 

select * from master_transaction
where operation='Electronic funds transfer'
and purpose is null

---there is a lot of missing balannce values in the dataset so we will check the all previous values of balance and match with operation
--- if operation is withdrawl then we will subtract from the previos balance 
---if operation is credit we will add to previous balance 
--- we need to do for every account id
---after checking found thatwhen i tried to caculate the balance 
----there is mismatch between the balance and imputed balance 
--so decided to go with null values
select * from master_transaction
where balance is null

alter table master_transaction
drop column imputed_balance

----- for further analysis create table customer 360 for customer behaviour analysis 

create table client_360(
client_id int primary key, 
age int ,
gender varchar(10),
district varchar(50),
have_account_flag bit ,
total_account tinyint,
owner_account_count tinyint,
user_account_count tinyint,
saving_account_count tinyint,
salary_account_count tinyint,
NRI_account_count tinyint,
avg_balance decimal(18,2),
no_of_accounts smallint,
prouct_usage int,
product_used varchar(100),
active_loan_flag bit,
account_opening_date date,
account_type varchar(100),
total_transaction_per_month int,
frequency varchar(100),
disposition_id int,
[owner/user] varchar(20),
monthly_fee_count tinyint,
weekly_fee_count  tinyint,
per_transaction_fee_count tinyint,
customer_level varchar(100))

select * from client_360

insert into client_360(client_id , age)
select client_id , age from client

update client_360
set gender=case
when cast(substring(cast(c.birth_number as varchar),3,2)as int)>12
then 'female'
else 'male'
end
from client_360 as c_360
join client as c
on C_360.client_id=c.client_id


update c_360
set c_360.district=d.district_name
from client_360 as c_360
join client as c
on c_360.client_id=c.client_id
join district as d
on c.district_id=d.district_id

update client_360
set have_account_flag=
case
when a.account_id is not null then 1 
else 0
end
from client_360 as c_360
left join disp as d
on c_360.client_id=d.client_id
left join account as a
on d.account_id=a.account_id

update c_360
set total_account=x.total_account
from client_360 as c_360
join
(select client_id , count(distinct(account_id)) as total_account
from disp
group by client_id) x
on c_360.client_id=x.client_id

update c_360
set owner_account_count=x.owner_cnt
from client_360 as c_360
join
(select client_id , count(distinct account_id) as owner_cnt
from disp
where type='owner'
group by client_id
)as x
on c_360.client_id=x.client_id

update client_360
set owner_account_count=0
where owner_account_count is null

update c_360
set user_account_count=x.user_cnt
from client_360 as c_360
join
(select client_id , count(distinct account_id) as user_cnt from disp
where type='user'
group by client_id) as x
on c_360.client_id=x.client_id

update client_360
set user_account_count=0
where user_account_count is null

update c_360
set saving_account_count=x.saving_cnt
from client_360 as c_360
join
(select d.client_id, count(distinct d.account_id) as saving_cnt from disp as d
join
account as a
on a.account_id=d.account_id
where a.Account_type='Savings account'
group by d.client_id) as x
on c_360.client_id=x.client_id


update client_360
set saving_account_count=0
where saving_account_count is null

update c_360
set salary_account_count=x.salary_cnt
from client_360 as c_360
join
(select d.client_id, count(distinct d.account_id) as salary_cnt from disp as d
join
account as a
on a.account_id=d.account_id
where a.Account_type='Salary account'
group by d.client_id) as x
on c_360.client_id=x.client_id


update client_360
set salary_account_count=0
where salary_account_count is null


update c_360
set NRI_account_count=x.NRI_cnt
from client_360 as c_360
join
(select d.client_id, count(distinct d.account_id) as NRI_cnt from disp as d
join
account as a
on a.account_id=d.account_id
where a.Account_type='NRI account'
group by d.client_id) as x
on c_360.client_id=x.client_id


update client_360
set NRI_account_count=0
where NRI_account_count is null

update c_360
set avg_balance=x.avg_balance
from client_360 as c_360
 



;with latest_balance as(
select account_id,balance,ROW_NUMBER() over(
partition by account_id
order by [date] desc, trans_id desc) as rn from master_transaction
where balance is not null
)
update c_360
set avg_balance = x.avg_balance
from client_360 as c_360
join
(select d.client_id,avg(cast(lb.balance as decimal(18,2))) as avg_balance
from disp d
join latest_balance lb
on d.account_id = lb.account_id
where lb.rn = 1
group by d.client_id
) x
on c_360.client_id = x.client_id;

exec sp_rename 'client_360.prouct_usage','card_type','column';

select * from client_360

alter table client_360
alter column card_type varchar(50)


update c_360
set card_type = x.card_type
from client_360 as c_360
join 
(select d.client_id , c.type as card_type from disp as d
join card as c
on d.disp_id=c.disp_id) as x
on c_360.client_id=x.client_id

update client_360
set card_type='No card'
where card_type is null

update c_360
set active_loan_flag=x.active_flag
from client_360 as c_360
join(
select d.client_id , 1 as active_flag from disp as d
join loan as l
on d.account_id=l.account_id
where l.status  in('C','D')
group by d.client_id
) as x
on c_360.client_id=x.client_id

update  client_360
set active_loan_flag=0
where active_loan_flag is null

update c_360
set account_opening_date=x.date
from client_360 as c_360
join(select d.client_id , min(A.final_date) as date from disp as d
join account as A
on A.account_id=d.account_id
group by d.client_id) as x
on c_360.client_id=x.client_id

update client_360
set total_transaction_per_month=x.tt_per_month
from client_360 as c_360
join( select d.client_id, cast(count(*) * 1.0 /count(distinct format(mt.[date],'yyyy-MM'))as decimal(10,2)) AS tt_per_month
 from disp as d
join master_transaction as mt
on d.account_id=mt.account_id
group by d.client_id) as x
on c_360.client_id=x.client_id
select * from client_360
exec sp_rename 'client_360.monthly_fee', 'monthly_fee_flag', 'column'
exec sp_rename 'client_360.weekly_fee_count', 'weekly_fee_flag', 'column'
exec sp_rename 'client_360.monthly_fee_flag', 'transaction_fee_flag', 'column'


update client_360
set monthly_fee_flag = 0

update c360
set monthly_fee_flag = 1
from client_360 c360
where exists
(select  1 from disp d
    join account  as a
    on  d.account_id = a.account_id
    where d.client_id = c360.client_id
      and a.frequency = 'POPLATEK MESICNE'
);

update client_360
set weekly_fee_flag = 0

update c360
set weekly_fee_flag = 1
from client_360 c360
where exists
(select  1 from disp d
    join account  as a
    on  d.account_id = a.account_id
    where d.client_id = c360.client_id
      and a.frequency = 'POPLATEK TYDNE'
);

update client_360
set transaction_fee_flag = 0

update c360
set transaction_fee_flag = 1
from client_360 c360
where exists
(select  1 from disp d
    join account  as a
    on  d.account_id = a.account_id
    where d.client_id = c360.client_id
      and a.frequency = 'POPLATEK PO OBRATU'
);


update district
set unemployment_rates1=null,
crime_statistics1=null
where district_id=(select top 1 district_id from district
order by district_id asc 
)

alter table client_360
add last_trans_date date


update c_360
set last_trans_date = x.last_txn_date
from client_360 as  c_360
join(
select d.client_id,max(mt.[date]) as last_txn_date
from disp as d
join master_transaction mt
on d.account_id = mt.account_id
group by d.client_id
) as x
on c_360.client_id = x.client_id;
exec sp_rename 'client_360.saving_account_count' , 'saving_account_flag','column'
exec sp_rename 'client_360.NRI_account_count' , 'NRI_account_flag','column'
exec sp_rename 'client_360.salary_account_count' , 'salary_account_flag','column'


exec sp_rename 'client_360.owner_account_count' , 'owner_account_flag','column'
exec sp_rename 'client_360.user_account_count' , 'user_account_flag','column'
select * from client_360