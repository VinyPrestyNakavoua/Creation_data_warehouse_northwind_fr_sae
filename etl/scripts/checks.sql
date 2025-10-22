-- Contrôles de base post-chargement (exemples)
SELECT 'dim_date manquante' AS test, COUNT(*) FROM dw.dim_date WHERE full_date IS NULL;
SELECT 'fact_ventes négatifs' AS test, COUNT(*) FROM dw.fact_ventes WHERE montant_net < 0;
