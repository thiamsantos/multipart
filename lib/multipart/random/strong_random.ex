defmodule Multipart.Random.StrongRandom do
  @behaviour Multipart.Random.Behaviour

  def random_boundary do
    rand_bytes =
      16
      |> :crypto.strong_rand_bytes()
      |> Base.encode16()

    "----------------------------#{rand_bytes}"
  end
end
