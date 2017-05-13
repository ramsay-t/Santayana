defmodule Santayana.Genetics do
	alias Santayana.Trials, as: Trials
	require Logger
	@moduledoc """
  This module contains the functions that perform the Genetic Algorithm to derive the coefficients for a given data set.
  """

	@doc """
  Derive the coefficients for a dataset.

  This function is basically just an interface to Elgar, the Erlang GA library.
  """
	@spec derive(number,[number],[[number]]) :: [number]
	def derive(ic,truevals,inputs) do
		# Various things use Skel pools, so we must conenct to the cluster and
    # start at least one worker.
    :net_adm.world()
    :timer.sleep(1000)
    :sk_work_master.find()
		Logger.info("Starting Skel pool workers...")
    peasants = Enum.map(:lists.seq(1,10), fn(_) -> :sk_peasant.start() end)
		
		# We need one coefficient per input, and the inputs are sorted as lists per time period
		klen = length(hd(inputs))
		options = [{:pop_size,50},{:thres,99}]

		# Run the GA
		ks = :elgar.run(&random_generator(klen,&1),&fitness(ic,truevals,inputs,&1),mutations(),&crossover/2,options)

		# Clean up the Skel workers
		Logger.info("Stopping Skel pool Workers.")
    Enum.map(peasants, fn(p) -> send(p, :terminate) end)

		# Return the coefficients
		ks
	end

	# A random coefficient generator...
	defp random_generator(len,_seed) do
		Enum.to_list(1..len) |> Enum.map(fn(_) -> :rand.uniform() end)
	end

	defp fitness(ic,truevals,inputs,candidate) do
		vals = Trials.predictor(ic,candidate,inputs)
		ae = Trials.ave_error(vals,truevals)
		#Logger.debug "Fitness #{inspect candidate} == #{inspect ae}%"
		100 - ae
	end

	defp mutations() do
		[&nudge_mu/1,
		 &mpy_mu/1,
		 &randomise_mu/1]
	end

	defp nudge_mu(ks) do
		i = :random.uniform(length(ks)) - 1
		v = Enum.at(ks,i)
		nv = v + rand_val()
		replace(ks,i,nv)
	end

	defp mpy_mu(ks) do
		i = :random.uniform(length(ks)) - 1
		v = Enum.at(ks,i)
		nv = v * rand_val()
		replace(ks,i,nv)
	end

	defp randomise_mu(ks) do
		i = :random.uniform(length(ks)) - 1
		v = Enum.at(ks,i)
		nv = rand_val()
		replace(ks,i,nv)
	end

	# randomise between + and - 1.0
	defp rand_val() do
		(:rand.uniform() * 2.0) - 1.0
	end

	defp replace(enum,idx,val) do
		{b,a} = Enum.split(enum,idx)
		aa = case a do 
					 [] -> [] 
					 [_ | as] -> as 
				 end
		r = b ++ [val] ++ aa
		#Logger.debug "Replacing #{inspect val} at #{inspect idx} in #{inspect enum} == #{inspect r}"
		r
	end

	defp crossover(ks1, ks2) do
		i = :random.uniform(length(ks1))
		{b1,_a1} = Enum.split(ks1,i)
		{_b2,a2} = Enum.split(ks2,i)
		r = b1 ++ a2
		#Logger.debug "Crossover at #{inspect i} in #{inspect ks1} and #{inspect ks2} == #{inspect r}"
		r
	end

end