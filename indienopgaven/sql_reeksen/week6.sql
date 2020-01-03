-- opgave 1
select email, case when sum(bij_zelfde_bedrijf) = 0 then false else true end as validatie
from (select persoon.email,
             case when c.ondernemingsnr = w2.ondernemingsnr then '1'::int else '0'::int end as bij_zelfde_bedrijf
      from persoon
               inner join werknemer w
                          on persoon.email = w.email
               inner join registratieformulier r on persoon.email = r.email

               inner join contract c on w.werknemersnr = c.werknemersnr
               inner join wagen w2 on r.nummerplaat = w2.nummerplaat) as alias
group by email;

--opgave 2
select distinct postcode,
                plaatsnaam,
                case
                    when (woonplaats is false and bedrijfplaats is true) then 'bedrijfslocatie'
                    when (woonplaats is true and bedrijfplaats is false) then 'woonplaats'
                    when (bedrijfplaats is true and woonplaats is true) then 'beiden'
                    else 'geen van beiden' end as "locatie-type"
from (select locatie.postcode,
             locatie.plaatsnaam,
             case when (p.plaatsnaam is null and p.postcode is null) then false else true end as woonplaats,
             case when (f.plaatsnaam is null and f.postcode is null) then false else true end as bedrijfplaats
      from locatie
               left join filiaal f on locatie.postcode = f.postcode and locatie.plaatsnaam = f.plaatsnaam
               left join persoon p on locatie.postcode = p.postcode and locatie.plaatsnaam = p.plaatsnaam) as ok
order by "locatie-type";

--opgave 3
select ok.ondernemingsnr,
       case
           when ok.percent is null then 0::numeric
           else ok.percent end as wagenverhuurpercetage
from (select f.ondernemingsnr,
             ((subq1.deel::double precision / subq2.totaal::double precision) * 100)::numeric as percent
      from (select distinct c.ondernemingsnr, count(distinct w.werknemersnr) as deel
            from werknemer w
                     inner join registratieformulier r on w.email = r.email
                     inner join wagen wo on r.nummerplaat = wo.nummerplaat
                     inner join contract c on w.werknemersnr = c.werknemersnr
            where c.ondernemingsnr = wo.ondernemingsnr
              and ((c.periode_begin, c.periode_end) overlaps (r.periode_begin, r.periode_end))
            group by (c.ondernemingsnr)) as subq1
               inner join (select distinct f.ondernemingsnr, count(distinct w.werknemersnr) as totaal
                           from werknemer w
                                    inner join contract c on w.werknemersnr = c.werknemersnr
                                    inner join filiaal f on c.ondernemingsnr = f.ondernemingsnr
                           group by (f.ondernemingsnr)) as subq2 on subq1.ondernemingsnr = subq2.ondernemingsnr
               right join filiaal f on f.ondernemingsnr = subq1.ondernemingsnr) as ok;

-- opgave 4
select aantal.postcode, aantal.merk, aantal.model
from (select subq1.postcode, max(subq1.count)
                     from (select l.postcode, w.merk, w.model, count(*)
                           from locatie l
                                    inner join persoon p2 on l.postcode = p2.postcode and l.plaatsnaam = p2.plaatsnaam
                                    inner join registratieformulier r2 on p2.email = r2.email
                                    inner join wagen w on r2.nummerplaat = w.nummerplaat
                           group by (l.postcode, w.merk, w.model)) as subq1 group by (subq1.postcode)) as maxi inner join (select l.postcode, w.merk, w.model, count(*)
      from locatie l
               inner join persoon p on l.postcode = p.postcode and l.plaatsnaam = p.plaatsnaam
               inner join registratieformulier r on p.email = r.email
               inner join wagen w on r.nummerplaat = w.nummerplaat
      group by (l.postcode, w.merk, w.model)) as aantal on aantal.postcode = maxi.postcode;