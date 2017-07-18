ExUnit.start()

require Coerce
Coerce.defcoercion(Integer, String) do
  def coerce(int, string) do
    {inspect(int), string}
  end
end
