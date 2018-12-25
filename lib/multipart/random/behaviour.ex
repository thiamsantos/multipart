defmodule Multipart.Random.Behaviour do
  @callback random_boundary :: String.t()
end
