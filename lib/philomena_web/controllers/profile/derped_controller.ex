defmodule PhilomenaWeb.Profile.DerpedController do
  use PhilomenaWeb, :controller

  alias Philomena.Users.User
  alias Philomena.Images.Image
  alias Philomena.Comments.Comment
  alias Philomena.Topics.Topic
  alias Philomena.Posts.Post
  alias Philomena.ImageFaves.ImageFave
  alias Philomena.ImageVotes.ImageVote
  alias Philomena.TagChanges.TagChange
  alias Philomena.SourceChanges.SourceChange
  alias Philomena.Reports.Report
  alias Philomena.Images.Tagging
  alias Philomena.Tags.Tag
  alias Philomena.Repo
  alias Philomena.UserIps.UserIp
  alias Philomena.Interactions
  import Ecto.Query

  plug :load_resource,
    model: User,
    id_field: "slug",
    id_name: "profile_id",
    persisted: true,
    preload: [verified_links: :tag]

  plug :verify_authorized

  @year 2025
  @start_of_year ~U[2025-01-01 00:00:00Z]
  @end_of_year ~U[2025-12-31 23:59:59Z]

  def index(conn, params) do
    user = conn.assigns.user

    token = share_token(user)

    global_overalls =
      Repo.one!(
        from s in "derped_global_overalls",
          select:
            map(s, [
              :user_count,
              :new_user_count,
              :image_count,
              :comment_count,
              :topic_count,
              :post_count,
              :image_fave_count,
              :image_vote_count,
              :tag_change_count,
              :source_change_count,
              :report_count
            ])
      )

    global_images =
      Repo.one!(
        from s in "derped_global_images",
          select: map(s, [:count, :user_count])
      )

    global_comments =
      Repo.one!(
        from s in "derped_global_comments",
          select: map(s, [:count, :user_count, :image_count, :new_image_count])
      )

    global_topics =
      Repo.one!(
        from s in "derped_global_topics",
          select: map(s, [:count, :user_count])
      )

    global_posts =
      Repo.one!(
        from s in "derped_global_posts",
          select: map(s, [:count, :user_count, :topic_count, :new_topic_count])
      )

    global_faves =
      Repo.one!(
        from s in "derped_global_faves",
          select: map(s, [:count, :user_count, :image_count, :new_image_count])
      )

    global_votes =
      Repo.one!(
        from s in "derped_global_votes",
          select:
            map(s, [
              :total_count,
              :up_count,
              :down_count,
              :user_count,
              :image_count,
              :new_image_count
            ])
      )

    global_tag_changes =
      Repo.one!(
        from s in "derped_global_tag_changes",
          select: map(s, [:count, :user_count, :image_count, :new_image_count])
      )

    global_tag_change_tags =
      Repo.one!(
        from s in "derped_global_tag_change_tags",
          select: map(s, [:total_count, :added_count, :removed_count, :tag_count])
      )

    global_source_changes =
      Repo.one!(
        from s in "derped_global_source_changes",
          select: map(s, [:count, :user_count, :image_count, :new_image_count])
      )

    global_reports =
      Repo.one!(
        from s in "derped_global_reports",
          select: map(s, [:count, :user_count])
      )

    global_top_rating_taggings =
      Repo.all(
        from s in "derped_global_top_taggings",
          join: t in Tag,
          on: t.id == s.tag_id,
          where: t.category == "rating",
          select: %{tag: t},
          select_merge: map(s, [:count]),
          order_by: [desc: s.count, desc: t.images_count, asc: t.name]
      )

    global_top_content_official_taggings =
      Repo.all(
        from s in "derped_global_top_taggings",
          join: t in Tag,
          on: t.id == s.tag_id,
          where: t.category == "content-official",
          select: %{tag: t},
          select_merge: map(s, [:count]),
          order_by: [desc: s.count, desc: t.images_count, asc: t.name],
          limit: 10,
          with_ties: true
      )

    global_top_character_taggings =
      Repo.all(
        from s in "derped_global_top_taggings",
          join: t in Tag,
          on: t.id == s.tag_id,
          where: t.category == "character",
          select: %{tag: t},
          select_merge: map(s, [:count]),
          order_by: [desc: s.count, desc: t.images_count, asc: t.name],
          limit: 10,
          with_ties: true
      )

    global_top_uploaders =
      Repo.all(
        from s in "derped_user_images",
          join: u in User,
          on: u.id == s.user_id,
          select: %{user: map(u, [:slug, :name])},
          select_merge: map(s, [:count]),
          order_by: [desc: s.count],
          limit: 10,
          with_ties: true
      )

    global_top_commenters =
      Repo.all(
        from s in "derped_user_comments",
          join: u in User,
          on: u.id == s.user_id,
          select: %{user: map(u, [:slug, :name])},
          select_merge: map(s, [:count, :image_count]),
          order_by: [desc: s.count],
          limit: 10,
          with_ties: true
      )

    global_top_posters =
      Repo.all(
        from s in "derped_user_posts",
          join: u in User,
          on: u.id == s.user_id,
          select: %{user: map(u, [:slug, :name])},
          select_merge: map(s, [:count, :topic_count]),
          order_by: [desc: s.count],
          limit: 10,
          with_ties: true
      )

    global_top_favers =
      Repo.all(
        from s in "derped_user_faves",
          join: u in User,
          on: u.id == s.user_id,
          select: %{user: map(u, [:slug, :name])},
          select_merge: map(s, [:count]),
          order_by: [desc: s.count],
          limit: 10,
          with_ties: true
      )

    global_top_voters =
      Repo.all(
        from s in "derped_user_votes",
          join: u in User,
          on: u.id == s.user_id,
          select: %{user: map(u, [:slug, :name])},
          select_merge: map(s, [:total_count]),
          order_by: [desc: s.total_count],
          limit: 10,
          with_ties: true
      )

    global_top_tag_changers =
      Repo.all(
        from s in "derped_user_tag_changes",
          join: u in User,
          on: u.id == s.user_id,
          select: %{user: map(u, [:slug, :name])},
          select_merge: map(s, [:count, :image_count]),
          order_by: [desc: s.count],
          limit: 10,
          with_ties: true
      )

    global_top_source_changers =
      Repo.all(
        from s in "derped_user_source_changes",
          join: u in User,
          on: u.id == s.user_id,
          select: %{user: map(u, [:slug, :name])},
          select_merge: map(s, [:count, :image_count]),
          order_by: [desc: s.count],
          limit: 10,
          with_ties: true
      )

    global_top_added_tags =
      Repo.all(
        from s in "derped_global_top_tag_change_tags",
          join: t in Tag,
          on: t.id == s.tag_id,
          select: %{tag: t},
          select_merge: map(s, [:count, :user_count]),
          where: s.added,
          order_by: [desc: s.count, desc: t.images_count, asc: t.name],
          limit: 10,
          with_ties: true
      )

    global_top_removed_tags =
      Repo.all(
        from s in "derped_global_top_tag_change_tags",
          join: t in Tag,
          on: t.id == s.tag_id,
          select: %{tag: t},
          select_merge: map(s, [:count, :user_count]),
          where: not s.added,
          order_by: [desc: s.count, desc: t.images_count, asc: t.name],
          limit: 10,
          with_ties: true
      )

    user_visits =
      Repo.one(
        from s in "derped_user_visits",
          where: s.user_id == ^user.id,
          select: map(s, [:rank, :ntile])
      ) || %{rank: nil, ntile: nil}

    user_visits =
      Map.merge(
        user_visits,
        Repo.one(
          from ui in UserIp,
            where: ui.user_id == ^user.id,
            select: %{
              overall: sum(ui.uses),
              total:
                sum(ui.uses)
                |> filter(ui.created_at >= ^@start_of_year and ui.created_at <= ^@end_of_year)
            }
        )
      )

    user_images =
      Repo.one(
        from s in "derped_user_images",
          where: s.user_id == ^user.id,
          select: map(s, [:count, :rank, :ntile])
      ) || %{count: 0, rank: nil, ntile: nil}

    user_comments =
      Repo.one(
        from s in "derped_user_comments",
          where: s.user_id == ^user.id,
          select: map(s, [:count, :image_count, :rank, :ntile])
      ) || %{count: 0, image_count: 0, rank: nil, ntile: nil}

    user_topics =
      Repo.one(
        from s in "derped_user_topics",
          where: s.user_id == ^user.id,
          select: map(s, [:count, :rank, :ntile])
      ) || %{count: 0, rank: nil, ntile: nil}

    user_posts =
      Repo.one(
        from s in "derped_user_posts",
          where: s.user_id == ^user.id,
          select: map(s, [:count, :topic_count, :rank, :ntile])
      ) || %{count: 0, topic_count: 0, rank: nil, ntile: nil}

    user_faves =
      Repo.one(
        from s in "derped_user_faves",
          where: s.user_id == ^user.id,
          select: map(s, [:count, :rank, :ntile])
      ) || %{count: 0, rank: nil, ntile: nil}

    user_votes =
      Repo.one(
        from s in "derped_user_votes",
          where: s.user_id == ^user.id,
          select: map(s, [:total_count, :up_count, :down_count, :rank, :ntile])
      ) || %{total_count: 0, up_count: 0, down_count: 0, rank: nil, ntile: nil}

    user_tag_changes =
      Repo.one(
        from s in "derped_user_tag_changes",
          where: s.user_id == ^user.id,
          select: map(s, [:count, :image_count, :rank, :ntile])
      ) || %{count: 0, image_count: 0, rank: nil, ntile: nil}

    user_source_changes =
      Repo.one(
        from s in "derped_user_source_changes",
          where: s.user_id == ^user.id,
          select: map(s, [:count, :image_count, :rank, :ntile])
      ) || %{count: 0, image_count: 0, rank: nil, ntile: nil}

    user_reports =
      Repo.one(
        from s in "derped_user_reports",
          where: s.user_id == ^user.id,
          select: map(s, [:count, :avg_time, :rank, :ntile])
      ) || %{count: 0, avg_time: 0, rank: nil, ntile: nil}

    user_top_faved_character_tags =
      Repo.all(
        from s in "derped_faved_tags",
          join: t in Tag,
          on: t.id == s.tag_id,
          where: s.user_id == ^user.id,
          where: t.category == "character",
          select: %{tag: t},
          select_merge: map(s, [:faves, :rank, :ntile]),
          order_by: [desc: s.faves, asc: s.rank, desc: t.images_count, asc: t.name],
          limit: 10,
          with_ties: true
      )

    user_top_faved_artist_tags =
      Repo.all(
        from s in "derped_faved_tags",
          join: t in Tag,
          on: t.id == s.tag_id,
          where: s.user_id == ^user.id,
          where: t.category == "origin" and like(t.name, "%:%"),
          select: %{tag: t},
          select_merge: map(s, [:faves, :rank, :ntile]),
          order_by: [desc: s.faves, asc: s.rank, desc: t.images_count, asc: t.name],
          limit: 10,
          with_ties: true
      )

    user_top_faved_oc_tags =
      Repo.all(
        from s in "derped_faved_tags",
          join: t in Tag,
          on: t.id == s.tag_id,
          where: s.user_id == ^user.id,
          where: t.category == "oc" and like(t.name, "oc:%"),
          select: %{tag: t},
          select_merge: map(s, [:faves, :rank, :ntile]),
          order_by: [desc: s.faves, asc: s.rank, desc: t.images_count, asc: t.name],
          limit: 10,
          with_ties: true
      )

    user_top_faved_ship_tags =
      Repo.all(
        from s in "derped_faved_tags",
          join: t in Tag,
          on: t.id == s.tag_id,
          where: s.user_id == ^user.id,
          where: like(t.name, "ship:%"),
          select: %{tag: t},
          select_merge: map(s, [:faves, :rank, :ntile]),
          order_by: [desc: s.faves, asc: s.rank, desc: t.images_count, asc: t.name],
          limit: 10,
          with_ties: true
      )

    user_top_added_tags =
      Repo.all(
        from s in "derped_user_top_tag_change_tags",
          join: t in Tag,
          on: t.id == s.tag_id,
          where: s.user_id == ^user.id,
          where: s.added,
          select: %{tag: t},
          select_merge: map(s, [:count, :rank, :ntile]),
          order_by: [desc: s.count, asc: s.rank, desc: t.images_count, asc: t.name],
          limit: 10,
          with_ties: true
      )

    user_top_removed_tags =
      Repo.all(
        from s in "derped_user_top_tag_change_tags",
          join: t in Tag,
          on: t.id == s.tag_id,
          where: s.user_id == ^user.id,
          where: not s.added,
          select: %{tag: t},
          select_merge: map(s, [:count, :rank, :ntile]),
          order_by: [desc: s.count, asc: s.rank, desc: t.images_count, asc: t.name],
          limit: 10,
          with_ties: true
      )

    random_daily_base_query =
      if params["daily"] == "votes",
        do: from(v in ImageVote, where: v.up),
        else: from(f in ImageFave)

    user_random_daily_images =
      Repo.all(
        from f in random_daily_base_query,
          join: image in assoc(f, :image),
          where: f.created_at >= ^@start_of_year and f.created_at <= ^@end_of_year,
          where: f.user_id == ^user.id,
          where: not image.hidden_from_users,
          select: f,
          distinct: fragment("EXTRACT(DOY FROM ?)", f.created_at),
          order_by: [fragment("EXTRACT(DOY FROM ?)", f.created_at), fragment("RANDOM()")],
          preload: [image: [:sources, tags: :aliases]]
      )

    linked_tags =
      user.verified_links
      |> Enum.uniq_by(& &1.tag_id)
      |> Enum.map(fn %{tag: tag} ->
        %{
          tag: tag,
          images:
            Repo.one(
              from image in Image,
                join: tagging in Tagging,
                on: tagging.image_id == image.id,
                where: tagging.tag_id == ^tag.id,
                where: not image.hidden_from_users,
                where: image.first_seen_at <= ^@end_of_year,
                select: %{
                  overall_count: count(),
                  new_count:
                    count()
                    |> filter(image.first_seen_at >= ^@start_of_year)
                }
            ),
          faves:
            Repo.one(
              from s in "derped_artist_tag_fave_stats",
                where: s.tag_id == ^tag.id,
                select: map(s, [:overall_count, :new_count, :new_images_count])
            ) || %{overall_count: 0, new_count: 0, new_images_count: 0},
          scores:
            Repo.one(
              from s in "derped_artist_tag_score_stats",
                where: s.tag_id == ^tag.id,
                select: map(s, [:overall_count, :new_count, :new_images_count])
            ) || %{overall_count: 0, new_count: 0, new_images_count: 0},
          comments:
            Repo.one(
              from s in "derped_artist_tag_comment_stats",
                where: s.tag_id == ^tag.id,
                select: map(s, [:overall_count, :new_count, :new_images_count])
            ) || %{overall_count: 0, new_count: 0, new_images_count: 0},
          most_faved_images:
            Repo.all(
              from image in Image,
                join: tagging in Tagging,
                on: tagging.image_id == image.id,
                where: tagging.tag_id == ^tag.id,
                where: not image.hidden_from_users,
                where:
                  image.first_seen_at >= ^@start_of_year and image.first_seen_at <= ^@end_of_year,
                select: image,
                order_by: [desc: image.faves_count],
                limit: 4,
                preload: [:sources, tags: :aliases]
            ),
          most_scored_images:
            Repo.all(
              from image in Image,
                join: tagging in Tagging,
                on: tagging.image_id == image.id,
                where: tagging.tag_id == ^tag.id,
                where: not image.hidden_from_users,
                where:
                  image.first_seen_at >= ^@start_of_year and image.first_seen_at <= ^@end_of_year,
                select: image,
                order_by: [desc: image.score],
                limit: 4,
                preload: [:sources, tags: :aliases]
            ),
          most_commented_on_images:
            Repo.all(
              from image in Image,
                join: tagging in Tagging,
                on: tagging.image_id == image.id,
                where: tagging.tag_id == ^tag.id,
                where: not image.hidden_from_users,
                where:
                  image.first_seen_at >= ^@start_of_year and image.first_seen_at <= ^@end_of_year,
                where: image.comments_count > 0,
                select: image,
                order_by: [desc: image.comments_count],
                limit: 4,
                preload: [:sources, tags: :aliases]
            )
        }
      end)
      |> Enum.sort_by(& &1.images.new_count, :desc)

    interactions =
      Interactions.user_interactions(
        (user_random_daily_images |> Enum.map(& &1.image)) ++
          (linked_tags
           |> Enum.map(
             &[&1.most_faved_images, &1.most_scored_images, &1.most_commented_on_images]
           )
           |> List.flatten()),
        conn.assigns.current_user
      )

    render(
      conn,
      "index.html",
      title: "Derped #{@year} for User `#{user.name}'",
      token: token,
      global_overalls: global_overalls,
      global_images: global_images,
      global_comments: global_comments,
      global_topics: global_topics,
      global_posts: global_posts,
      global_faves: global_faves,
      global_votes: global_votes,
      global_tag_changes: global_tag_changes,
      global_tag_change_tags: global_tag_change_tags,
      global_source_changes: global_source_changes,
      global_reports: global_reports,
      global_top_rating_taggings: global_top_rating_taggings,
      global_top_content_official_taggings: global_top_content_official_taggings,
      global_top_character_taggings: global_top_character_taggings,
      global_top_uploaders: global_top_uploaders,
      global_top_commenters: global_top_commenters,
      global_top_posters: global_top_posters,
      global_top_favers: global_top_favers,
      global_top_voters: global_top_voters,
      global_top_tag_changers: global_top_tag_changers,
      global_top_source_changers: global_top_source_changers,
      global_top_added_tags: global_top_added_tags,
      global_top_removed_tags: global_top_removed_tags,
      user_visits: user_visits,
      user_images: user_images,
      user_comments: user_comments,
      user_topics: user_topics,
      user_posts: user_posts,
      user_faves: user_faves,
      user_votes: user_votes,
      user_tag_changes: user_tag_changes,
      user_source_changes: user_source_changes,
      user_reports: user_reports,
      user_top_faved_character_tags: user_top_faved_character_tags,
      user_top_faved_artist_tags: user_top_faved_artist_tags,
      user_top_faved_oc_tags: user_top_faved_oc_tags,
      user_top_faved_ship_tags: user_top_faved_ship_tags,
      user_top_added_tags: user_top_added_tags,
      user_top_removed_tags: user_top_removed_tags,
      user_random_daily_images: user_random_daily_images,
      linked_tags: linked_tags,
      interactions: interactions
    )
  end

  defp verify_authorized(conn, _opts) do
    current = conn.assigns.current_user
    user = conn.assigns.user
    user_id = user.id

    cond do
      match?(%{id: ^user_id}, current) ->
        conn

      match?(%{role: role} when role in ~w(moderator admin), current) ->
        conn

      not is_nil(conn.params["token"]) and conn.params["token"] == share_token(user) ->
        conn

      true ->
        PhilomenaWeb.NotAuthorizedPlug.call(conn)
    end
  end

  defp share_token(user) do
    salt =
      Application.get_env(:philomena, :anonymous_name_salt)
      |> to_string()

    message = "derped-#{@year}-#{user.id}"

    {:ok, token} =
      :pbkdf2.pbkdf2(
        :sha256,
        message,
        salt,
        100,
        8
      )

    :binary.encode_hex(token, :lowercase)
  end
end
