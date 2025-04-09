defmodule PhilomenaWeb.Profile.VoteController do
  use PhilomenaWeb, :controller

  alias Philomena.Users.User
  alias Philomena.Repo
  alias Philomena.ImageFaves.ImageFave
  alias Philomena.ImageVotes.ImageVote
  alias Philomena.ImageHides.ImageHide
  alias Philomena.Tags.Tag
  import Ecto.Query

  plug :load_resource,
    model: User,
    id_field: "slug",
    id_name: "profile_id",
    persisted: true

  plug :verify_authorized

  def index(conn, _params) do
    user = conn.assigns.user

    # limit = 1000

    faves =
      from(
        fave in ImageFave,
        where: fave.user_id == ^user.id,
        join: image in assoc(fave, :image),
        join: tag in assoc(image, :tags),
        group_by: tag.id,
        select: %{
          tag: tag,
          faves: count()
        }
      )
      |> Repo.all()

    hides =
      from(
        hide in ImageHide,
        where: hide.user_id == ^user.id,
        join: image in assoc(hide, :image),
        join: tag in assoc(image, :tags),
        group_by: tag.id,
        select: %{
          tag: tag,
          hides: count()
        }
      )
      |> Repo.all()

    votes =
      from(
        vote in ImageVote,
        where: vote.user_id == ^user.id,
        join: image in assoc(vote, :image),
        join: tag in assoc(image, :tags),
        group_by: tag.id,
        select: %{
          tag: tag,
          upvotes: count() |> filter(vote.up),
          downvotes: count() |> filter(not vote.up)
        }
      )
      |> Repo.all()

    fave_map = Map.new(faves, &{&1.tag, &1.faves})
    hide_map = Map.new(hides, &{&1.tag, &1.hides})
    up_map = Map.new(votes, &{&1.tag, &1.upvotes})
    down_map = Map.new(votes, &{&1.tag, &1.downvotes})

    defaults = %{
      faves: 0,
      upvotes: 0,
      downvotes: 0,
      hides: 0
    }

    tags =
      Enum.flat_map([faves, votes, hides], fn list -> Enum.map(list, & &1.tag) end)
      |> Enum.uniq()
      |> Enum.map(fn tag ->
        %{
          tag: tag,
          faves: Map.get(fave_map, tag, 0),
          hides: Map.get(hide_map, tag, 0),
          up: Map.get(up_map, tag, 0),
          down: Map.get(down_map, tag, 0)
        }
      end)

    # faves =
    #   from(
    #     fave in ImageFave,
    #     where: fave.user_id == ^user.id,
    #     join: image in assoc(fave, :image),
    #     join: tag in assoc(image, :tags),
    #     group_by: tag.id,
    #     select: %{
    #       tag: tag,
    #       count: selected_as(count(), :count)
    #     },
    #     order_by: [desc: selected_as(:count)],
    #     limit: ^limit
    #   )
    #   |> Repo.all()

    # upvotes =
    #   from(
    #     vote in ImageVote,
    #     where: vote.up and vote.user_id == ^user.id,
    #     join: image in assoc(vote, :image),
    #     join: tag in assoc(image, :tags),
    #     group_by: tag.id,
    #     select: %{
    #       tag: tag,
    #       count: selected_as(count(), :count)
    #     },
    #     order_by: [desc: selected_as(:count)],
    #     limit: ^limit
    #   )
    #   |> Repo.all()

    # downvotes =
    #   from(
    #     vote in ImageVote,
    #     where: not vote.up and vote.user_id == ^user.id,
    #     join: image in assoc(vote, :image),
    #     join: tag in assoc(image, :tags),
    #     group_by: tag.id,
    #     select: %{
    #       tag: tag,
    #       count: selected_as(count(), :count)
    #     },
    #     order_by: [desc: selected_as(:count)],
    #     limit: ^limit
    #   )
    #   |> Repo.all()

    # downvotes_minus_upvotes =
    #   from(
    #     vote in ImageVote,
    #     where: vote.user_id == ^user.id,
    #     join: image in assoc(vote, :image),
    #     join: tag in assoc(image, :tags),
    #     group_by: tag.id,
    #     having: filter(count(), not vote.up) > filter(count(), vote.up),
    #     select: %{
    #       tag: tag,
    #       count:
    #         selected_as(
    #           filter(count(), not vote.up) - filter(count(), vote.up),
    #           :count
    #         )
    #     },
    #     order_by: [desc: selected_as(:count)],
    #     limit: ^limit
    #   )
    #   |> Repo.all()

    # hides =
    #   from(
    #     hide in ImageHide,
    #     where: hide.user_id == ^user.id,
    #     join: image in assoc(hide, :image),
    #     join: tag in assoc(image, :tags),
    #     group_by: tag.id,
    #     select: %{
    #       tag: tag,
    #       count: selected_as(count(), :count)
    #     },
    #     order_by: [desc: selected_as(:count)],
    #     limit: ^limit
    #   )
    #   |> Repo.all()

    render(conn, "index.html",
      title: "Vote Stats for User '#{user.name}'",
      # faves: faves,
      # upvotes: upvotes,
      # downvotes: downvotes,
      # downvotes_minus_upvotes: downvotes_minus_upvotes,
      # hides: hides,
      tag_stats: tags
      # layout_class: "layout--wide"
    )
  end

  defp verify_authorized(conn, _opts) do
    user_id = conn.assigns.user.id

    case conn.assigns.current_user do
      %{id: ^user_id} -> conn
      %{role: role} when role in ~W(moderator admin) -> conn
      _other -> PhilomenaWeb.NotAuthorizedPlug.call(conn)
    end
  end
end
