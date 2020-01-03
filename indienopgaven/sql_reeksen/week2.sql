-- nummer 1
select twee.voornaam, twee.achternaam, twee.email
from
    (select postcode from persoon group by postcode having count(postcode) = 1) as een
        inner join (select postcode, voornaam, achternaam, email from persoon) as
            twee using(postcode);


-- nummer 2
select distinct pers.voornaam, pers.achternaam, fil.ondernemingsnr
from
     persoon pers left join werknemer using(email)
         inner join
         filiaal fil on substr(fil.postcode, 1, 1) like substr(pers.postcode, 1, 1)
where werknemer.email is null
order by pers.achternaam, pers.voornaam;

-- nummer 3
select distinct pers.voornaam as voornaam, pers.achternaam as achternaam, fil1.ondernemingsnr as ondernemingsnr1, fil1.naam as filiaal1, fil2.ondernemingsnr as ondernemingsnr2, fil2.naam as filiaal2
from (contract contr1 inner join filiaal fil1 on contr1.ondernemingsnr = fil1.ondernemingsnr)
	inner join (((contract contr2
		inner join filiaal fil2 on contr2.ondernemingsnr = fil2.ondernemingsnr)
				inner join werknemer wn using(werknemersnr)) inner join persoon pers using(email)
				) using(werknemersnr)
where contr1.periode_begin < contr2.periode_begin
and contr1.periode_end < contr2.periode_begin
and fil1.ondernemingsnr != fil2.ondernemingsnr
order by pers.achternaam desc, pers.voornaam desc;

-- van jonathan
SELECT DISTINCT p.voornaam, p.achternaam, fa.ondernemingsnr, fa.naam, fb.ondernemingsnr, fb.naam FROM
persoon p
INNER JOIN werknemer w USING(email)
INNER JOIN contract ca USING(werknemersnr)
INNER JOIN filiaal fa ON ca.ondernemingsnr = fa.ondernemingsnr
INNER JOIN contract cb USING(werknemersnr)
INNER JOIN filiaal fb ON cb.ondernemingsnr = fb.ondernemingsnr
WHERE ca.periode_end < cb.periode_begin AND fa.ondernemingsnr != fb.ondernemingsnr
ORDER BY p.achternaam DESC, p.voornaam DESC;

-- combinatie
(select pers.voornaam as voornaam, pers.achternaam as achternaam, fil1.ondernemingsnr as ondernemingsnr1, fil1.naam as filiaal1, fil2.ondernemingsnr as ondernemingsnr2, fil2.naam as filiaal2
from (contract contr1 inner join filiaal fil1 on contr1.ondernemingsnr = fil1.ondernemingsnr)
	inner join (((contract contr2
		inner join filiaal fil2 on contr2.ondernemingsnr = fil2.ondernemingsnr)
				inner join werknemer wn using(werknemersnr)) inner join persoon pers using(email)
				) using(werknemersnr)
where contr1.periode_begin < contr2.periode_begin
and contr1.periode_end < contr2.periode_begin
and fil1.ondernemingsnr != fil2.ondernemingsnr
order by pers.achternaam desc, pers.voornaam desc)
except
(SELECT DISTINCT p.voornaam, p.achternaam, fa.ondernemingsnr, fa.naam, fb.ondernemingsnr, fb.naam FROM persoon p
INNER JOIN werknemer w USING(email)
INNER JOIN contract ca USING(werknemersnr)
INNER JOIN filiaal fa ON ca.ondernemingsnr = fa.ondernemingsnr
INNER JOIN contract cb USING(werknemersnr)
INNER JOIN filiaal fb ON cb.ondernemingsnr = fb.ondernemingsnr
WHERE ca.periode_end < cb.periode_begin AND fa.ondernemingsnr != fb.ondernemingsnr
ORDER BY p.achternaam DESC, p.voornaam DESC);