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
  import Ecto.Query

  plug :load_resource,
    model: User,
    id_field: "slug",
    id_name: "profile_id",
    persisted: true

  plug :verify_authorized

  @year 2025
  @start_of_year ~U[2025-01-01 00:00:00Z]
  @end_of_year ~U[2025-12-31 23:59:59Z]

  def index(conn, _params) do
    user = conn.assigns.user

    token = share_token(user)

    global_new_user_count =
      Repo.one(
        from u in User,
          where: u.created_at >= ^@start_of_year and u.created_at <= ^@end_of_year,
          select: count()
      )

    global_images =
      Repo.one!(
        from s in "derped_global_images",
          select: map(s, [:count, :distinct_user_count])
      )

    global_comments =
      Repo.one!(
        from s in "derped_global_comments",
          select: map(s, [:count, :distinct_image_count, :distinct_user_count])
      )

    global_topics =
      Repo.one!(
        from s in "derped_global_topics",
          select: map(s, [:count, :distinct_user_count])
      ) || %{count: 0, distinct_user_count: 0}

    global_posts =
      Repo.one!(
        from s in "derped_global_posts",
          select: map(s, [:count, :distinct_topic_count, :distinct_user_count])
      )

    global_faves =
      Repo.one!(
        from s in "derped_global_faves",
          select: map(s, [:count, :distinct_image_count, :distinct_user_count])
      )

    global_votes =
      Repo.one!(
        from s in "derped_global_votes",
          select:
            map(s, [
              :total_count,
              :up_count,
              :down_count,
              :distinct_image_count,
              :distinct_user_count
            ])
      )

    global_tag_changes =
      Repo.one!(
        from s in "derped_global_tag_changes",
          select: map(s, [:count, :distinct_image_count])
      )

    global_source_changes =
      Repo.one!(
        from s in "derped_global_source_changes",
          select: map(s, [:count, :distinct_image_count])
      )

    global_reports =
      Repo.one!(
        from s in "derped_global_reports",
          select: map(s, [:count, :distinct_user_count])
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
          select: map(s, [:count, :distinct_image_count, :rank, :ntile])
      ) || %{count: 0, distinct_image_count: 0, rank: nil, ntile: nil}

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
          select: map(s, [:count, :distinct_topic_count, :rank, :ntile])
      ) || %{count: 0, distinct_topic_count: 0, rank: nil, ntile: nil}

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
          select: map(s, [:count, :distinct_image_count, :rank, :ntile])
      ) || %{count: 0, distinct_image_count: 0, rank: nil, ntile: nil}

    user_source_changes =
      Repo.one(
        from s in "derped_user_source_changes",
          where: s.user_id == ^user.id,
          select: map(s, [:count, :distinct_image_count, :rank, :ntile])
      ) || %{count: 0, distinct_image_count: 0, rank: nil, ntile: nil}

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

    render(
      conn,
      "index.html",
      title: "Derped #{@year} for User `#{user.name}'",
      token: token,
      global_new_user_count: global_new_user_count,
      global_images: global_images,
      global_comments: global_comments,
      global_topics: global_topics,
      global_posts: global_posts,
      global_faves: global_faves,
      global_votes: global_votes,
      global_tag_changes: global_tag_changes,
      global_source_changes: global_source_changes,
      global_reports: global_reports,
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
      user_top_faved_oc_tags: user_top_faved_oc_tags
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

      conn.params["token"] and conn.params["token"] == share_token(user) ->
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
