-- aanmaak van tabellen --

CREATE TABLE artikel
(
    artikel_titel varchar NOT NULL,
    jaar          int CHECK ((jaar IS NULL) OR (jaar >= 1900)),
    tijdschrift   varchar,

    CONSTRAINT artikel_pkey PRIMARY KEY (artikel_titel)
);

CREATE TABLE auteur
(
    voornaam   varchar,
    achternaam varchar,

    CONSTRAINT auteur_pkey PRIMARY KEY (voornaam, achternaam)
);

CREATE TABLE auteur_affiliatie
(
    voornaam    varchar,
    achternaam  varchar,
    instituut   varchar,
    organisatie varchar,

    CONSTRAINT affiliaties_auteur_pkey PRIMARY KEY (voornaam, achternaam, instituut, organisatie),
    CONSTRAINT affiliaties_auteur_fkey FOREIGN KEY (voornaam, achternaam) REFERENCES auteur
);

CREATE TABLE sectie
(
    sectie_titel     varchar NOT NULL,
    sectie_nummer    int     NOT NULL,
    artikel_titel    varchar NOT NULL,
    tekstuele_inhoud varchar,

    CONSTRAINT sectie_pkey PRIMARY KEY (artikel_titel, sectie_nummer),
    CONSTRAINT sectie_fkey FOREIGN KEY (artikel_titel) REFERENCES artikel,
    CONSTRAINT uc_sectie UNIQUE (sectie_titel)
);

CREATE TABLE tabel
(
    tabel_nummer     int     NOT NULL,
    tabel_bijschrift varchar,
    artikel_titel    varchar NOT NULL,

    CONSTRAINT tabel_pkey PRIMARY KEY (tabel_nummer, artikel_titel),
    CONSTRAINT tabel_fkey FOREIGN KEY (artikel_titel) REFERENCES artikel
);

CREATE TABLE figuur
(
    figuur_nummer     int     NOT NULL,
    figuur_bijschrift varchar,
    artikel_titel     varchar NOT NULL,

    CONSTRAINT figuur_pkey PRIMARY KEY (figuur_nummer, artikel_titel),
    CONSTRAINT figuur_fkey FOREIGN KEY (artikel_titel) REFERENCES artikel
);

CREATE TABLE referentie
(
    refererend_artikel  varchar,
    gerefereerd_artikel varchar,

    CONSTRAINT referentie_pkey PRIMARY KEY (refererend_artikel, gerefereerd_artikel)
);

CREATE TABLE auteur_artikel
(
    voornaam      varchar,
    achternaam    varchar,
    artikel_titel varchar,

    CONSTRAINT auteur_artikel_pkey PRIMARY KEY (voornaam, achternaam, artikel_titel),
    CONSTRAINT auteur_artikel_fkey1 FOREIGN KEY (voornaam, achternaam) REFERENCES auteur,
    CONSTRAINT auteur_artikel_fkey2 FOREIGN KEY (artikel_titel) REFERENCES artikel
);

-- triggers --

-- controleert of een refererend artikel jonger is dan het gerefereerde artikel
CREATE OR REPLACE FUNCTION check_jaar_voor_referenties()
    RETURNS trigger AS
$BODY$
DECLARE
    refererend_artikel_jaar  int;
    gerefereerd_artikel_jaar int;
BEGIN
    -- zoek het jaar op van beide artikels
    SELECT a.jaar INTO refererend_artikel_jaar FROM artikel a WHERE NEW.refererend_artikel = a.artikel_titel;
    SELECT a.jaar INTO gerefereerd_artikel_jaar FROM artikel a WHERE NEW.gerefereerd_artikel = a.artikel_titel;

    -- werp een uitzondering op indien het refererende artikel ouder is dan het gerefereerd artikel
    IF (refererend_artikel_jaar IS NOT NULL) AND
       (gerefereerd_artikel_jaar IS NOT NULL) AND
       (refererend_artikel_jaar < gerefereerd_artikel_jaar) THEN
        RAISE EXCEPTION 'Het artikel % uit % refereert naar % uit %, wat niet kan', NEW.refererend_artikel, refererend_artikel_jaar, NEW.gerefereerd_artikel, gerefereerd_artikel_jaar;
    END IF;

    -- alles is in orde als er geen uitzondering opgeworpen is, dus NEW mag teruggegeven worden
    RETURN NEW;
END
$BODY$
    LANGUAGE plpgsql;

CREATE TRIGGER check_referenties
    BEFORE INSERT
    ON referentie
    FOR EACH ROW
EXECUTE PROCEDURE check_jaar_voor_referenties();