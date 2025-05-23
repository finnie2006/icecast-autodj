let port = __PORT__

et("harbor.bind_addr", "0.0.0.0")

silence = blank()

autodj = playlist(
  "/home/container/music",
  reload_mode="watch"
)

live = input.harbor(
  "live",
  port=port + 1,
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
  port=port,
  user="source",
  password="sourcepassword",
  mount="stream",
  name="Stream name",
  radio
)
