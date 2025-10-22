-- - F1 : Liste decroissante des produits avec les plus grosses remises avec le client concerne et l information sur le nom de l employe de la commande
CREATE OR REPLACE VIEW public.v_f1_remises_produits AS
SELECT
    dc.refprod,
    p.nomprod AS produit,
    c.societe AS client,
    (e.nom || ' ' || e.prenom) AS employe,
    dc.remise,
    dc.prixunit,
    dc.qte,
    (dc.prixunit * dc.qte * (1 - COALESCE(dc.remise,0::numeric)))::numeric(12,2) AS montant_net
FROM public._detailcommande dc
JOIN public._produit p    ON dc.refprod = p.refprod
JOIN public._commande co   ON dc.nocom = co.nocom
JOIN public._client c      ON co.codecli = c.codecli
LEFT JOIN public._employe e ON co.noemp = e.noemp
ORDER BY dc.remise DESC;

-- - F2 : Liste du chiffre d affaires par produit avec sous-totaux par categorie de produit
CREATE OR REPLACE VIEW public.v_f2_ca_par_produit AS
SELECT
    cat.codecateg,
    cat.nomcateg,
    p.refprod,
    p.nomprod,
    SUM(dc.qte * dc.prixunit * (1 - COALESCE(dc.remise,0::numeric)))::numeric(14,2) AS chiffre_affaires
FROM public._detailcommande dc
JOIN public._produit p    ON dc.refprod = p.refprod
LEFT JOIN public._categorie cat ON p.codecateg = cat.codecateg
GROUP BY cat.codecateg, cat.nomcateg, p.refprod, p.nomprod
ORDER BY cat.nomcateg NULLS LAST, chiffre_affaires DESC;

-- - F3 : Liste du chiffre d affaires par pays avec le total des frais de port
CREATE OR REPLACE VIEW public.v_f3_ca_par_pays AS
SELECT
    COALESCE(co.paysliv, '(NON RENSEIGNE)') AS pays,
    SUM(dc.qte * dc.prixunit * (1 - COALESCE(dc.remise,0::numeric)))::numeric(14,2) AS chiffre_affaires,
    SUM(COALESCE(co.port,0))::numeric(12,2) AS total_frais_port
FROM public._commande co
JOIN public._detailcommande dc ON co.nocom = dc.nocom
GROUP BY COALESCE(co.paysliv, '(NON RENSEIGNE)')
ORDER BY chiffre_affaires DESC;

-- - F4 : Liste du chiffre d affaires transporté par transporteur
CREATE OR REPLACE VIEW public.v_f4_ca_par_transporteur AS
SELECT
    COALESCE(t.nomtran, '(NON RENSEIGNE)') AS transporteur,
    SUM(dc.qte * dc.prixunit * (1 - COALESCE(dc.remise,0::numeric)))::numeric(14,2) AS chiffre_affaires
FROM public._commande co
JOIN public._detailcommande dc ON co.nocom = dc.nocom
LEFT JOIN public._transporteur t ON co.notran = t.notran
GROUP BY COALESCE(t.nomtran, '(NON RENSEIGNE)')
ORDER BY chiffre_affaires DESC;

-- - F5 : Liste des commandes par employe avec son nom et les remises moyennes qu il accorde par client
CREATE OR REPLACE VIEW public.v_f5_commandes_par_employe AS
SELECT
    e.noemp,
    (e.nom || ' ' || e.prenom) AS employe,
    c.societe AS client,
    COUNT(DISTINCT co.nocom) AS nb_commandes,
    ROUND(AVG(COALESCE(dc.remise,0::numeric)), 4) AS remise_moyenne
FROM public._employe e
JOIN public._commande co ON e.noemp = co.noemp
JOIN public._detailcommande dc ON co.nocom = dc.nocom
JOIN public._client c ON co.codecli = c.codecli
GROUP BY e.noemp, employe, c.societe
ORDER BY employe, remise_moyenne DESC;

-- - F6 : Liste des chiffres d affaires et quantites realises avec les produits, par fournisseur
CREATE OR REPLACE VIEW public.v_f6_ca_qte_par_fournisseur AS
SELECT
    f.nofourn,
    f.societe AS fournisseur,
    SUM(dc.qte)::bigint AS quantite_totale,
    SUM(dc.qte * dc.prixunit * (1 - COALESCE(dc.remise,0::numeric)))::numeric(14,2) AS chiffre_affaires
FROM public._detailcommande dc
JOIN public._produit p ON dc.refprod = p.refprod
LEFT JOIN public._fournisseur f ON p.nofourn = f.nofourn
GROUP BY f.nofourn, f.societe
ORDER BY chiffre_affaires DESC NULLS LAST;

