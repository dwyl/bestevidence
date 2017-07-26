defmodule Bep.SearchView do
  use Bep.Web, :view
  def colour_evidence(type) do
    cond do
      Enum.member?([1, 4, 9, 10, 11, 16, 18, 34], type) -> "b--evidence-1"
      type == 13 -> "b--evidence-2"
      type == 2 -> "b--evidence-3"
      Enum.member?([27, 14], type) -> "b--evidence-4"
      Enum.member?([5, 8, 22, 29, 30, 35], type) -> "b--evidence-5"
      true -> "b--white"
    end
  end

  def pyramid_logo(type) do
    cond do
      Enum.member?([1, 4, 9, 10, 11, 16, 18, 34], type) -> "pyramid-grade1.svg"
      type == 13 -> "pyramid-grade2.svg"
      type == 2 -> "pyramid-grade3.svg"
      Enum.member?([27, 14], type) -> "pyramid-grade4.svg"
      Enum.member?([5, 8, 22, 29, 30, 35], type) -> "pyramid-grade5.svg"
      true -> ""
    end
  end
end
