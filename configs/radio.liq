set("harbor.bind_addr", "0.0.0.0")

silence = blank()

autodj = playlist(
  "/home/container/music",
  reload_mode="watch"
)

live = input.harbor(
  "live",
  port=8001,
  password="livepassword",
  user="source"
)

source_chain = fallback(
  track_sensitive=false,
  [live, autodj, silence]
)

radio = nrj(source_chain)

output.icecast(
  %mp3(
    bitrate=320
  ),
  host="localhost",
  port=8000,
  user="source",
  password="sourcepassword",
  mount="stream",
  name="Stream name",
  radio
)
