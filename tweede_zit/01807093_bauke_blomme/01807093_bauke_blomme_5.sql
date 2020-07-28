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