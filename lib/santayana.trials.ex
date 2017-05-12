defmodule Santayana.Trials do
	require Logger
	@moduledoc """
  The Trials module contains functions for executing trials of constant sets against historical value sets using Newton's law of cooling.
  """

  # The predictor step takes an anterior value, a list of constants, a list of input values, and produces a posterior value.
  # The lengths of the lists of constants and input values must match.
	@spec predictor_step(number, [number], [number]) :: number
	defp predictor_step(t,ks,vs) do
		zs = Enum.zip(ks,vs)
		# Fold across the constant/value pairs, summing the values
		# The gradient between each value and the anterior value is multiplied by the respective constant
		List.foldl(zs,t,fn({k,v},tt) -> tt + (k * (v - t)) end)
	end																										 

	@doc """
  The predictor function takes an initial condition, a list of constants, a list of value lists (i.e. a list of all the values, with one list for each point in the time period) and produces a list of predicted values.

  The lengths of the lists of values must all equal the length of the list of constants.
  """
	@spec predictor(number,[number],[[number]]) :: [number]
	def predictor(ic,ks,vss) do
		# Fold across the list of values, using the previous result as the anterior value, and appending the posterior value to the head of the accumulator
		ts = List.foldl(vss,[ic], fn(vs,[c | cs]) ->  [predictor_step(c,ks,vs) | [c | cs]] end)
		# Because heads are easier to deal with, the list of values was built in reverse...
		Enum.reverse(ts)
	end


end