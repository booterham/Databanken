with all_products as (select naam from product)
with combined_purchases as (select * from aankoop)
select *
from aankoop;


select a1.klantcode,
       a1.restonaam,
       a1.productnaam,
       a1.tijdstip,
       a2.productnaam,
       a2.tijdstip,
       extract(seconds from a1.tijdstip - a2.tijdstip) +
       extract(minutes from a1.tijdstip - a2.tijdstip) * 60 as intervall
from aankoop a1
         inner join aankoop a2 on a1.restonaam = a2.restonaam and a1.klantcode = a2.klantcode
where (a1.tijdstip - cast('151 seconds' as interval), a1.tijdstip + cast('151 seconds' as interval)) overlaps
      (a2.tijdstip - cast('150 seconds' as interval), a2.tijdstip + cast('150 seconds' as interval))
  and a1.productnaam != a2.productnaam
order by intervall;