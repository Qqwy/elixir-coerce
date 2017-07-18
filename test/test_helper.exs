ExUnit.start()

require Coerce.Define
Coerce.Define.defcoercion(Integer, BitString) do
  def coerce(int, string) do
    {inspect(int), string}
  end
end
