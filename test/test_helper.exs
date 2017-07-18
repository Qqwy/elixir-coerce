ExUnit.start()

require Coerce
Coerce.defcoercion(Integer, BitString) do
  def coerce(int, string) do
    {inspect(int), string}
  end
end
