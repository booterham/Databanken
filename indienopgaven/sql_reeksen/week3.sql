-- opgave 1
select nummerplaat
from (select r.nummerplaat, r.email, count(r.email)
    from registratieformulier r group by r.nummerplaat, r.email) as dubbeleweg
group by nummerplaat having count(nummerplaat) = 1;

-- opgave 2

select p.email, p.voornaam, p.achternaam from (select distinct firstdate, email from (select min(beegin) as firstdate from
        (select beegin from (select max(cast(r.periode_end as date) - cast(r.periode_begin as date) + 1) as maxval
from registratieformulier r) as maxdagen
inner join
(select cast(r.periode_begin as date) as beegin,
        cast(r.periode_end as date) as einde,
       (cast(r.periode_end as date) - cast(r.periode_begin as date) + 1) as dagen,
        r.email
from registratieformulier r order by dagen desc, beegin asc) as andere on maxdagen.maxval = andere.dagen) as sub_for_minbegin) as sub

            inner join (select beegin, einde, dagen, email from (select max(cast(r.periode_end as date) - cast(r.periode_begin as date) + 1) as maxval
from registratieformulier r) as maxdagen
inner join
(select cast(r.periode_begin as date) as beegin,
        cast(r.periode_end as date) as einde,
       (cast(r.periode_end as date) - cast(r.periode_begin as date) + 1) as dagen,
        r.email
from registratieformulier r order by dagen desc, beegin asc) as andere on maxdagen.maxval = andere.dagen) as sub1 on sub.firstdate = sub1.beegin) as fullsub

inner join persoon p using(email);

-- opgave 3

SELECT r1.* FROM Registratieformulier r1 INNER JOIN Persoon p USING(email) INNER JOIN Wagen w USING(nummerplaat) INNER JOIN Constructeur c1 USING(model) INNER JOIN type t1 ON(c1.type = t1.naam)
WHERE 250/4 >= (SELECT
					CASE WHEN (c2.merk = 'Volkswagen' AND c2.model = 'Polo') OR (c2.merk = 'Renault' AND c2.model = 'Megane') THEN t2.dagtarief*0.9
					ELSE t2.dagtarief*1
					END AS dagtarief
				FROM Constructeur c2 INNER JOIN Type t2 ON(c2.type = t2.naam)
				WHERE c2.merk = c1.merk AND c2.model = c1.model
			   )
AND p.email NOT IN(
					SELECT email FROM Werknemer
				  )
ORDER BY r1.periode_begin;

-- opgave 4

SELECT DISTINCT ondernemingsnr, email, voornaam, achternaam, periode_begin
FROM Filiaal f1
INNER JOIN Wagen w1 USING(ondernemingsnr)
INNER JOIN Registratieformulier r1 USING(nummerplaat)
INNER JOIN Persoon p1 USING(email)
WHERE periode_begin <= ALL(
    SELECT periode_begin
    FROM Filiaal f2
    INNER JOIN Wagen w2 USING(ondernemingsnr)
    INNER JOIN Registratieformulier r2 USING(nummerplaat)
    WHERE f1.ondernemingsnr = f2.ondernemingsnr
)

