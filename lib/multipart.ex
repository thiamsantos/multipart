defmodule Multipart do
  defmodule FormData do
    keys = [:boundary, :parts]
    @enforce_keys keys
    defstruct keys

    @type t :: %__MODULE__{
            boundary: String.t(),
            parts: [Multipart.FilePart.t() | Multipart.ValuePart.t()]
          }
  end

  defmodule FilePart do
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

  defmodule ValuePart do
    keys = [:name, :value]
    @enforce_keys keys
    defstruct keys

    @type t :: %__MODULE__{name: String.t(), value: String.t()}
  end

  @spec new_form(String.t()) :: FormData.t()
  def new_form(boundary \\ random_boundary()) when is_binary(boundary) do
    %FormData{boundary: boundary, parts: []}
  end

  @spec append_file(FormData.t(), String.t(), String.t(), String.t(), String.t()) :: FormData.t()
  def append_file(
        %FormData{parts: parts} = form_data,
        name,
        value,
        filename,
        content_type \\ "application/octet-stream"
      )
      when is_binary(name) and is_binary(value) and is_binary(filename) and
             is_binary(content_type) do
    file_part = %FilePart{
      name: name,
      value: value,
      filename: filename,
      content_type: content_type
    }

    %{form_data | parts: [file_part | parts]}
  end

  @spec append_value(FormData.t(), String.t(), String.t()) :: FormData.t()
  def append_value(%FormData{parts: parts} = form_data, name, value)
      when is_binary(name) and is_binary(value) do
    value_part = %ValuePart{name: name, value: value}
    %{form_data | parts: [value_part | parts]}
  end

  @spec with_boundary(FormData.t(), String.t()) :: FormData.t()
  def with_boundary(%FormData{} = form_data, boundary) when is_binary(boundary) do
    %{form_data | boundary: boundary}
  end

  @spec encode_form(FormData.t()) :: String.t()
  def encode_form(%FormData{parts: parts, boundary: boundary}) do
    parts
    |> Enum.reverse()
    |> Enum.map(&encode_part/1)
    |> Enum.join(boundary <> "\r\n")
    |> prepend(boundary <> "\r\n")
    |> append(boundary <> "--")
  end

  defp encode_part(%FilePart{} = file_part) do
    %FilePart{name: name, value: value, filename: filename, content_type: content_type} =
      file_part

    "Content-Disposition: form-data; name=\"#{name}\"; filename=\"#{filename}\"\r\n" <>
      "Content-Type: #{content_type}\r\n" <> "\r\n" <> "#{value}\r\n"
  end

  defp encode_part(%ValuePart{} = value_part) do
    %ValuePart{name: name, value: value} = value_part

    "Content-Disposition: form-data; name=\"#{name}\"\r\n" <> "\r\n" <> "#{value}\r\n"
  end

  @spec random_boundary :: String.t()
  def random_boundary do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16()
    |> prepend("-----------------------------")
  end

  defp append(acc, value) do
    acc <> value
  end

  defp prepend(acc, value) do
    value <> acc
  end
end
