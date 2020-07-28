-- Hostnaam/IP-adres: ddcmstud.ugent.be
-- Poort: 8088
-- Databank: resto
-- Gebruikersnaam: sql_exerciser
-- Wachtwoord: 7UCVuJeLCGcQbk2M




-- 1
-- Geef terug hoeveel procent van de aankopen gedaan zijn door klanten die de
-- minimumprijs betalen voor hun aangekochte producten. Rond het resultaat af
-- tot op twee cijfers na de komma. In het uiteindelijke resultaat verwachten we
-- enkel het attribuut ‘percentage’.

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

-- 2
-- Om een analyse van de verplaatsingen van klanten te maken zijn we geïnteres-
-- seerd in het aantal keer een verplaatsing voorkomt. Een verplaatsing wordt
-- gedefinieerd als een koppel van resto’s waar een klant achtereenvolgens een
-- aankoop heeft gedaan zonder in de tussentijd een andere aankoop te doen. Dit
-- betekent dat als Jan Janssens eerst op tijdstip 1 een aankoop heeft gedaan bij
-- resto A, op tijdstip 2 bij resto B en op tijdstip 3 opnieuw bij resto A, we A-B
-- en B-A als toegestane koppels beschouwen, maar A-A niet. In het uiteindelijke
-- resultaat verwachten we de kolommen ‘resto1’, ‘resto2’ en ‘aantal’ waarbij
-- ‘resto1’ en ‘resto2’ de namen van de bezochte resto’s voorstellen en ‘aantal’
-- wijst op het aantal keer een koppel voorkomt. Een aankoop bij resto1 moet
-- ook steeds voor een aankoop bij resto2 gebeurd zijn en indien een klant meer
-- dan 1 keer dezelfde verplaatsing heeft gemaakt, moeten deze allemaal meetel-
-- len in het eindresultaat. Tot slot moeten ook ‘verplaatsingen’ waar resto1 en
-- resto2 gelijk zijn worden beschouwd. Sorteer het uiteindelijk resultaat volgens
-- afnemend aantal.

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

-- 3
-- Geef alle resto’s terug die zowel het meest gevarieerde aanbod aan producten
-- alsook de grootste omzet hebben. De variëteit van een resto wordt berekend
-- door het aantal unieke producten (dus niet productsoorten!) die ooit zijn aan-
-- geboden door een resto te tellen. De omzet van een resto wordt dan weer
-- berekend door de totaalomzet van alle aankopen bij de resto op te tellen. De
-- totaalomzet van een aankoop is de minimumprijs van het aangekochte product
-- vermenigvuldigd met de prijsfactor en met het aantal. In het uiteindelijke re-
-- sultaat verwachten we enkel de kolom ‘restonaam’.

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

-- 4
-- Geef alle resto’s terug die gelegen zijn in Gent (met postcode 9000) en waar de
-- beschrijving effectief een waarde (dus niet NULL) bevat. Je mag ervan uitgaan
-- dat het adres van een resto steeds eindigt op ‘xxxx Plaatsnaam’ waarin ‘xxxx’
-- de postcode voorstelt en de plaatsnaam dus met hoofdletter wordt genoteerd.
-- In het uiteindelijke resultaat verwachten we de kolommen ‘naam’, ‘adres’ en
-- ‘beschrijving’.

select * from resto where adres ~ '  9000 Gent$' and beschrijving notnull;

-- 5
-- Geef alle productsoorten die gedurende een welbepaalde week (lopende van
-- maandag tot en met zondag) maar eenmalig zijn verkocht bij een resto. Dit be-
-- tekent dus dat, wanneer een productsoort gedurende de week die loopt van 6
-- juli 2020 tot 12 juli 2020 1 keer is verkocht bij resto A en 2 keer bij resto B, we
-- deze soort willen teruggeven, maar enkel gekoppeld aan resto A. In het uitein-
-- delijke resultaat verwachten we 5 kolommen met de namen ‘restonaam’, ‘pro-
-- ductnaam’, ‘soortnaam’, ‘tijdstip’ en ‘klantcode’ waar ‘tijdstip’ verwijst naar
-- het tijdstip van aankoop en ‘klantcode’ naar de code van de klant die de soort
-- als enige heeft aangekocht in een bepaalde week.

