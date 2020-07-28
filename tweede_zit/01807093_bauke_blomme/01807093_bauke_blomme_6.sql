select categorie, round(sum(opbrengst_voor_product), 2) as winst from (select productnaam, soortnaam, categorie, minimumprijs * factor * aantal as opbrengst_voor_product from (select productnaam,
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
