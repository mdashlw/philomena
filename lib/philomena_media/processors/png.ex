defmodule PhilomenaMedia.Processors.Png do
  @moduledoc false

  alias PhilomenaMedia.Intensities
  alias PhilomenaMedia.Analyzers.Result
  alias PhilomenaMedia.Remote
  alias PhilomenaMedia.Processors.Processor
  alias PhilomenaMedia.Processors

  @behaviour Processor

  @spec versions(Processors.version_list()) :: [Processors.version_filename()]
  def versions(sizes) do
    Enum.map(sizes, fn {name, _} -> "#{name}.png" end)
  end

  @spec process(Result.t(), Path.t(), Processors.version_list()) :: Processors.edit_script()
  def process(analysis, file, versions) do
    animated? = analysis.animated?

    # For non-animated PNGs, strip ICC profile and convert to sRGB if needed
    # Skip for animated PNGs since ImageMagick may not handle them well
    {working_file, replace_original} =
      if animated? do
        {file, []}
      else
        stripped = strip(file)
        {stripped, [replace_original: stripped]}
      end

    {:ok, intensities} = Intensities.file(working_file)

    scaled = Enum.flat_map(versions, &scale(working_file, animated?, &1))

    replace_original ++
      [
        intensities: intensities,
        thumbnails: scaled
      ]
  end

  @spec post_process(Result.t(), Path.t()) :: Processors.edit_script()
  def post_process(analysis, file) do
    if analysis.animated? do
      # libpng has trouble with animations, so skip optimization
      []
    else
      [replace_original: optimize(file)]
    end
  end

  @spec intensities(Result.t(), Path.t()) :: Intensities.t()
  def intensities(_analysis, file) do
    {:ok, intensities} = Intensities.file(file)
    intensities
  end

  defp has_icc_profile?(file) do
    case Remote.cmd("magick", ["identify", "-format", "%[profile:icc]", file]) do
      {output, 0} ->
        String.trim(output) != ""

      _ ->
        # Assume no profile if we can't check
        false
    end
  end

  defp strip(file) do
    stripped = Briefly.create!(extname: ".png")

    if has_icc_profile?(file) do
      # Convert ICC profile to sRGB and strip metadata
      {_output, 0} =
        Remote.cmd("magick", [
          file,
          "-profile",
          srgb_profile(),
          "-strip",
          stripped
        ])
    else
      # No ICC profile, just copy the file as-is
      File.cp!(file, stripped)
    end

    stripped
  end

  # Sobelow misidentifies removing the .bak file
  # sobelow_skip ["Traversal.FileModule"]
  defp optimize(file) do
    optimized = Briefly.create!(extname: ".png")

    {_output, 0} =
      Remote.cmd("optipng", ["-fix", "-i0", "-o2", "-quiet", "-clobber", file, "-out", optimized])

    # Remove useless .bak file
    File.rm(optimized <> ".bak")

    optimized
  end

  defp srgb_profile do
    Path.join(File.cwd!(), "priv/icc/sRGB.icc")
  end

  defp scale(file, animated?, {thumb_name, {width, height}}) do
    scaled = Briefly.create!(extname: ".png")

    scale_filter =
      "scale=w=#{width}:h=#{height}:force_original_aspect_ratio=decrease,format=rgb32"

    {_output, 0} =
      if animated? do
        Remote.cmd("ffmpeg", [
          "-loglevel",
          "0",
          "-y",
          "-i",
          file,
          "-plays",
          "0",
          "-vf",
          scale_filter,
          "-f",
          "apng",
          scaled
        ])
      else
        Remote.cmd("ffmpeg", ["-loglevel", "0", "-y", "-i", file, "-vf", scale_filter, scaled])
      end

    Remote.cmd("optipng", ["-i0", "-o1", "-quiet", "-clobber", scaled])

    [{:copy, scaled, "#{thumb_name}.png"}]
  end
end
