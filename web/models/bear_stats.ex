defmodule Bep.BearStat do
  use Bep.Web, :model
  alias Bep.{PicoSearch, Publication}
  
  @moduledoc false

  schema "bear_stats" do
    belongs_to :publication, Publication
    belongs_to :pico_search, PicoSearch
    field :index, :integer
    field :arr_mid, :string
    field :arr_low, :string
    field :arr_high, :string
    field :rr_mid, :string
    field :rr_low, :string
    field :rr_high, :string
    field :rrr_mid, :string
    field :rrr_low, :string
    field :rrr_high, :string
    field :or_mid, :string
    field :or_low, :string
    field :or_high, :string
    field :nnt_mid, :string
    field :nnt_low, :string
    field :nnt_high, :string
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [
        :index,
        :arr_mid,
        :arr_low,
        :arr_high,
        :rr_mid,
        :rr_low,
        :rr_high,
        :rrr_mid,
        :rrr_low,
        :rrr_high,
        :or_mid,
        :or_low,
        :or_high,
        :nnt_mid,
        :nnt_low,
        :nnt_high,
      ])
    # |> validate_required([:index, :arr_mid, :arr_low, :arr_high])
  end
end
