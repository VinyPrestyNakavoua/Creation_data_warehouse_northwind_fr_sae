SELECT 'coherence_montants' AS test,
       COUNT(*) AS nb_incoherences
FROM dwh.fact_ventes
WHERE montant_net <> ROUND(ligne_qte * ligne_prix_unit * (1-COALESCE(ligne_remise,0))::numeric, 2);
