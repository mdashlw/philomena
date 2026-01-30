defmodule PhilomenaMedia.Processors.Jpeg do
  @moduledoc false

  alias PhilomenaMedia.Intensities
  alias PhilomenaMedia.Analyzers.Result
  alias PhilomenaMedia.Remote
  alias PhilomenaMedia.Processors.Processor
  alias PhilomenaMedia.Processors

  @behaviour Processor

  @exit_success 0
  @exit_warning 2

  # Lazy-loaded sRGB profile for comparison
  @srgb_profile_path Path.join(File.cwd!(), "priv/icc/sRGB.icc")

  @spec versions(Processors.version_list()) :: [Processors.version_filename()]
  def versions(sizes) do
    Enum.map(sizes, fn {name, _} -> "#{name}.jpg" end)
  end

  @spec process(Result.t(), Path.t(), Processors.version_list()) :: Processors.edit_script()
  def process(_analysis, file, versions) do
    stripped = optimize(strip(file))

    {:ok, intensities} = Intensities.file(stripped)

    scaled = Enum.flat_map(versions, &scale(stripped, &1))

    [
      replace_original: stripped,
      intensities: intensities,
      thumbnails: scaled
    ]
  end

  @spec post_process(Result.t(), Path.t()) :: Processors.edit_script()
  def post_process(_analysis, _file), do: []

  @spec intensities(Result.t(), Path.t()) :: Intensities.t()
  def intensities(_analysis, file) do
    {:ok, intensities} = Intensities.file(file)
    intensities
  end

  defp requires_lossy_transformation?(file) do
    with {output, 0} <-
           Remote.cmd("magick", ["identify", "-format", "%[orientation]\t%[profile:icc]", file]),
         [orientation, profile] <- String.split(output, "\t") do
      needs_orientation_fix = orientation not in ["Undefined", "TopLeft"]

      # If no profile exists, no color conversion needed
      # If profile exists but is sRGB, we can strip it without re-encoding
      needs_color_conversion = profile != "" and not is_srgb_profile?(file)

      needs_orientation_fix or needs_color_conversion
    else
      _ ->
        true
    end
  end

  # Check if the embedded ICC profile is sRGB by comparing with our reference profile
  # or by checking the profile description
  defp is_srgb_profile?(file) do
    # First, try to match the profile by byte comparison with our sRGB profile
    case extract_icc_profile(file) do
      {:ok, embedded_profile} ->
        case File.read(@srgb_profile_path) do
          {:ok, reference_profile} ->
            if embedded_profile == reference_profile do
              true
            else
              # Fallback: check if profile description contains "sRGB"
              profile_description_is_srgb?(file)
            end

          {:error, _} ->
            # Can't read reference profile, fall back to description check
            profile_description_is_srgb?(file)
        end

      :error ->
        # Can't extract profile, fall back to description check
        profile_description_is_srgb?(file)
    end
  end

  # Extract the raw ICC profile bytes from a JPEG file
  defp extract_icc_profile(file) do
    # Use ImageMagick to extract the ICC profile to stdout
    # The "icc:-" output writes the raw profile bytes to stdout
    case Remote.cmd("magick", [file, "icc:-"]) do
      {profile_data, 0} when byte_size(profile_data) > 0 ->
        {:ok, profile_data}

      _ ->
        :error
    end
  end

  # Check if the ICC profile description indicates sRGB
  defp profile_description_is_srgb?(file) do
    case Remote.cmd("magick", ["identify", "-format", "%[icc:description]", file]) do
      {description, 0} ->
        description
        |> String.downcase()
        |> String.contains?("srgb")

      _ ->
        false
    end
  end

  defp strip(file) do
    stripped = Briefly.create!(extname: ".jpg")

    # ImageMagick always reencodes the image, resulting in quality loss, so
    # be more clever
    if requires_lossy_transformation?(file) do
      # Transcode: strip EXIF, embedded profile and reorient image
      {_output, 0} =
        Remote.cmd("magick", [
          file,
          "-profile",
          srgb_profile(),
          "-auto-orient",
          "-strip",
          stripped
        ])
    else
      # Transmux only: Strip EXIF without touching orientation
      validate_return(Remote.cmd("jpegtran", ["-copy", "none", "-outfile", stripped, file]))
    end

    stripped
  end

  defp optimize(file) do
    optimized = Briefly.create!(extname: ".jpg")

    validate_return(Remote.cmd("jpegtran", ["-optimize", "-outfile", optimized, file]))

    optimized
  end

  defp scale(file, {thumb_name, {width, height}}) do
    scaled = Briefly.create!(extname: ".jpg")
    scale_filter = "scale=w=#{width}:h=#{height}:force_original_aspect_ratio=decrease"

    {_output, 0} =
      Remote.cmd("ffmpeg", [
        "-loglevel",
        "0",
        "-y",
        "-i",
        file,
        "-vf",
        scale_filter,
        "-q:v",
        "1",
        scaled
      ])

    {_output, 0} = Remote.cmd("jpegtran", ["-optimize", "-outfile", scaled, scaled])

    [{:copy, scaled, "#{thumb_name}.jpg"}]
  end

  defp srgb_profile do
    @srgb_profile_path
  end

  defp validate_return({_output, ret}) when ret in [@exit_success, @exit_warning] do
    :ok
  end
end