select restonaam, productnaam, soortnaam, tijdstip, klantcode
from (select restonaam,
             productnaam,
             soortnaam,
             max(tijdstip)               as tijdstip, -- we kunnen hier max gebruiken aangezien dit de waarde laat staan als er maar 1 is en we bij meerdere waarden er niet om geven wat ermee gebeurt
             extract(week from tijdstip) as week,
             max(klantcode)              as klantcode,
             count(*)                    as aantal
      from aankoop
      group by restonaam, productnaam, soortnaam, week) as alle_info
where aantal = 1;

-- 6
-- Om het aanbod van de resto’s te optimaliseren, wil de UGent nagaan op welke
-- productcategorieën het meeste winst werd gemaakt tot nog toe. De winst die
-- geboekt wordt op een verkocht product uit een specifieke productcategorie
-- wordt hierbij gedefinieerd als het totale bedrag dat klanten hebben uitgegeven
-- aan producten van die categorie (rekening houdend met aantal en prijsfactor)
-- min het totale bedrag dat nodig was voor de UGent om de verkochte producten
-- zelf te kunnen aanbieden.
-- Ga uit van onderstaande bedragen die de UGent zelf dient te betalen om een
-- afgewerkt product in de resto te kunnen verkopen:

-- Drank 0.95 × minimumprijs
-- Dessert & Ontbijt 0.93 × minimumprijs
-- Belegd broodje, Soep & Maaltijdsoep 0.87 × minimumprijs
-- Hoofdgerecht Vlees, Hoofdgerecht Vis, Vegetarisch Hoofdgerecht & Veganistisch Hoofdgerecht 0.85 × minimumprijs

-- Bereken voor iedere productcategorie de totale winst die tot op heden werd
-- geboekt. In het uiteindelijk resultaat worden de volgende twee kolommen ver-
-- wacht: ‘categorie’ en ‘winst’. De getallen in de kolom ‘winst’ worden afgerond
-- tot op 2 cijfers na de komma in de eindberekening. Sorteer de resultaten vol-
-- gens dalende winst.

select categorie, round(sum(opbrengst_voor_product), 2) as winst from (select soortnaam, categorie, minimumprijs * factor * aantal as opbrengst_voor_product from (select productnaam,
       soortnaam,
       categorie,
       sum(aantal)       as aantal,
       max(minimumprijs) as minimumprijs,
       max(factor)       as factor
from (select aankoop.productnaam,
             aankoop.soortnaam,
             aantal,
             categorie,
             minimumprijs,
             case
                 when categorie ~ 'Drank' then 0.95
                 when categorie like 'Dessert' or categorie like 'Ontbijt' then 0.93
                 when categorie like 'Belegd broodje' or categorie like 'Soep' or categorie like 'Maaltijdsoep'
                     then 0.87
                 when categorie like 'Hoofdgerecht Vlees' or categorie like 'Hoofdgerecht Vis' or
                      categorie like 'Vegetarisch Hoofdgerecht' or categorie like 'Veganistisch Hoofdgerecht'
                     then 0.85 end as factor
      from aankoop
               inner join product on product.naam = productnaam
               inner join productsoort p on product.naam = p.productnaam) as full_info
group by productnaam, soortnaam, categorie) as okok) as fuckoff group by categorie order by winst desc;

-- 7
-- Geef voor iedere resto het gemiddeld aantal seconden terug tussen twee op-
-- eenvolgende aankopen van dezelfde klant in deze resto (ongeacht aankopen
-- van deze klant bij een andere resto in de tussentijd). Klanten die in eenzelfde
-- resto in totaal minder dan twee aankopen deden, dienen niet te worden mee-
-- genomen in het eindresultaat. In het uiteindelijke resultaat verwachten we
-- twee kolommen: ‘restonaam’ en ‘gemiddelde_tijd’ (datatype numeric). Rond
-- de waarden in kolom ‘gemiddelde_tijd’ af tot op twee cijfers na de komma.

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

