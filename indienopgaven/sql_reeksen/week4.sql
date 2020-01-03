-- opgave 1
select nr as ondernemingsnr, naam
from (select nummerplaat, wagen.ondernemingsnr as nr, count(nummerplaat) as yeet
      from registratieformulier
               left join
           wagen using (nummerplaat)
               inner join filiaal f on wagen.ondernemingsnr = f.ondernemingsnr
      where merk like 'Opel'
        and model like 'Astra'
      group by nummerplaat, wagen.ondernemingsnr) as counts
         inner join filiaal on counts.nr = filiaal.ondernemingsnr
where yeet > 10;

-- opgave 2
select email,
       voornaam,
       achternaam,
       case
           when hoeveel = 0 then 'Potentieel toekomstige werknemer'
           when hoeveel = 1 then 'Trouwe werknemer'
           else 'Bedrijfshopper' end as werknemersstatus
from (select r.email, voornaam, achternaam, count(r.email) as hoeveel
      from registratieformulier r
               left join persoon on persoon.email = r.email
      group by r.email, voornaam, achternaam) as skeet;

-- opgave 3
select distinct werknemersnr, email, voornaam, achternaam
from (select count(werknemersnr) as aantal, w.werknemersnr, p.email, p.voornaam, p.achternaam, wagen.model, wagen.merk
      from registratieformulier
               left join wagen using (nummerplaat)
               inner join persoon p on registratieformulier.email = p.email
               inner join werknemer w on p.email = w.email
      group by w.werknemersnr, p.email, p.voornaam, p.achternaam, wagen.model, wagen.merk) as groot
where aantal = (select max(aantal)
                from (select count(werknemersnr) as aantal,
                             w.werknemersnr,
                             p.email,
                             p.voornaam,
                             p.achternaam,
                             wagen.model,
                             wagen.merk
                      from registratieformulier
                               left join wagen using (nummerplaat)
                               inner join persoon p on registratieformulier.email = p.email
                               inner join werknemer w on p.email = w.email
                      group by w.werknemersnr, p.email, p.voornaam, p.achternaam, wagen.model, wagen.merk) as klein);

-- opgave 4
(select avg(tel) as gemiddelde
 from (select nummerplaat, count(nummerplaat) as tel from registratieformulier group by nummerplaat) as gegroepeerd)
as yeet;


select distinct nummerplaat from (select nummerplaat,
        abs(count(nummerplaat) -
            (select avg(tel) as gemiddelde
             from (select nummerplaat, count(nummerplaat) as tel
                   from registratieformulier
                   group by nummerplaat) as gegroepeerd)) as gemiddelde
 from registratieformulier
 group by nummerplaat) as yeet
 where yeet.gemiddelde = 0.3151862464183381;