defmodule MultipartTest do
  use ExUnit.Case

  import Multipart

  test "simple test" do
    html_file = File.read!("test/fixtures/a.html")
    text_file = File.read!("test/fixtures/a.txt")
    binary_file = File.read!("test/fixtures/binary")

    actual =
      "-----------------------------2059697857808684979679937929"
      |> new_form()
      |> append_value("text1", "text default")
      |> append_value("text2", "aωb")
      |> append_file("file1", html_file, "a.html", "text/html")
      |> append_file("file2", text_file, "a.txt", "text/plain")
      |> append_file("file3", binary_file, "binary")
      |> encode_form()

    expected =
      "-----------------------------2059697857808684979679937929\r\n" <>
        "Content-Disposition: form-data; name=\"text1\"\r\n" <>
        "\r\n" <>
        "text default\r\n" <>
        "-----------------------------2059697857808684979679937929\r\n" <>
        "Content-Disposition: form-data; name=\"text2\"\r\n" <>
        "\r\n" <>
        "aωb\r\n" <>
        "-----------------------------2059697857808684979679937929\r\n" <>
        "Content-Disposition: form-data; name=\"file1\"; filename=\"a.html\"\r\n" <>
        "Content-Type: text/html\r\n" <>
        "\r\n" <>
        "<!DOCTYPE html><title>Content of a.html.</title>\r\n" <>
        "-----------------------------2059697857808684979679937929\r\n" <>
        "Content-Disposition: form-data; name=\"file2\"; filename=\"a.txt\"\r\n" <>
        "Content-Type: text/plain\r\n" <>
        "\r\n" <>
        "Content of a.txt.\r\n" <>
        "-----------------------------2059697857808684979679937929\r\n" <>
        "Content-Disposition: form-data; name=\"file3\"; filename=\"binary\"\r\n" <>
        "Content-Type: application/octet-stream\r\n" <>
        "\r\n" <> "aωb\r\n" <> "-----------------------------2059697857808684979679937929--"

    assert actual == expected
  end
end
