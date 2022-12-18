use assignment;
SET SQL_SAFE_UPDATES = 0;
## 1 . Create a new table named 'bajaj1' containing the date, close price, 20 Day MA and 50 Day MA. (This has to be done for all 6 stocks)

# bajaj_auto

alter table `bajaj_auto`
add format_date date;

update `bajaj_auto` set format_date = str_to_date(date, '%d-%M-%Y');

drop table if exists `bajaj1`;

create table bajaj1
  as (select format_date as `Date`, `Close Price` as  `Close Price` , 
  avg(`Close Price`) over (order by format_date asc rows 19 preceding) as `20 Day MA`,
  avg(`Close Price`) over (order by format_date asc rows 49 preceding) as `50 Day MA`,
  row_number()     over (order by `format_date` ) as `row_num`
  from `bajaj_auto`);
  
# ignoring values as calculation is inappropriate 
delete from bajaj1 
where  row_num < 50;

alter table bajaj1
drop column row_num;
  
select * from bajaj1 order by `Date`;
 

# eicher motors

alter table `eicher_motors`
add format_date date;

update `eicher_motors` set format_date = str_to_date(date, '%d-%M-%Y');

drop table if exists `eicher1`;

create table eicher1
  as (select `format_date` as `Date`, `Close Price` as  `Close Price` , 
  avg(`Close Price`) over (order by format_date asc rows 19 preceding) as `20 Day MA`,
  avg(`Close Price`) over (order by format_date asc rows 49 preceding) as `50 Day MA`,
  row_number()     over (order by `format_date` ) as `row_num`
  from `eicher_motors`);
  
# ignoring values as calculation is inappropriate  
delete from eicher1 
where  row_num < 50;

alter table eicher1
drop column row_num;

select * from eicher1 order by `Date`;


# hero motocorp

alter table `hero_motocorp`
add format_date date;

update `hero_motocorp` set format_date = str_to_date(date, '%d-%M-%Y');

drop table if exists `hero1`;

create table hero1
  as (select `format_date` as `Date`, `Close Price` as  `Close Price` , 
  avg(`Close Price`) over (order by format_date asc rows 19 preceding) as `20 Day MA`,
  avg(`Close Price`) over (order by format_date asc rows 49 preceding) as `50 Day MA`,
   row_number()     over (order by `format_date` ) as `row_num`
  from `hero_motocorp`);

# ignoring values as calculation is inappropriate 
delete from hero1 
where  row_num < 50;

alter table hero1
drop column row_num;

select * from hero1 order by `Date`;

# infosys

alter table `infosys`
add format_date date;

update `infosys` set format_date = str_to_date(date, '%d-%M-%Y');

drop table if exists `infosys1`;

create table infosys1
  as (select `format_date` as `Date`, `Close Price` as  `Close Price` , 
  avg(`Close Price`) over (order by format_date asc rows 19 preceding) as `20 Day MA`,
  avg(`Close Price`) over (order by format_date asc rows 49 preceding) as `50 Day MA`,
   row_number()     over (order by `format_date` ) as `row_num`
  from `infosys`);

# ignoring values as calculation is inappropriate 
delete from infosys1 
where  row_num < 50;

alter table infosys1
drop column row_num;

select * from infosys1 order by `Date`;

# tcs

alter table `tcs`
add format_date date;

update `tcs` set format_date = str_to_date(date, '%d-%M-%Y');

drop table if exists `tcs1`;

create table tcs1
  as (select `format_date` as `Date`, `Close Price` as  `Close Price` , 
  avg(`Close Price`) over (order by format_date asc rows 19 preceding) as `20 Day MA`,
  avg(`Close Price`) over (order by format_date asc rows 49 preceding) as `50 Day MA`,
   row_number()     over (order by `format_date` ) as `row_num`
  from `tcs`);

# ignoring values as calculation is inappropriate 
delete from tcs1 
where  row_num < 50;

alter table tcs1
drop column row_num;

select * from tcs1 order by `Date`;

# tvs motors

alter table `tvs_motors`
add format_date date;

update `tvs_motors` set format_date = str_to_date(date, '%d-%M-%Y');

drop table if exists `tvs1`;

create table tvs1
  as (select `format_date` as `Date`, `Close Price` as  `Close Price` , 
  avg(`Close Price`) over (order by format_date asc rows 19 preceding) as `20 Day MA`,
  avg(`Close Price`) over (order by format_date asc rows 49 preceding) as `50 Day MA`,
  row_number()     over (order by `format_date` ) as `row_num`
  from `tvs_motors`);

# ignoring values as calculation is inappropriate 
delete from tvs1 
where  row_num < 50;

alter table tvs1
drop column row_num;

select * from tvs1 order by `Date`;

## 2. Create a master table containing the date and close price of all the six stocks. (Column header for the price is the name of the stock)

drop table if exists `master`;

create table master
select baj.format_date as Date , baj.`Close Price` as Bajaj , tcs.`Close Price` as TCS , 
tvs.`Close Price` as TVS , inf.`Close Price` as Infosys , eic.`Close Price` as Eicher , her.`Close Price` as Hero
from `bajaj_auto` baj
inner join `tcs` tcs on tcs.format_date = baj.format_date
inner join `tvs_motors` tvs on tvs.format_date = baj.format_date
inner join `infosys` inf on inf.format_date = baj.format_date
inner join `eicher_motors` eic on eic.format_date = baj.format_date
inner join `hero_motocorp` her on her.format_date = baj.format_date ;

select * from master order by `Date`;

## 3. Use the table created in Part(1) to generate buy and sell signal. Store this in another table named 'bajaj2'. Perform this operation for all stocks.

# bajaj2

drop table if exists `bajaj2`;

