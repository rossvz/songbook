defmodule SongbookWeb.ShowLive.FormComponent do
  @moduledoc false
  use SongbookWeb, :live_component

  alias Songbook.Music

  @impl true
  def update(%{show: show} = assigns, socket) do
    form =
      if show.id do
        AshPhoenix.Form.for_update(show, :update,
          domain: Music,
          as: "show"
        )
      else
        AshPhoenix.Form.for_create(Music.Show, :create,
          domain: Music,
          as: "show"
        )
      end
      |> to_form()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, form)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@page_title}
        <:subtitle>Fill in the show details below</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="show-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:date]} type="date" label="Date" required />
        <.input field={@form[:time]} type="text" label="Time" placeholder="8:00 PM" />
        <.input
          field={@form[:venue]}
          type="text"
          label="Venue"
          required
          phx-hook="PlacesAutocomplete"
          id="venue-autocomplete"
        />
        <.input field={@form[:latitude]} type="hidden" />
        <.input field={@form[:longitude]} type="hidden" />

        <:actions>
          <.button phx-disable-with="Saving..." class="bg-zinc-900 hover:bg-zinc-700">
            Save Show
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def handle_event("place_selected", %{"venue" => venue, "latitude" => lat, "longitude" => lng}, socket) do
    # Update the form with the place data
    form =
      socket.assigns.form.source
      |> AshPhoenix.Form.validate(%{
        "venue" => venue,
        "latitude" => lat,
        "longitude" => lng
      })
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("validate", %{"show" => show_params}, socket) do
    form =
      socket.assigns.form.source
      |> AshPhoenix.Form.validate(show_params)
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("save", %{"show" => show_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form.source, params: show_params) do
      {:ok, show} ->
        notify_parent({:saved, show})

        {:noreply,
         socket
         |> put_flash(:info, "Show #{if socket.assigns.show.id, do: "updated", else: "created"} successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, form} ->
        {:noreply, assign(socket, :form, to_form(form))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
