defmodule Bep.SearchView do
  use Bep.Web, :view
  @classes "fixed bg-white vh-75-s w-100 w-25-ns ml6-ns dn pt1 pb3 pb0-ns shadow-1-ns "

  defp format_class(type, format_string) do
    cond do
      type in [1, 4, 9, 10, 11, 16, 18, 34] -> format_string.(1)
      type == 13 -> format_string.(2)
      type == 2 -> format_string.(3)
      type in [27, 14] -> format_string.(4)
      type in [5, 8, 22, 29, 30, 35] -> format_string.(5)
      true -> format_string.(0)
    end
  end

  defp pyramid_logo_format(int) when int == 0, do: ""
  defp pyramid_logo_format(int), do: "pyramid-grade#{int}.svg"

  def pyramid_logo(type), do: format_class(type, &pyramid_logo_format/1)

  def render("scripts.results.html", _assigns) do
    ~s{<script>require("web/static/js/results_filter")</script>}
    <> ~s{<script>require("web/static/js/evidence_socket")</script>}
    |> raw
  end

 defp colour_evidence_format(int) when int == 0, do: "b--white"
 defp colour_evidence_format(int), do: "b--evidence-#{int}"

 @doc"""
   iex>colour_evidence(0)
   "b--white"
   iex>colour_evidence(22)
   "b--evidence-5"
 """
 def colour_evidence(type), do: format_class(type, &colour_evidence_format/1)

 def get_year_from_date(date) do
     case Timex.parse(date, "{RFC1123}") do
       {:ok, parsed_date} -> parsed_date.year
       {:error, _error} -> ""
     end
 end

 def search_res_class_helper(search) do
   str =
     if search.uncertainty do
       "top-4-plus top-6-ns"
     else
       "top-4 top-5-ns"
     end

    @classes <> str
 end
end
