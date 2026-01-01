BEGIN;

DROP MATERIALIZED VIEW IF EXISTS derped_global_overalls;

CREATE MATERIALIZED VIEW
  derped_global_overalls AS
SELECT
  (
    SELECT
      COUNT(*)
    FROM
      users
  ) AS user_count,
  (
    SELECT
      COUNT(*)
    FROM
      users
    WHERE
      created_at >= '2025-01-01'
      AND created_at < '2026-01-01'
  ) AS new_user_count,
  (
    SELECT
      COUNT(*)
    FROM
      images
  ) AS image_count,
  (
    SELECT
      COUNT(*)
    FROM
      comments
  ) AS comment_count,
  (
    SELECT
      COUNT(*)
    FROM
      topics
  ) AS topic_count,
  (
    SELECT
      COUNT(*)
    FROM
      posts
  ) AS post_count,
  (
    SELECT
      COUNT(*)
    FROM
      image_faves
  ) AS image_fave_count,
  (
    SELECT
      COUNT(*)
    FROM
      image_votes
  ) AS image_vote_count,
  (
    SELECT
      COUNT(*)
    FROM
      tag_changes
  ) AS tag_change_count,
  (
    SELECT
      COUNT(*)
    FROM
      source_changes
  ) AS source_change_count,
  (
    SELECT
      COUNT(*)
    FROM
      reports
  ) AS report_count;

DROP MATERIALIZED VIEW IF EXISTS derped_global_images;

CREATE MATERIALIZED VIEW
  derped_global_images AS
SELECT
  COUNT(*),
  COUNT(DISTINCT user_id) AS user_count
FROM
  images
WHERE
  created_at >= '2025-01-01'
  AND created_at < '2026-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_comments;

CREATE MATERIALIZED VIEW
  derped_global_comments AS
SELECT
  COUNT(*),
  COUNT(DISTINCT comments.user_id) AS user_count,
  COUNT(DISTINCT images.id) AS image_count,
  COUNT(DISTINCT images.id) FILTER (
    WHERE
      images.created_at >= '2025-01-01'
      AND images.created_at < '2026-01-01'
  ) AS new_image_count
FROM
  comments
  INNER JOIN images ON images.id = comments.image_id
WHERE
  comments.created_at >= '2025-01-01'
  AND comments.created_at < '2026-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_topics;

CREATE MATERIALIZED VIEW
  derped_global_topics AS
SELECT
  COUNT(*),
  COUNT(DISTINCT user_id) AS user_count
FROM
  topics
WHERE
  created_at >= '2025-01-01'
  AND created_at < '2026-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_posts;

CREATE MATERIALIZED VIEW
  derped_global_posts AS
SELECT
  COUNT(*),
  COUNT(DISTINCT posts.user_id) AS user_count,
  COUNT(DISTINCT topics.id) AS topic_count,
  COUNT(DISTINCT topics.id) FILTER (
    WHERE
      topics.created_at >= '2025-01-01'
      AND topics.created_at < '2026-01-01'
  ) AS new_topic_count
FROM
  posts
  INNER JOIN topics ON topics.id = posts.topic_id
WHERE
  posts.created_at >= '2025-01-01'
  AND posts.created_at < '2026-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_faves;

CREATE MATERIALIZED VIEW
  derped_global_faves AS
SELECT
  COUNT(*),
  COUNT(DISTINCT image_faves.user_id) AS user_count,
  COUNT(DISTINCT images.id) AS image_count,
  COUNT(DISTINCT images.id) FILTER (
    WHERE
      images.created_at >= '2025-01-01'
      AND images.created_at < '2026-01-01'
  ) AS new_image_count
FROM
  image_faves
  INNER JOIN images ON images.id = image_faves.image_id
WHERE
  image_faves.created_at >= '2025-01-01'
  AND image_faves.created_at < '2026-01-01';

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
  COUNT(DISTINCT image_votes.user_id) AS user_count,
  COUNT(DISTINCT images.id) AS image_count,
  COUNT(DISTINCT images.id) FILTER (
    WHERE
      images.created_at >= '2025-01-01'
      AND images.created_at < '2026-01-01'
  ) AS new_image_count
FROM
  image_votes
  INNER JOIN images ON images.id = image_votes.image_id
WHERE
  image_votes.created_at >= '2025-01-01'
  AND image_votes.created_at < '2026-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_tag_changes;

CREATE MATERIALIZED VIEW
  derped_global_tag_changes AS
SELECT
  COUNT(tag_changes.id),
  COUNT(DISTINCT tag_changes.user_id) AS user_count,
  COUNT(DISTINCT images.id) AS image_count,
  COUNT(DISTINCT images.id) FILTER (
    WHERE
      images.created_at >= '2025-01-01'
      AND images.created_at < '2026-01-01'
  ) AS new_image_count
FROM
  tag_changes
  INNER JOIN images ON images.id = tag_changes.image_id
WHERE
  tag_changes.created_at >= '2025-01-01'
  AND tag_changes.created_at < '2026-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_tag_change_tags;

CREATE MATERIALIZED VIEW
  derped_global_tag_change_tags AS
SELECT
  COUNT(*) AS total_count,
  COUNT(*) FILTER (
    WHERE
      added
  ) AS added_count,
  COUNT(*) FILTER (
    WHERE
      NOT added
  ) AS removed_count,
  COUNT(DISTINCT tag_id) AS tag_count
FROM
  tag_changes
  INNER JOIN tag_change_tags ON tag_change_tags.tag_change_id = tag_changes.id
WHERE
  tag_changes.created_at >= '2025-01-01'
  AND tag_changes.created_at < '2026-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_source_changes;

CREATE MATERIALIZED VIEW
  derped_global_source_changes AS
