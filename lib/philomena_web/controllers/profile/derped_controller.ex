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
  alias Philomena.Repo
  import Ecto.Query

  plug :load_and_authorize_resource,
    model: User,
    id_field: "slug",
    id_name: "profile_id",
    persisted: true

  plug :verify_authorized

  @year 2025
  @start_of_year ~D[2025-01-01]
  @end_of_year ~D[2025-12-31]

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

    global_new_comment_count =
      Repo.one(
        from(
          from c in Comment,
            where: c.created_at >= ^@start_of_year and c.created_at <= ^@end_of_year,
            select: count()
        )
      )

    global_new_topic_count =
      Repo.one(
        from t in Topic,
          where: t.created_at >= ^@start_of_year and t.created_at <= ^@end_of_year,
          select: count()
      )

    global_new_post_count =
      Repo.one(
        from p in Post,
          where: p.created_at >= ^@start_of_year and p.created_at <= ^@end_of_year,
          select: count()
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

    global_new_tag_change_count =
      Repo.one(
        from c in TagChange,
          where: c.created_at >= ^@start_of_year and c.created_at <= ^@end_of_year,
          select: count()
      )

    global_new_source_change_count =
      Repo.one(
        from c in SourceChange,
          where: c.created_at >= ^@start_of_year and c.created_at <= ^@end_of_year,
          select: count()
      )

    global_new_report_count =
      Repo.one(
        from r in Report,
          where: r.created_at >= ^@start_of_year and r.created_at <= ^@end_of_year,
          select: count()
      )

    render(
      conn,
      "index.html",
      title: "Derped #{@year} for User `#{user.name}'",
      token: token,
      global_new_user_count: global_new_user_count,
      global_new_image_count: global_new_image_count,
      global_new_comment_count: global_new_comment_count,
      global_new_topic_count: global_new_topic_count,
      global_new_post_count: global_new_post_count,
      global_new_image_fave_count: global_new_image_fave_count,
      global_new_image_vote_count: global_new_image_vote_count,
      global_new_tag_change_count: global_new_tag_change_count,
      global_new_source_change_count: global_new_source_change_count,
      global_new_report_count: global_new_report_count
    )
  end

  defp verify_authorized(conn, _opts) do
    target = conn.assigns.user
    current = conn.assigns.current_user

    cond do
      match?(%{id: ^target.id}, current) ->
        conn

      match?(%{role: role} when role in ~w(moderator admin), current) ->
        conn

      match?(%{"token" => share_token(target)}, conn.params) ->
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
        4
      )

    token
  end
end
