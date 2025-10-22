-- Index additionnels (exemples)
CREATE INDEX IF NOT EXISTS ix_fact_ventes_date ON dw.fact_ventes(datecom_key);
CREATE INDEX IF NOT EXISTS ix_fact_livraisons_dateenv ON dw.fact_livraisons(dateenv_key);
VACUUM ANALYZE dw.fact_ventes;
VACUUM ANALYZE dw.fact_livraisons;
