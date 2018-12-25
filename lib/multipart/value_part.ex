defmodule Multipart.ValuePart do
  keys = [:name, :value]
  @enforce_keys keys
  defstruct keys

  @type t :: %__MODULE__{name: String.t(), value: String.t()}
end

defimpl Multipart.PartEncoder, for: Multipart.ValuePart do
  require EEx

  EEx.function_from_string(
    :def,
    :encode,
    ~s(Content-Disposition: form-data; name="<%= part.name %>"\r\n\r\n<%= part.value %>\r\n),
    [:part]
  )
end
