BEGIN;

DROP MATERIALIZED VIEW IF EXISTS derped_global_images;

CREATE MATERIALIZED VIEW
  derped_global_images AS
SELECT
  COUNT(*),
  COUNT(DISTINCT user_id) AS distinct_user_count
FROM
  images
WHERE
  created_at >= '2025-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_comments;

CREATE MATERIALIZED VIEW
  derped_global_comments AS
SELECT
  COUNT(*),
  COUNT(DISTINCT image_id) AS distinct_image_count,
  COUNT(DISTINCT user_id) AS distinct_user_count
FROM
  comments
WHERE
  created_at >= '2025-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_topics;

CREATE MATERIALIZED VIEW
  derped_global_topics AS
SELECT
  COUNT(*),
  COUNT(DISTINCT user_id) AS distinct_user_count
FROM
  topics
WHERE
  created_at >= '2025-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_posts;

CREATE MATERIALIZED VIEW
  derped_global_posts AS
SELECT
  COUNT(*),
  COUNT(DISTINCT topic_id) AS distinct_topic_count,
  COUNT(DISTINCT user_id) AS distinct_user_count
FROM
  posts
WHERE
  created_at >= '2025-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_faves;

CREATE MATERIALIZED VIEW
  derped_global_faves AS
SELECT
  COUNT(*),
  COUNT(DISTINCT image_id) AS distinct_image_count,
  COUNT(DISTINCT user_id) AS distinct_user_count
FROM
  image_faves
WHERE
  created_at >= '2025-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_votes;

CREATE MATERIALIZED VIEW
  derped_global_votes AS
SELECT
  COUNT(*) AS total_count,
  COUNT(*) FILTER (
    WHERE
      up
  ) AS up_count,
  COUNT(*) FILTER (
    WHERE
      NOT up
  ) AS down_count,
  COUNT(DISTINCT image_id) AS distinct_image_count,
  COUNT(DISTINCT user_id) AS distinct_user_count
FROM
  image_votes
WHERE
  created_at >= '2025-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_tag_changes;

CREATE MATERIALIZED VIEW
  derped_global_tag_changes AS
SELECT
  COUNT(*),
  COUNT(DISTINCT image_id) AS distinct_image_count
FROM
  tag_changes
WHERE
  created_at >= '2025-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_source_changes;

CREATE MATERIALIZED VIEW
  derped_global_source_changes AS
SELECT
  COUNT(*),
  COUNT(DISTINCT image_id) AS distinct_image_count
FROM
  source_changes
WHERE
  created_at >= '2025-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_reports;

CREATE MATERIALIZED VIEW
  derped_global_reports AS
SELECT
  COUNT(*),
  COUNT(DISTINCT user_id) AS distinct_user_count
FROM
  reports
WHERE
  created_at >= '2025-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_user_images;

CREATE MATERIALIZED VIEW
  derped_user_images AS
SELECT
  user_id,
  COUNT(*),
  DENSE_RANK() OVER (
    ORDER BY
      COUNT(*) DESC
  ) AS rank,
  NTILE(100) OVER (
    ORDER BY
      COUNT(*) DESC
  )
FROM
  images
WHERE
  created_at >= '2025-01-01'
GROUP BY
  user_id;

DROP MATERIALIZED VIEW IF EXISTS derped_user_comments;

CREATE MATERIALIZED VIEW
  derped_user_comments AS
SELECT
  user_id,
  COUNT(*),
  COUNT(DISTINCT image_id) AS distinct_image_count,
  DENSE_RANK() OVER (
    ORDER BY
      COUNT(*) DESC
  ) AS rank,
  NTILE(100) OVER (
    ORDER BY
      COUNT(*) DESC
  )
FROM
  comments
WHERE
  created_at >= '2025-01-01'
GROUP BY
  user_id;

DROP MATERIALIZED VIEW IF EXISTS derped_user_topics;

CREATE MATERIALIZED VIEW
  derped_user_topics AS
SELECT
  user_id,
  COUNT(*),
  DENSE_RANK() OVER (
    ORDER BY
      COUNT(*) DESC
  ) AS rank,
  NTILE(100) OVER (
    ORDER BY
      COUNT(*) DESC
  )
FROM
  topics
WHERE
  created_at >= '2025-01-01'
GROUP BY
  user_id;

DROP MATERIALIZED VIEW IF EXISTS derped_user_posts;

CREATE MATERIALIZED VIEW
  derped_user_posts AS
