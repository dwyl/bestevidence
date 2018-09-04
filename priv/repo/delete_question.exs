alias Bep.{BearQuestion, Repo}
import Ecto.Query

# Created this function to allow a dev to easily and safely delete a question
# from the datebase.
# The reason I chose to create the function this way it to minimise the chance
# of the wrong question being deleted from the database
# (open to suggestions/improvements)

# If you need to delete a question from the database, also delete the question
# from `bestevidence/web/models/bear_questions.ex`

# Make sure to test removing a question locally before deleting from production
# As removing a question could have effect on BEAR form

delete_question = fn() ->
  IO.puts("Enter the section first and then the question you wish to delete")
  IO.puts("They need to be done in the following way...")
  IO.puts("section name///question text")
  IO.puts("Then press enter. \n")

  [section_str, question_str] =
    "Enter section name followed by /// and then the question, as shown above. \n>"
    |> IO.gets()
    |> String.split("///")

  question_str = String.replace(question_str, "\n", "")

  query =
    from b in BearQuestion,
    where: b.section == ^section_str and b.question == ^question_str

  query
  |> Repo.one!()
  |> Repo.delete!()
end

delete_question.()
