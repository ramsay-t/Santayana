defmodule Santayana.DataImport do
	require Logger
	@moduledoc """
  This modules contains functions for connecting to the Sheffield Diamond Smart Building Information Service and extracting data.
  """

	defp format_time(t) do
		Timex.format!(t,"%FT%T",:strftime)
	end
	
  @doc """
  Parses time strings into Timex objects using a consistent format

  This parses strings like \"2017-05-09T00:59:59Z\" into Timex objects.

  """
	def parsetime(s) do
		ss = if(!String.ends_with?(s,"Z")) do
					 s <> "Z"
				 else
					 s
				 end
		Timex.parse!(ss, "%FT%TZ", :strftime)
	end
	
	@doc """
  Connect to the Sheffield Diamond Smart Building Information Service and retrieve the data for the specified ID in the specified period.

  The start and end times should be Timex objects.
  """
	@spec get_multiple(String.t,Timex.t,Timex.t) :: [{Timex.t,String.t}]
	def get_data(sid,startt,endt) do
		startstr = format_time(startt)
		endstr = format_time(endt)
		url = "http://smartbms01.shef.ac.uk/sensor?id=" <> sid <> "&start=" <> startstr <> "&end=" <> endstr
		Logger.info("Getting data: " <> url)
		resp = HTTPoison.get!(url)
		json = JSON.decode!(resp.body)
		
		Enum.map(json["values"],fn(j) -> {parsetime(j["datetime"]),j["value"]} end)

	end

	@doc """
  Request data for multiple data points.

  This function will then align the data. This is done using the most sparse data set, so data points are dropped from the other data sets until
  all the lists contain only the same date-time points, in the same order. 
  """
	@spec get_multiple([String.t],Timex.t,Timex.t) :: [[{Timex.t,String.t}]]
	def get_multiple(ls,startt,endt) do
		datas = Enum.map(ls,&get_data(&1,startt,endt))
		align(datas)
	end

	# Align multiple data sets so that you only have things with matching timestamps at the same positions in each list.
	# This will always skip intermediate values and "fast forward" other lists until the match
	defp align([]) do
		[]
	end
	defp align(ls) do
		t = latest(ls)
		ff = fast_forward_fixpoint(t,ls)
		if Enum.any?(ff, fn(f) -> f == [] end) do
			[]
		else
			h = {elem(hd(hd(ff)),0),Enum.map(ff,fn(f) -> elem(hd(f),1) end)}
			t = align(Enum.map(ff,&Kernel.tl(&1)))
			[h | t]
		end
	end

	# This is meaningless for an empty list...
	defp latest([l]) do
		case l do
			[] ->
				[]
			[h | _] ->
				elem(h,0)
		end
	end
	defp latest([l | ls]) do
		case l do
			[] ->
				latest(ls)
			[h | _] ->
				this = elem(h,0)
				other = latest(ls)
				if Timex.compare(this,other) > 0 do
					this
				else
					other
				end
		end
	end

	defp fast_forward([],_) do
		[]
	end
	defp fast_forward([l | ls],target) do
		if Timex.compare(elem(l,0),target) < 0 do
			fast_forward(ls,target)
		else
			[l|ls]
		end
	end

	defp fast_forward_fixpoint(latest,ls) do
		if Enum.any?(ls, fn(f) -> f == [] end) do
			ls
		else
			newlatest = latest(ls)
			if Timex.compare(newlatest,latest) == 0 do
				ls
			else
				fast_forward_fixpoint(newlatest,Enum.map(ls,&fast_forward(&1,newlatest)))
			end
		end
	end

end