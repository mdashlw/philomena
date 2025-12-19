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

    global_new_image_count =
      Repo.one(
        from i in Image,
          where: i.created_at >= ^@start_of_year and i.created_at <= ^@end_of_year,
          select: count()
      )

    global_new_comments =
      Repo.one(
        from(
          from c in Comment,
            where: c.created_at >= ^@start_of_year and c.created_at <= ^@end_of_year,
            select: %{
              count: count(),
              image_count: count(c.image_id, :distinct)
            }
        )
      )

    global_new_topic_count =
      Repo.one(
        from t in Topic,
          where: t.created_at >= ^@start_of_year and t.created_at <= ^@end_of_year,
          select: count()
      )

    global_new_posts =
      Repo.one(
        from p in Post,
          where: p.created_at >= ^@start_of_year and p.created_at <= ^@end_of_year,
          select: %{
            count: count(),
            topic_count: count(p.topic_id, :distinct)
          }
      )

    global_new_image_fave_count =
      Repo.one(
        from f in ImageFave,
          where: f.created_at >= ^@start_of_year and f.created_at <= ^@end_of_year,
          select: count()
      )

    global_new_image_vote_count =
      Repo.one(
        from v in ImageVote,
          where: v.created_at >= ^@start_of_year and v.created_at <= ^@end_of_year,
          select: count()
      )

    global_new_tag_changes =
      Repo.one(
        from c in TagChange,
          where: c.created_at >= ^@start_of_year and c.created_at <= ^@end_of_year,
          select: %{
            count: count(),
            image_count: count(c.image_id, :distinct)
          }
      )

    global_new_source_changes =
      Repo.one(
        from c in SourceChange,
          where: c.created_at >= ^@start_of_year and c.created_at <= ^@end_of_year,
          select: %{
            count: count(),
            image_count: count(c.image_id, :distinct)
          }
      )

    global_new_report_count =
      Repo.one(
        from r in Report,
          where: r.created_at >= ^@start_of_year and r.created_at <= ^@end_of_year,
          select: count()
      )

    user_new_images =
      Repo.one(
        from i in Image,
          where:
            i.created_at >= ^@start_of_year and i.created_at <= ^@end_of_year and
              i.user_id == ^user.id,
          select: %{
            total_count: count(),
            anonymous_count: count() |> filter(i.anonymous)
          }
      )

    user_new_comments =
      Repo.one(
        from c in Comment,
          where:
            c.created_at >= ^@start_of_year and c.created_at <= ^@end_of_year and
              c.user_id == ^user.id,
          select: %{
            total_count: count(),
            anonymous_count: count() |> filter(c.anonymous),
            image_count: count(c.image_id, :distinct)
          }
      )

    user_new_fave_count =
      Repo.one(
        from f in ImageFave,
          where:
            f.created_at >= ^@start_of_year and f.created_at <= ^@end_of_year and
              f.user_id == ^user.id,
          select: count()
      )

    user_new_votes =
      Repo.one(
        from v in ImageVote,
          where:
            v.created_at >= ^@start_of_year and v.created_at <= ^@end_of_year and
              v.user_id == ^user.id,
          select: %{
            total_count: count(),
            up_count: count() |> filter(v.up),
            down_count: count() |> filter(not v.up)
          }
      )

    user_new_topic_count =
      Repo.one(
        from t in Topic,
          where:
            t.created_at >= ^@start_of_year and t.created_at <= ^@end_of_year and
              t.user_id == ^user.id,
          select: count()
      )

    user_new_posts =
      Repo.one(
        from p in Post,
          where:
            p.created_at >= ^@start_of_year and p.created_at <= ^@end_of_year and
              p.user_id == ^user.id,
          select: %{
            total_count: count(),
            anonymous_count: count() |> filter(p.anonymous),
            topic_count: count(p.topic_id, :distinct)
          }
      )

    user_new_tag_changes =
      Repo.one(
        from c in TagChange,
          where:
            c.created_at >= ^@start_of_year and c.created_at <= ^@end_of_year and
              c.user_id == ^user.id,
          select: %{
            count: count(),
            image_count: count(c.image_id, :distinct)
          }
      )

    user_new_source_changes =
      Repo.one(
        from c in SourceChange,
          where:
            c.created_at >= ^@start_of_year and c.created_at <= ^@end_of_year and
              c.user_id == ^user.id,
          select: %{
            count: count(),
            image_count: count(c.image_id, :distinct)
          }
      )

    user_new_reports =
      Repo.one(
        from r in Report,
          where:
            r.created_at >= ^@start_of_year and r.created_at <= ^@end_of_year and
              r.user_id == ^user.id,
          select: %{
            count: count(),
            avg_time:
              fragment(
                "COALESCE(?, 0::double precision)",
                avg(fragment("EXTRACT(EPOCH FROM ? - ?)", r.updated_at, r.created_at))
                |> filter(not r.open)
              )
          }
      )

    result =
      Repo.query!(
        "WITH stats AS
           (SELECT it.tag_id,
                   if.user_id,
                   count(*) AS faves,
                   dense_rank() OVER (PARTITION BY it.tag_id
                                      ORDER BY count(*) DESC) AS rank
            FROM image_faves IF
            JOIN image_taggings it ON it.image_id = if.image_id
            JOIN tags t ON t.id = it.tag_id
            WHERE if.created_at >= $1
              AND t.category = 'character'
            GROUP BY it.tag_id,
                     if.user_id)
         SELECT t.*,
                s.faves,
                s.rank
         FROM stats s
         JOIN tags t ON t.id = s.tag_id
         WHERE s.user_id = $3
         ORDER BY s.faves DESC
         FETCH FIRST 20 ROWS WITH TIES",
        [@start_of_year, user.id]
      )

    user_most_faved_character_tags =
      Enum.map(result.rows, fn row ->
        %{
          tag: Repo.load(Tag, {result.columns, row}),
          faves: Enum.at(row, Enum.find_index(result.columns, &(&1 == "faves"))),
          rank: Enum.at(row, Enum.find_index(result.columns, &(&1 == "rank")))
        }
      end)

    render(
      conn,
      "index.html",
      title: "Derped #{@year} for User `#{user.name}'",
      token: token,
      global_new_user_count: global_new_user_count,
      global_new_image_count: global_new_image_count,
      global_new_comments: global_new_comments,
      global_new_topic_count: global_new_topic_count,
      global_new_posts: global_new_posts,
      global_new_image_fave_count: global_new_image_fave_count,
      global_new_image_vote_count: global_new_image_vote_count,
      global_new_tag_changes: global_new_tag_changes,
      global_new_source_changes: global_new_source_changes,
      global_new_report_count: global_new_report_count,
      user_new_images: user_new_images,
      user_new_comments: user_new_comments,
      user_new_fave_count: user_new_fave_count,
      user_new_votes: user_new_votes,
      user_new_topic_count: user_new_topic_count,
      user_new_posts: user_new_posts,
      user_new_tag_changes: user_new_tag_changes,
      user_new_source_changes: user_new_source_changes,
      user_new_reports: user_new_reports,
      user_most_faved_character_tags: user_most_faved_character_tags
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
