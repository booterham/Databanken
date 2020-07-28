with all_restos as (select naam as resto, count(distinct productnaam) as aanbod, sum(totale_prijs) as opbrengst
                    from (select distinct resto.naam,
                                          aanbod.productnaam,
                                          aankoop.tijdstip,
                                          aankoop.klantcode,
                                          affiliatienaam,
                                          minimumprijs,
                                          a.prijsfactor,
                                          minimumprijs * a.prijsfactor as totale_prijs
                          from resto
                                   inner join aanbod on aanbod.restonaam = resto.naam
                                   inner join aankoop
                                              on aanbod.restonaam = aankoop.restonaam and
                                                 aanbod.begintijdstip = aankoop.begintijdstip and
                                                 aanbod.productnaam = aankoop.productnaam and
                                                 aanbod.soortnaam = aankoop.soortnaam
                                   inner join klant k on aankoop.klantcode = k.code
                                   inner join affiliatie a on k.affiliatienaam = a.naam
                                   inner join productsoort p
                                              on aanbod.productnaam = p.productnaam and aanbod.soortnaam = p.soortnaam) as alles
                    group by naam)
select resto
from all_restos
where aanbod = (select max(aanbod) from all_restos)
  and opbrengst = (select max(opbrengst) from all_restos);