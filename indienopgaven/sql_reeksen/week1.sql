select distinct concat('1-', substr(nummerplaat, 7), '-', substr(nummerplaat, 3, 3)) as nieuwe_nummerplaat from wagen;

select distinct plaatsnaam from locatie where plaatsnaam like '% %' or plaatsnaam like '%-%' order by plaatsnaam;

select naam as wagentype, case when naam like 'minibus' and round((dagtarief * 0.8) * 5, -1) < 250 then true when naam like 'cabriolet' and round((dagtarief * 0.8) * 5, -1) < 250 then true when (naam not like 'cabriolet' and naam not like 'minibus' and round(dagtarief * 5, -1) < 250) then true else false end as betaalbaar from type;

select voornaam, achternaam, email, case when substr(email, 1, length(voornaam) + 1 + length(replace(achternaam, ' ', ''))) like concat(lower(voornaam), '.', lower(replace(achternaam, ' ', ''))) and email like '%.%@%.%' then true else false end as correct from persoon;
