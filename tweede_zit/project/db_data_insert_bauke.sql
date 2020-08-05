INSERT INTO artikel
SELECT DISTINCT articletitle, year::int, journal
FROM artikel_super;

INSERT INTO auteur
SELECT DISTINCT CASE WHEN firstname IS NULL THEN 'onbekend' ELSE firstname END AS firstname,
                CASE WHEN lastname IS NULL THEN 'onbekend' ELSE lastname END   AS lastname
FROM artikel_super
WHERE NOT (firstname IS NULL AND lastname IS NULL);
-- eventueel checken op vorm van achternaam

INSERT INTO figuur
SELECT DISTINCT specialcontentnr::int, caption, articletitle
FROM inhoud_super
WHERE specialcontentnr IS NOT NULL
  AND specialcontenttype = 'figure';

INSERT INTO tabel
SELECT DISTINCT specialcontentnr::int, caption, articletitle
FROM inhoud_super
WHERE specialcontentnr IS NOT NULL
  AND specialcontenttype = 'table';

SELECT citing_articletitle, citing_year, cited_articletitle, cited_year
FROM referenties_super
WHERE citing_year::int >= cited_year::int;

