defmodule SantayanaTest.TrialsTest do
	alias Santayana.Trials, as: Trials
  use ExUnit.Case
  doctest Santayana

	# Fixed value Trials

	test "No values" do
		assert Trials.predictor(20,[0,0,0,0],[]) == [20]
	end

  test "Zero Weighted predictions" do
    res = Trials.predictor(20,[0,0,0,0],[[1,2,3,4],[5,6,7,8],[9,10,11,12]])
		assert res == [20, 20, 20, 20]
  end

  test "Just passive" do
    res = Trials.predictor(20,[0,0,0,0.5],[[1,2,3,18],[5,6,7,18],[9,10,11,18]])
		assert res == [20, 19.0, 18.5, 18.25]
  end

  test "Just AHU" do
    res = Trials.predictor(20,[0.5,0,0,0],[[18,16,17,18],[18,16,17,18],[18,16,17,18]])
		assert res == [20, 19.0, 18.5, 18.25]
  end

  test "Multiple weights" do
    res = Trials.predictor(20,[0.01,0.03,0.03,0.1],[[18,16,17,18],[18,16,17,18],[18,16,17,18]])
		assert res == [20, 19.57, 19.2131, 18.916873]
  end	

end
