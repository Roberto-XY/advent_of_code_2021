defmodule ComputeCore do
  use Rustler, otp_app: :advent_of_code, crate: "compute_core"

  # When your NIF is loaded, it will override this function.
  def add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
end
