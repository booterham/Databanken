select kijkitem.startjaar, kijkitem.eindjaar, kijkitem.item_id, crew_leden.persoon_id
from kijkitem
         right join crew_leden using (item_id) where