SELECT
  user_id,
  COUNT(*),
  COUNT(DISTINCT topic_id) AS distinct_topic_count,
  DENSE_RANK() OVER (
    ORDER BY
      COUNT(*) DESC
  ) AS rank,
  NTILE(100) OVER (
    ORDER BY
      COUNT(*) DESC
  )
FROM
  posts
WHERE
  created_at >= '2025-01-01'
GROUP BY
  user_id;

DROP MATERIALIZED VIEW IF EXISTS derped_user_faves;

CREATE MATERIALIZED VIEW
  derped_user_faves AS
SELECT
  user_id,
  COUNT(*),
  DENSE_RANK() OVER (
    ORDER BY
      COUNT(*) DESC
  ) AS rank,
  NTILE(100) OVER (
    ORDER BY
      COUNT(*) DESC
  )
FROM
  image_faves
WHERE
  created_at >= '2025-01-01'
GROUP BY
  user_id;

DROP MATERIALIZED VIEW IF EXISTS derped_user_votes;

CREATE MATERIALIZED VIEW
  derped_user_votes AS
SELECT
  user_id,
  COUNT(*) AS total_count,
  COUNT(*) FILTER (
    WHERE
      up
  ) AS up_count,
  COUNT(*) FILTER (
    WHERE
      NOT up
  ) AS down_count,
  DENSE_RANK() OVER (
    ORDER BY
      COUNT(*) DESC
  ) AS rank,
  NTILE(100) OVER (
    ORDER BY
      COUNT(*) DESC
  )
FROM
  image_votes
WHERE
  created_at >= '2025-01-01'
GROUP BY
  user_id;

DROP MATERIALIZED VIEW IF EXISTS derped_user_tag_changes;

CREATE MATERIALIZED VIEW
  derped_user_tag_changes AS
SELECT
  user_id,
  COUNT(*),
  COUNT(DISTINCT image_id) AS distinct_image_count,
  DENSE_RANK() OVER (
    ORDER BY
      COUNT(*) DESC
  ) AS rank,
  NTILE(100) OVER (
    ORDER BY
      COUNT(*) DESC
  )
FROM
  tag_changes
WHERE
  created_at >= '2025-01-01'
GROUP BY
  user_id;

DROP MATERIALIZED VIEW IF EXISTS derped_user_source_changes;

CREATE MATERIALIZED VIEW
  derped_user_source_changes AS
SELECT
  user_id,
  COUNT(*),
  COUNT(DISTINCT image_id) AS distinct_image_count,
  DENSE_RANK() OVER (
    ORDER BY
      COUNT(*) DESC
  ) AS rank,
  NTILE(100) OVER (
    ORDER BY
      COUNT(*) DESC
  )
FROM
  source_changes
WHERE
  created_at >= '2025-01-01'
GROUP BY
  user_id;

DROP MATERIALIZED VIEW IF EXISTS derped_user_reports;

CREATE MATERIALIZED VIEW
  derped_user_reports AS
SELECT
  user_id,
  COUNT(*),
  COALESCE(
    AVG(
      EXTRACT(
        EPOCH
        FROM
          (updated_at - created_at)
      )
    ) FILTER (
      WHERE
        NOT open
    ),
    0::double precision
  ) AS avg_time,
  DENSE_RANK() OVER (
    ORDER BY
      COUNT(*) DESC
  ) AS rank,
  NTILE(100) OVER (
    ORDER BY
      COUNT(*) DESC
  )
FROM
  reports
WHERE
  created_at >= '2025-01-01'
GROUP BY
  user_id;

DROP MATERIALIZED VIEW IF EXISTS derped_faved_tags;

CREATE MATERIALIZED VIEW
  derped_faved_tags AS
SELECT
  t.id AS tag_id,
  f.user_id,
  COUNT(*) AS faves,
  DENSE_RANK(*) OVER (
    PARTITION BY
      t.id
    ORDER BY
      COUNT(*) DESC
  ) AS rank,
  NTILE(100) OVER (
    PARTITION BY
      t.id
    ORDER BY
      COUNT(*) DESC
  )
FROM
  image_faves AS f
  INNER JOIN image_taggings AS it ON it.image_id = f.image_id
  INNER JOIN tags AS t ON t.id = it.tag_id
WHERE
  f.created_at >= '2025-01-01'
  AND t.category IS NOT NULL
GROUP BY
  t.id,
  f.user_id;

COMMIT;