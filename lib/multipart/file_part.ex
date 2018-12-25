defmodule Multipart.FilePart do
  keys = [:name, :value, :filename, :content_type]
  @enforce_keys keys
  defstruct keys

  @type t :: %__MODULE__{
          name: String.t(),
          value: String.t(),
          filename: String.t(),
          content_type: String.t()
        }
end

defimpl Multipart.PartEncoder, for: Multipart.FilePart do
  require EEx

  EEx.function_from_string(
    :def,
    :encode,
    ~s(Content-Disposition: form-data; name="<%= part.name %>"; filename="<%= part.filename %>"\r\nContent-Type: <%= part.content_type %>\r\n\r\n<%= part.value %>\r\n),
    [:part]
  )
end
