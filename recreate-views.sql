BEGIN;

DROP MATERIALIZED VIEW IF EXISTS derped_global_images;

CREATE MATERIALIZED VIEW
  derped_global_images AS
SELECT
  COUNT(*),
  COUNT(DISTINCT user_id) AS user_count
FROM
  images
WHERE
  created_at >= '2025-01-01';

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
  ) AS new_image_count
FROM
  comments
  INNER JOIN images ON images.id = comments.image_id
WHERE
  comments.created_at >= '2025-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_topics;

CREATE MATERIALIZED VIEW
  derped_global_topics AS
SELECT
  COUNT(*),
  COUNT(DISTINCT user_id) AS user_count
FROM
  topics
WHERE
  created_at >= '2025-01-01';

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
  ) AS new_topic_count
FROM
  posts
  INNER JOIN topics ON topics.id = posts.topic_id
WHERE
  posts.created_at >= '2025-01-01';

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
  ) AS new_image_count
FROM
  image_faves
  INNER JOIN images ON images.id = image_faves.image_id
WHERE
  image_faves.created_at >= '2025-01-01';

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
  ) AS new_image_count
FROM
  image_votes
  INNER JOIN images ON images.id = image_votes.image_id
WHERE
  image_votes.created_at >= '2025-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_taggings;

CREATE MATERIALIZED VIEW
  derped_global_taggings AS
SELECT
  COUNT(*),
  COUNT(DISTINCT user_id) AS user_count,
  COUNT(DISTINCT images.id) AS image_count,
  COUNT(DISTINCT images.id) FILTER (
    WHERE
      images.created_at >= '2025-01-01'
  ) AS new_image_count
FROM
  image_taggings
  INNER JOIN images ON images.id = image_taggings.image_id
WHERE
  created_at >= '2025-01-01';

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
  ) AS new_image_count
FROM
  tag_changes
  INNER JOIN images ON images.id = tag_changes.image_id
WHERE
  tag_changes.created_at >= '2025-01-01';

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
  tag_changes.created_at >= '2025-01-01';

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
  ) AS new_image_count
FROM
  source_changes
  INNER JOIN images ON images.id = source_changes.image_id
WHERE
  source_changes.created_at >= '2025-01-01';

DROP MATERIALIZED VIEW IF EXISTS derped_global_reports;

DROP MATERIALIZED VIEW IF EXISTS derped_global_top_tag_change_tags;

CREATE MATERIALIZED VIEW
  derped_global_top_tag_change_tags AS
SELECT
  tag_change_tags.tag_id,
  COUNT(*) FILTER (
    WHERE
      tag_change_tags.added
  ) AS added_count,
  COUNT(*) FILTER (
    WHERE
      NOT tag_change_tags.added
  ) AS removed_count,
  COUNT(DISTINCT tag_changes.user_id) FILTER (
    WHERE
      tag_change_tags.added
  ) AS added_user_count,
  COUNT(DISTINCT tag_changes.user_id) FILTER (
    WHERE
      NOT tag_change_tags.added
  ) AS removed_user_count
FROM
  tag_changes
  INNER JOIN tag_change_tags ON tag_change_tags.tag_change_id = tag_changes.id
WHERE
  tag_changes.created_at >= '2025-01-01'
GROUP BY
  tag_change_tags.tag_id,
  tag_change_tags.added;

CREATE MATERIALIZED VIEW
  derped_global_reports AS
SELECT
  COUNT(*),
  COUNT(DISTINCT user_id) AS user_count
FROM
  reports
WHERE
  created_at >= '2025-01-01';

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