create table bajaj2 as
select 
		date_value AS "Date",
		close_price AS "Close Price",
		case when first_value(short_term_greater) over w = nth_value(short_term_greater,2) over w then  'Hold'
				when NTH_VALUE(short_term_greater,2) over w = 'Y' then 'Buy'
				when NTH_VALUE(short_term_greater,2) over w = 'N' then 'Sell'
                else 'Hold'
                end
			
		 AS "Signal" 
	FROM
(
select
		`Date` as date_value,
		`Close Price` AS close_price,
		if(`20 Day MA`>`50 Day MA`,'Y','N') short_term_greater
	from
		bajaj1 
) temp_table
window w as (order by date_value rows between 1 preceding and 0 following);

select * from bajaj2 order by `Date`;


# eicher2

drop table if exists `eicher2`;

create table eicher2 as
select 
		date_value AS "Date",
		close_price AS "Close Price",
		case when first_value(short_term_greater) over w = nth_value(short_term_greater,2) over w then  'Hold'
				when NTH_VALUE(short_term_greater,2) over w = 'Y' then 'Buy'
				when NTH_VALUE(short_term_greater,2) over w = 'N' then 'Sell'
                else 'Hold'
                end
			
		 AS "Signal" 
	FROM
(
select
		`Date` as date_value,
		`Close Price` AS close_price,
		if(`20 Day MA`>`50 Day MA`,'Y','N') short_term_greater
	from
		eicher1 
) temp_table
window w as (order by date_value rows between 1 preceding and 0 following);

select * from eicher2 order by `Date`;

# hero2

drop table if exists `hero2`;

create table hero2 as
select 
		date_value AS "Date",
		close_price AS "Close Price",
		case when first_value(short_term_greater) over w = nth_value(short_term_greater,2) over w then  'Hold'
				when NTH_VALUE(short_term_greater,2) over w = 'Y' then 'Buy'
				when NTH_VALUE(short_term_greater,2) over w = 'N' then 'Sell'
                else 'Hold'
                end
			
		 AS "Signal" 
	FROM
(
select
		`Date` as date_value,
		`Close Price` AS close_price,
		if(`20 Day MA`>`50 Day MA`,'Y','N') short_term_greater
	from
		hero1 
) temp_table
window w as (order by date_value rows between 1 preceding and 0 following);
  
select * from hero2 order by `Date`;

# infosys2

drop table if exists `infosys2`;

create table infosys2 as
select 
		date_value AS "Date",
		close_price AS "Close Price",
		case when first_value(short_term_greater) over w = nth_value(short_term_greater,2) over w then  'Hold'
				when NTH_VALUE(short_term_greater,2) over w = 'Y' then 'Buy'
				when NTH_VALUE(short_term_greater,2) over w = 'N' then 'Sell'
                else 'Hold'
                end
			
		 AS "Signal" 
	FROM
(
select
		`Date` as date_value,
		`Close Price` AS close_price,
		if(`20 Day MA`>`50 Day MA`,'Y','N') short_term_greater
	from
		infosys1 
) temp_table
window w as (order by date_value rows between 1 preceding and 0 following);
  
select * from infosys2 order by `Date`;

# tcs2

drop table if exists `tcs2`;

create table tcs2 as
select 
		date_value AS "Date",
		close_price AS "Close Price",
		case when first_value(short_term_greater) over w = nth_value(short_term_greater,2) over w then  'Hold'
				when NTH_VALUE(short_term_greater,2) over w = 'Y' then 'Buy'
				when NTH_VALUE(short_term_greater,2) over w = 'N' then 'Sell'
                else 'Hold'
                end
			
		 AS "Signal" 
	FROM
(
select
		`Date` as date_value,
		`Close Price` AS close_price,
		if(`20 Day MA`>`50 Day MA`,'Y','N') short_term_greater
	from
		tcs1 
) temp_table
window w as (order by date_value rows between 1 preceding and 0 following);
  
select * from tcs2 order by `Date`;

# tvs2

drop table if exists `tvs2`;

create table tvs2 as
select 
		date_value AS "Date",
		close_price AS "Close Price",
		case when first_value(short_term_greater) over w = nth_value(short_term_greater,2) over w then  'Hold'
				when NTH_VALUE(short_term_greater,2) over w = 'Y' then 'Buy'
				when NTH_VALUE(short_term_greater,2) over w = 'N' then 'Sell'
                else 'Hold'
                end
			
		 AS "Signal" 
	FROM
(
select
		`Date` as date_value,
		`Close Price` AS close_price,
		if(`20 Day MA`>`50 Day MA`,'Y','N') short_term_greater
	from
		tvs1 
) temp_table
window w as (order by date_value rows between 1 preceding and 0 following);
  
select * from tvs2 order by `Date`;
  
## 4. Create a User defined function, that takes the date as input and returns the signal for that particular day (Buy/Sell/Hold) for the Bajaj stock.

delimiter $$

create function get_signal_for_date( input_date date)

returns varchar(10)

deterministic

begin

declare signal_value varchar(10);

select `Signal` into signal_value 
from bajaj2
where `Date` = input_date;

return signal_value;

end $$

delimiter ;

# date format - yyyy-mm-dd  
# Test function for all three signals
select get_signal_for_date('2015-09-29') as day_signal;  # result - hold
select get_signal_for_date('2015-08-24') as day_signal; # result - sell
select get_signal_for_date('2015-05-18') as day_signal; # result - buy


## Remove format_date from all tables to have tables as original record

alter table `bajaj_auto`
drop column format_date;
alter table `eicher_motors`
drop column format_date;
alter table `hero_motocorp`
drop column format_date;
alter table `infosys`
drop column format_date;
alter table `tcs`
drop column format_date;
alter table `tvs_motors`
drop column format_date;

-- END OF ASSIGNMENT