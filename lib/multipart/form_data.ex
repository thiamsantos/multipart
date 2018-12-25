defmodule Multipart.FormData do
  keys = [:boundary, :parts]
  @enforce_keys keys
  defstruct keys

  @type t :: %__MODULE__{
          boundary: String.t(),
          parts: list()
        }
end