SELECT
  COUNT(*),
  COUNT(DISTINCT source_changes.user_id) AS user_count,
  COUNT(DISTINCT images.id) AS image_count,
  COUNT(DISTINCT images.id) FILTER (
    WHERE
      images.created_at >= '2025-01-01'
      AND images.created_at < '2026-01-01'
  ) AS new_image_count
FROM
  source_changes
  INNER JOIN images ON images.id = source_changes.image_id
WHERE
  source_changes.created_at >= '2025-01-01'
  AND source_changes.created_at < '2026-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_top_taggings;

CREATE MATERIALIZED VIEW
  derped_global_top_taggings AS
SELECT
  tags.id AS tag_id,
  COUNT(*)
FROM
  images
  INNER JOIN image_taggings ON image_taggings.image_id = images.id
  INNER JOIN tags ON tags.id = image_taggings.tag_id
WHERE
  images.created_at >= '2025-01-01'
  AND images.created_at < '2026-01-01'
  AND tags.category IS NOT NULL
GROUP BY
  tags.id;

DROP MATERIALIZED VIEW IF EXISTS derped_global_top_tag_change_tags;

CREATE MATERIALIZED VIEW
  derped_global_top_tag_change_tags AS
SELECT
  tag_change_tags.tag_id,
  tag_change_tags.added,
  COUNT(*),
  COUNT(DISTINCT tag_changes.user_id) AS user_count
FROM
  tag_changes
  INNER JOIN tag_change_tags ON tag_change_tags.tag_change_id = tag_changes.id
WHERE
  tag_changes.created_at >= '2025-01-01'
  AND tag_changes.created_at < '2026-01-01'
GROUP BY
  tag_change_tags.tag_id,
  tag_change_tags.added;

DROP MATERIALIZED VIEW IF EXISTS derped_user_top_tag_change_tags;

CREATE MATERIALIZED VIEW
  derped_user_top_tag_change_tags AS
SELECT
  tag_changes.user_id,
  tag_change_tags.tag_id,
  tag_change_tags.added,
  COUNT(*) AS count,
  DENSE_RANK() OVER (
    PARTITION BY
      tag_change_tags.tag_id,
      tag_change_tags.added
    ORDER BY
      COUNT(*) DESC
  ) AS rank,
  NTILE(100) OVER (
    PARTITION BY
      tag_change_tags.tag_id,
      tag_change_tags.added
    ORDER BY
      COUNT(*) DESC
  )
FROM
  tag_changes
  INNER JOIN tag_change_tags ON tag_change_tags.tag_change_id = tag_changes.id
WHERE
  tag_changes.created_at >= '2025-01-01'
  AND tag_changes.created_at < '2026-01-01'
  AND tag_changes.user_id IS NOT NULL
GROUP BY
  tag_changes.user_id,
  tag_change_tags.tag_id,
  tag_change_tags.added;

DROP MATERIALIZED VIEW IF EXISTS derped_global_reports;

CREATE MATERIALIZED VIEW
  derped_global_reports AS
SELECT
  COUNT(*),
  COUNT(DISTINCT user_id) AS user_count
FROM
  reports
WHERE
  created_at >= '2025-01-01'
  AND created_at < '2026-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_user_visits;

CREATE MATERIALIZED VIEW
  derped_user_visits AS
SELECT
  user_id,
  DENSE_RANK() OVER (
    ORDER BY
      SUM(uses) DESC
  ) AS rank,
  NTILE(100) OVER (
    ORDER BY
      SUM(uses) DESC
  )
FROM
  user_ips AS ui
WHERE
  created_at >= '2025-01-01'
  AND created_at < '2026-01-01'
GROUP BY
  user_id;

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
  AND created_at < '2026-01-01'
  AND user_id IS NOT NULL
GROUP BY
  user_id;

DROP MATERIALIZED VIEW IF EXISTS derped_user_comments;

CREATE MATERIALIZED VIEW
  derped_user_comments AS
SELECT
  user_id,
  COUNT(*),
  COUNT(DISTINCT image_id) AS image_count,
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
  AND created_at < '2026-01-01'
  AND user_id IS NOT NULL
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
  AND created_at < '2026-01-01'
  AND user_id IS NOT NULL
GROUP BY
  user_id;

DROP MATERIALIZED VIEW IF EXISTS derped_user_posts;

CREATE MATERIALIZED VIEW
  derped_user_posts AS
SELECT
  user_id,
  COUNT(*),
  COUNT(DISTINCT topic_id) AS topic_count,
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
  AND created_at < '2026-01-01'
  AND user_id IS NOT NULL
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
  AND created_at < '2026-01-01'
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
  AND created_at < '2026-01-01'
GROUP BY
  user_id;

DROP MATERIALIZED VIEW IF EXISTS derped_user_tag_changes;

CREATE MATERIALIZED VIEW
  derped_user_tag_changes AS
SELECT
  user_id,
  COUNT(*),
  COUNT(DISTINCT image_id) AS image_count,
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
  AND created_at < '2026-01-01'
  AND user_id IS NOT NULL
GROUP BY
  user_id;

DROP MATERIALIZED VIEW IF EXISTS derped_user_source_changes;

CREATE MATERIALIZED VIEW
  derped_user_source_changes AS
SELECT
  user_id,
  COUNT(*),
  COUNT(DISTINCT image_id) AS image_count,
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
  AND created_at < '2026-01-01'
  AND user_id IS NOT NULL
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
        AND created_at != updated_at
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
  AND created_at < '2026-01-01'
  AND user_id IS NOT NULL
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
  AND f.created_at < '2026-01-01'
  AND t.category IS NOT NULL
GROUP BY
  t.id,
  f.user_id;

COMMIT;