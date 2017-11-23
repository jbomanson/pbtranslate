struct PBTranslate::Network::Empty
  INSTANCE = new

  {% for message_and_type in [
      {:network_depth, Distance},
      {:network_width, Distance},
      {:network_write_count, Area},
  ] %}
    def {{message_and_type[0].id}} : {{message_and_type[1]}}
      {{message_and_type[1]}}.new(0)
    end
  {% end %}

  def host(visitor) : Nil
  end
end
