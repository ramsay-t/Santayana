defmodule SantayanaTest.GeneticsTest do
	alias Santayana.Trials, as: Trials
	alias Santayana.DataImport, as: Data
	alias Santayana.Genetics, as: Genetics
  use ExUnit.Case
  doctest Santayana

	# This is actually just a synonym for running the predictor, but we will use it to make the "right" answer
	defp make_vals(ic,ks,is) do
		Trials.predictor(ic,ks,is)
	end

	test "Simple relationship" do
		testinputs = [[1,10,10],[2,919,828],[3,882,19],[4,919,-6],[5,5,5],[6,6,6],[7,7,7],[8,99,0]]
		truevals = make_vals(20,[1.0,0,0],testinputs)
		ks = Genetics.derive(20,truevals,testinputs)
		vals = Trials.predictor(20,ks,testinputs)
		assert Trials.ave_error(vals,truevals) < 1.0
	end

	test "Multi-variable relationship" do
		testinputs = [[1,10,10],[2,919,828],[3,882,19],[4,919,-6],[5,5,5],[6,6,6],[7,7,7],[8,99,0]]
		truevals = make_vals(20,[0.3,0.4,0.5],testinputs)
		ks = Genetics.derive(20,truevals,testinputs)
		vals = Trials.predictor(20,ks,testinputs)
		assert Trials.ave_error(vals,truevals) < 1.0
	end

end
