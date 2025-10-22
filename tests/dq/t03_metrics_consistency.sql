-- Coherence montant_net = qte * prix * (1-remise)
SELECT 'coherence_montants' AS test,
       COUNT(*) AS nb_incoherences
FROM dw.fact_ventes
WHERE montant_net <> ROUND(ligne_qte * ligne_prix_unit * (1-COALESCE(ligne_remise,0))::numeric, 2);