-- - F7 : Cumul des frais de port par transporteur avec le nombre d expeditions
CREATE OR REPLACE VIEW public.v_f7_frais_par_transporteur AS
SELECT
    COALESCE(t.nomtran, '(NON RENSEIGNE)') AS transporteur,
    COUNT(co.nocom) AS nb_expeditions,
    SUM(COALESCE(co.port,0))::numeric(12,2) AS total_frais_port
FROM public._commande co
LEFT JOIN public._transporteur t ON co.notran = t.notran
GROUP BY COALESCE(t.nomtran, '(NON RENSEIGNE)')
ORDER BY total_frais_port DESC;

-- - F8 : Rapport additionnel - Exemple : chiffre d affaires mensuel global (annee, mois)
CREATE OR REPLACE VIEW public.v_f8_ca_mensuel AS
SELECT
    DATE_PART('year', co.datecom::date)  ::int AS annee,
    DATE_PART('month', co.datecom::date) ::int AS mois,
    SUM(dc.qte * dc.prixunit * (1 - COALESCE(dc.remise,0::numeric)))::numeric(14,2) AS chiffre_affaires
FROM public._commande co
JOIN public._detailcommande dc ON co.nocom = dc.nocom
WHERE co.datecom IS NOT NULL AND trim(co.datecom) <> ''
GROUP BY annee, mois
ORDER BY annee DESC, mois DESC;

-- - L1 : Liste des plus grands ecarts entre la date d objectif de livraison et la date d envoi de la commande
CREATE OR REPLACE VIEW public.v_l1_ecarts_livraison AS
SELECT
    co.nocom,
    co.dateobjliv,
    co.dateenv,
    ( (co.dateenv::date) - (co.dateobjliv::date) ) AS ecart_jours
FROM public._commande co
WHERE co.dateenv IS NOT NULL AND co.dateobjliv IS NOT NULL AND trim(co.dateenv) <> '' AND trim(co.dateobjliv) <> ''
ORDER BY ecart_jours DESC;

-- - L2 : Liste des produits dont le niveau de reappro est declenche
CREATE OR REPLACE VIEW public.v_l2_reappro AS
SELECT
    p.refprod,
    p.nomprod,
    p.unitstock,
    p.unitescom,
    p.niveaureap,
    (COALESCE(p.unitstock,0) - COALESCE(p.unitescom,0)) AS stock_restant
FROM public._produit p
WHERE (COALESCE(p.unitstock,0) - COALESCE(p.unitescom,0)) < COALESCE(p.niveaureap,0)
ORDER BY stock_restant ASC;

-- - L3 : Quantites de produit livrees par region et par ville de livraison
CREATE OR REPLACE VIEW public.v_l3_qte_par_ville AS
SELECT
    co.regionliv,
    co.villeliv,
    SUM(dc.qte)::bigint AS quantite_totale
FROM public._commande co
JOIN public._detailcommande dc ON co.nocom = dc.nocom
GROUP BY co.regionliv, co.villeliv
ORDER BY co.regionliv NULLS LAST, co.villeliv NULLS LAST;

-- - L4 : Liste des commandes a livrer ayant un fournisseur dans la meme region
CREATE OR REPLACE VIEW public.v_l4_commandes_meme_region AS
SELECT DISTINCT
    co.nocom,
    co.regionliv,
    f.region AS region_fournisseur,
    f.societe AS fournisseur
FROM public._commande co
JOIN public._detailcommande dc ON co.nocom = dc.nocom
JOIN public._produit p ON dc.refprod = p.refprod
LEFT JOIN public._fournisseur f ON p.nofourn = f.nofourn
WHERE co.regionliv IS NOT NULL AND f.region IS NOT NULL AND trim(co.regionliv) <> '' AND trim(f.region) <> ''
  AND co.regionliv = f.region
ORDER BY co.nocom;

-- - L5 : Rapport additionnel - Exemple : delai moyen d expedition (dateenv - datecom) par transporteur
CREATE OR REPLACE VIEW public.v_l5_delai_par_transporteur AS
SELECT
    COALESCE(t.nomtran, '(NON RENSEIGNE)') AS transporteur,
    ROUND(AVG( (co.dateenv::date) - (co.datecom::date) )::numeric, 2) AS delai_moyen_jours
FROM public._commande co
LEFT JOIN public._transporteur t ON co.notran = t.notran
WHERE co.dateenv IS NOT NULL AND co.datecom IS NOT NULL AND trim(co.dateenv) <> '' AND trim(co.datecom) <> ''
GROUP BY COALESCE(t.nomtran, '(NON RENSEIGNE)')
ORDER BY delai_moyen_jours;
