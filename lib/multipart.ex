defmodule Multipart do
  alias Multipart.{FilePart, ValuePart, FormData, PartEncoder}

  @random_adapter Application.fetch_env!(:multipart, :random_adapter)

  @spec random_boundary :: String.t()
  defdelegate random_boundary, to: @random_adapter

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
    |> Enum.map(&PartEncoder.encode/1)
    |> Enum.join(boundary <> "\r\n")
    |> prepend(boundary <> "\r\n")
    |> append(boundary <> "--")
  end

  defp append(acc, value) do
    acc <> value
  end

  defp prepend(acc, value) do
    value <> acc
  end
end
