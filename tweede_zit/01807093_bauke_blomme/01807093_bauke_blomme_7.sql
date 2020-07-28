select restonaam, avg(tijd_tussen_aankopen) as gemiddelde
from (select restonaam,
             t1,
             extract(seconds from min(t2) - t1) as tijd_tussen_aankopen
      from (select a1.restonaam, a1.tijdstip as t1, a2.tijdstip as t2, a1.klantcode
            from aankoop a1
                     inner join aankoop a2 using (klantcode, restonaam)
            where a1.tijdstip < a2.tijdstip) as first_subquery
      group by restonaam, t1, klantcode
      order by restonaam, klantcode, t1) as second_subquery group by restonaam;

-- er wordt geen rekening gehouden met mensen die maar 1 keer een aankoop bij een resto doen aangezien
-- we een inner join gebruiken