select round(cast(sum(goedkoopste_prijs) as numeric) / cast(count(goedkoopste_prijs) as numeric) * 100, 2) as percentage
from (select case
                 when klantcode in (select code
                                    from klant
                                             inner join (select naam from affiliatie where prijsfactor = 1) as affiliaties_met_laagste_prijsfactor
                                                        on naam = affiliatienaam
                 ) then 1
                 else 0 end as goedkoopste_prijs
      from aankoop
               inner join klant k on aankoop.klantcode = k.code
               inner join affiliatie a on k.affiliatienaam = a.naam) as teller;