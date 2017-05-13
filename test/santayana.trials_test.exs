defmodule SantayanaTest.TrialsTest do
	alias Santayana.Trials, as: Trials
	alias Santayana.DataImport, as: Data
  use ExUnit.Case
  doctest Santayana

	# Fixed value Trials

	test "No values" do
		assert Trials.predictor(20,[0,0,0],[]) == [20]
	end

  test "Zero Weighted predictions" do
    res = Trials.predictor(20,[0,0,0],[[1,2,3,4],[5,6,7,8],[9,10,11,12]])
		assert res == [20, 20, 20, 20]
  end

  test "Just passive" do
    res = Trials.predictor(20,[0.5,0,0],[[18,1,2],[18,3,4],[18,5,6]])
		assert res == [20, 19.0, 18.5, 18.25]
  end

  test "Just AHU" do
    res = Trials.predictor(20,[0,0.5,0],[[18,16,17,18],[18,16,17,18],[18,16,17,18]])
		assert res == [20, 18, 17, 16.5]
  end

  test "Multiple weights" do
    res = Trials.predictor(20,[0.01,0.03,0.03],[[18,16,17,18],[18,16,17,18],[18,16,17,18]])
		assert res == [20, 19.77, 19.556099999999997, 19.357172999999996]
  end	

	# Live value trials
	defp dataset() do
		data = Data.get_multiple(["BMS-L11O42S21","BMS-L1O11S55","BMS-L1O14S28"],Data.parsetime("2017-05-09T00:00:00"),Data.parsetime("2017-05-09T01:30:00"))
		Enum.map(data,fn({_datetime,d}) -> Enum.map(d, fn(dd) -> elem(Float.parse(dd),0) end) end)
	end

	test "Predict values from real data" do
		data = dataset()
		# hd(data) is the room temp, the other two are Atrium temps
		res = Trials.predictor(hd(hd(data)),[0.01,0.1],Enum.map(tl(data), &tl(&1)))
		expected = Enum.map(tl(data),&hd(&1))
		errors = Trials.errors(res,expected)
		assert Enum.all?(errors, fn(e) -> e < 10 end) 
		assert Trials.ave_error(res, expected) < 10
	end

end
