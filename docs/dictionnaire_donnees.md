# Dictionnaire de données (extrait)

## Faits `fact_ventes`
- `montant_net` = `qte * prix_unit * (1 - remise)`
- `montant_brut` = `qte * prix_unit`
- `montant_remise` = `montant_brut * remise`

## Faits `fact_livraisons`
- `delai_expedition_jours` = `dateenv - datecom`
- `ecart_obj_liv_jours` = `dateenv - dateobjliv`
