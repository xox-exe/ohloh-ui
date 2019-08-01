/* This script deletes unused project_security_sets, releases, releases_vulnerabilities, and
 * vulnerabilities.
 *
 */

 BEGIN;
 CREATE TEMPORARY TABLE unused_project_security_sets(id integer) ON COMMIT DROP;

 /* This inserts those pss.ids that are NOT best_project_security_sets */
 INSERT INTO unused_project_security_sets (
     SELECT pss.id from project_security_sets pss
     WHERE pss.id not in (SELECT best_project_security_set_id FROM projects
                          WHERE best_project_security_set_id IS NOT NULL)
     ORDER BY pss.created_at LIMIT 100000
 );

 /* This removes those pss.ids that are newer than the best_project_security_set from the list of
    unused project_security_sets */
DELETE FROM unused_project_security_sets where id IN (
    select pss2.id from project_security_sets pss2
    inner join (
        select pss.project_id, pss.created_at from project_security_sets pss
        inner join projects p on p.best_project_security_set_id = pss.id and not p.deleted
    ) as best_pss on pss2.project_id = best_pss.project_id
    where pss2.created_at > best_pss.created_at
);

/* Delete from vulnerabilities when they belong to releases for unused project_security_sets */
DELETE FROM vulnerabilities where id in (
    SELECT rv.vulnerability_id from releases_vulnerabilities rv
    INNER JOIN releases r on r.id = rv.release_id
    INNER JOIN unused_project_security_sets upss on upss.id = r.project_security_set_id
);

/* Delete the join table records when they belong to releases for unused project_security_sets */
DELETE FROM releases_vulnerabilities rv where rv.release_id in (
    SELECT r.id from releases r
    INNER JOIN unused_project_security_sets upss on upss.id = r.project_security_set_id
);

/* Now delete those releases that belong to unused project_security_sets */
DELETE FROM releases where r.project_security_set_id in (
    SELECT id from unused_project_security_sets
);

/* Finally delete the unused project_security_sets */
DELETE FROM project_security_sets where id in (
    SELECT id FROM unused_project_security_sets
);

COMMIT;

/* Vacuum all tables */
VACUUM ANALYZE project_security_sets;
VACUUM ANALYZE releases;
VACUUM ANALYZE releases_vulnerabilities;
VACUUM ANALYZE vulnerabilities;
