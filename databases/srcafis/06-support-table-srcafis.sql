-- create table containing only ids and minutiae
DROP TABLE IF EXISTS srcafis_m;
SELECT id, mdt INTO srcafis_m FROM srcafis;
ALTER TABLE srcafis_m ADD PRIMARY KEY (id);

-- check table structure
\d srcafis_m

/*
    Table "public.srcafis_m"
 Column |  Type   | Modifiers 
--------+---------+-----------
 id     | integer | not null
 mdt    | bytea   | 
Indexes:
    "srcafis_m_pkey" PRIMARY KEY, btree (id)
*/

-- compare size in disk for the tables
\d+

/*
                          List of relations
 Schema |     Name     |   Type   | Owner |    Size    | Description 
--------+--------------+----------+-------+------------+-------------
 public | srcafis         | table    | afis  | 492 MB     | 
 public | srcafis_m       | table    | afis  | 2072 kB    | 
*/

\timing on

-- =========================================================

-- Verification (1:1)

SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM srcafis_m a, srcafis_m b
WHERE a.id = (SELECT id FROM srcafis WHERE fp = 'ds2_u05_f_fo_ri_01')
  AND b.id = (SELECT id FROM srcafis WHERE fp = 'ds2_u05_f_fo_ri_03');

-- faster!
SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM srcafis_m a, srcafis_m b
WHERE a.id = 2041
  AND b.id = 2043;

/*
 match 
-------
 t
(1 row)
*/

SELECT bz_match(a.mdt, b.mdt) AS score
FROM srcafis_m a, srcafis_m b
WHERE a.id = 2041
  AND b.id = 2043;

/*
 score 
-------
    56
(1 row)
*/

-- =========================================================

-- Identification (1:N)

-- returns only first match
SELECT b.id AS first_matching_sample
FROM srcafis_m a, srcafis_m b
WHERE a.id = (SELECT id FROM srcafis WHERE fp = 'ds2_u05_f_fo_ri_01')
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40
LIMIT 1;

/*
 first_matching_sample 
-----------------------
                   395
(1 row)
*/

-- faster!
SELECT b.id AS first_matching_sample
FROM srcafis_m a, srcafis_m b
WHERE a.id = 2041
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40
LIMIT 1;

-- returns all matches
SELECT array_agg(b.id) AS matching_samples
FROM srcafis_m a, srcafis_m b
WHERE a.id = 2041
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40;

/*
 matching_samples 
------------------
 {395,2042,2043}
(1 row)
*/
