select resto1, resto2, count(*) as aantal
from (with okok as (with peepee as (select klantcode, resto1, resto2, tijdstip1, min(tijdstip2) as mintijdstip2
                                    from (select a1.klantcode,
                                                 a1.restonaam as resto1,
                                                 a2.restonaam as resto2,
                                                 a1.tijdstip  as tijdstip1,
                                                 a2.tijdstip  as tijdstip2
                                          from aankoop a1
                                                   inner join aankoop a2 using (klantcode)
                                          where a1.tijdstip < a2.tijdstip) as alle_combinaties
                                    group by resto1, klantcode, resto2, tijdstip1
                                    order by klantcode, tijdstip1)
                    select klantcode, resto1, tijdstip1, min(mintijdstip2) as tijdstip2
                    from peepee
                    group by klantcode, resto1, tijdstip1)
      select okok.klantcode, resto1, pp.restonaam as resto2, tijdstip1, tijdstip2
      from okok
               inner join aankoop pp on pp.klantcode = okok.klantcode and okok.tijdstip2 = pp.tijdstip) as lelijke_query
group by resto1, resto2
order by count(*) desc;

