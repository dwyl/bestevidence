defmodule Bep.SearchView do
  use Bep.Web, :view
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
    ~s{<script>require("web/static/js/results_lazy_loading")</script>}
    <> ~s{<script>require("web/static/js/results_filter")</script>}
    |> raw
  end

 defp colour_evidence_format(int) when int == 0, do: "b--white"
 defp colour_evidence_format(int), do: "b--evidence-#{int}"

 def colour_evidence(type), do: format_class(type, &colour_evidence_format/1)
end
