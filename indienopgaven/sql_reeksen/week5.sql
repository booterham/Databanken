-- opgave 1
select distinct onnr as ondernemingsnr, concat(beginmon, '/', beginyear) as maand, totaal as opbrengts
from (select beginmon, beginyear, onnr, sum(verdiend) as totaal
      from (select to_char(periode_begin, 'MM')     as beginmon,
                   extract(year from periode_begin) as beginyear,
                   ondernemingsnr                   as onnr,
                   round(cast(extract(epoch from (periode_end - periode_begin)) / 3600 / 24 + 1 as numeric) *
                         dagtarief, 2)              as verdiend
            from registratieformulier
                     inner join wagen w on registratieformulier.nummerplaat = w.nummerplaat
                     inner join filiaal using (ondernemingsnr)
                     inner join constructeur c on w.merk = c.merk and w.model = c.model
                     inner join type t on c.type = t.naam) as first
      group by beginmon, beginyear, onnr) as second;

-- modelantwoord opgave 1

select distinct w.ondernemingsnr,
                    to_char(periode_begin, 'MM/YYYY')                                                as maand,
                    round(sum((extract('days' from (periode_end - periode_begin)) + 1) * dagtarief)::numeric, -1) as opbrengst
    from registratieformulier r
             inner join wagen w on r.nummerplaat = w.nummerplaat
             inner join constructeur c on w.merk = c.merk and w.model = c.model
             inner join type t on c.type = t.naam
    group by w.ondernemingsnr, to_char(periode_begin, 'MM/YYYY');

--opgave 2
select case
           when datum is null then to_char(generate_series, 'DD/MM/YYYY')
           else to_char(datum, 'DD/MM/YYYY') end                                 as datum,
       case when aantal_registraties is null then 0 else aantal_registraties end as aantal_registraties
from (select datum, count(begindatum) as aantal_registraties
      from (select distinct r1.periode_begin as datum, r2.periode_begin as begindatum, r2.periode_end as einddatum
            from registratieformulier r1
                     cross join registratieformulier r2
            where r1.periode_begin >= r2.periode_begin
              and r1.periode_begin <= r2.periode_end
              and extract(year from r1.periode_begin) = 2018
            order by r1.periode_begin) as first
      group by datum) as second
         right join (select *
                     from generate_series('2018-01-01 00:00'::timestamp,
                                          '2018-12-31 00:00', '1 day')) as idk on idk.generate_series = second.datum
order by idk.generate_series;

-- model

select distinct to_char(date.date, 'DD/MM/YYYY') as datum, count(nummerplaat) as aantal_registraties
    from generate_series('2018/01/01'::date, '2018/12/31'::date, '1 day') as date
             left join registratieformulier r on date.date >= r.periode_begin and date.date <= r.periode_end
    group by date.date;

-- opgave 3
select distinct werknemersnr, email, voornaam, achternaam
from (select werknemersnr, email, voornaam, achternaam, count(periode_begin) as periodes, count(beginhuur) as verhuurs
      from (select distinct cont.werknemersnr,
                            cont.email,
                            cont.voornaam,
                            cont.achternaam,
                            cont.periode_begin,
                            cont.periode_end,
                            beginhuur,
                            eindhuur
            from (select r.email                          as regiemail,
                         contractmetnaam.email            as werknemersmail,
                         r.periode_begin                  as beginhuur,
                         r.periode_end                    as eindhuur,
                         contractmetnaam.periode_begin    as begincontract,
                         contractmetnaam.periode_end      as eindcontract,
                         contractmetnaam.werknemersnummer as werknemersnr,
                         contractmetnaam.voornaam         as voornaam,
                         contractmetnaam.achternaam       as achternaam
                  from registratieformulier r
                           cross join (select periode_begin,
                                              periode_end,
                                              w.werknemersnr as werknemersnummer,
                                              p.voornaam,
                                              p.achternaam,
                                              w.email
                                       from contract c
                                                inner join werknemer w on c.werknemersnr = w.werknemersnr
                                                inner join persoon p on w.email = p.email) as contractmetnaam
                  where (r.periode_begin, r.periode_begin) overlaps
                        (contractmetnaam.periode_begin, contractmetnaam.periode_end)
                    and r.email = contractmetnaam.email) as periode_overlap_juiste_persoon
                     full join (select w2.werknemersnr, p2.email, p2.voornaam, p2.achternaam, periode_begin, periode_end
                                from contract
                                         inner join werknemer w2 on contract.werknemersnr = w2.werknemersnr
                                         inner join persoon p2 on w2.email = p2.email) cont
                               on cont.periode_begin = begincontract and cont.periode_end = eindcontract and
                                  periode_overlap_juiste_persoon.werknemersnr = cont.werknemersnr
            order by werknemersnr) as withnulls
      group by voornaam, email, werknemersnr, achternaam) as gegroepeerd
where periodes = verhuurs;

-- model

select werknemersnr, werknemer.email, voornaam, achternaam
    from werknemer
    inner join persoon on werknemer.email = persoon.email
    where werknemer.email not in
          (select p1.email
           from werknemer w1
                    inner join persoon p1 on w1.email = p1.email
                    inner join contract c1 on w1.werknemersnr = c1.werknemersnr
           where not exists(select *
                            from registratieformulier r
                            where p1.email = r.email
                              and r.periode_begin between c1.periode_begin and c1.periode_end));

-- opgave 4
select cast(ondernemingsnr as int),
       round(cast(sum(aantaldagenverhuurd) /
                  (select count(werknemersnr)
                   from contract c
                   where c.ondernemingsnr = ungrouped.ondernemingsnr) as numeric), 2
           ) as gemiddelde
from (select distinct nummerplaat,
                      periode_begin,
                      periode_end,
                      ondernemingsnr,
                      EXTRACT(epoch FROM periode_end - periode_begin) / 86400 + 1 as aantaldagenverhuurd
      from registratieformulier
               inner join wagen w using (nummerplaat)) as ungrouped
group by ondernemingsnr
order by gemiddelde desc;

-- model
select f1.ondernemingsnr,
           round(sum(extract('days' from r.periode_end - r.periode_begin) + 1)::numeric /
           (select count(distinct werknemersnr)
            from filiaal f2
                     inner join contract c on f1.ondernemingsnr = c.ondernemingsnr
            where f1.ondernemingsnr = f2.ondernemingsnr), 2) as gemiddelde
    from filiaal f1
             inner join wagen w on f1.ondernemingsnr = w.ondernemingsnr
             inner join registratieformulier r on w.nummerplaat = r.nummerplaat
    group by f1.ondernemingsnr
    order by gemiddelde desc;