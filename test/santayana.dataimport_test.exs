defmodule SantayanaTest.DataImportTest do
	alias Santayana.DataImport, as: Data
  use ExUnit.Case
  doctest Santayana


	defp start1 do
		Data.parsetime("2017-05-09T00:00:00")
	end
	defp end1 do
		Data.parsetime("2017-05-09T00:59:59")
	end

	defp start2 do
		Data.parsetime("2017-05-09T00:00:00")
	end
	defp end2 do
		Data.parsetime("2017-05-09T00:59:59")
	end

	test "Get one data set" do
		data = Data.get_data("BMS-L11O42S3",start1(),end1())
		assert data == [{Data.parsetime("2017-05-09T00:00:00Z"),"21.008004"},
										{Data.parsetime("2017-05-09T00:10:00Z"),"20.843956"},
										{Data.parsetime("2017-05-09T00:20:00Z"),"20.761932"},
										{Data.parsetime("2017-05-09T00:30:00Z"),"20.843956"},
										{Data.parsetime("2017-05-09T00:40:00Z"),"20.72092"},
										{Data.parsetime("2017-05-09T00:50:00Z"),"20.72092"}]
	end

	test "Get multiple data sets" do
		data = Data.get_multiple(["BMS-L11O42S21","BMS-L11O42S1","BMS-L11O43S21","BMS-L11O43S1"],start2(),end2())
		assert data == [[{~N[2017-05-09 00:00:00], "22.001108"}, {~N[2017-05-09 00:10:00], "22.042026"}, {~N[2017-05-09 00:20:00], "22.065408"}, {~N[2017-05-09 00:30:00], "22.030336"}, {~N[2017-05-09 00:40:00], "22.018645"}, {~N[2017-05-09 00:50:00], "21.919272"}], [{~N[2017-05-09 00:00:00], "581.060849"}, {~N[2017-05-09 00:10:00], "570.645494"}, {~N[2017-05-09 00:20:00], "575.853172"}, {~N[2017-05-09 00:30:00], "591.476205"}, {~N[2017-05-09 00:40:00], "575.853172"}, {~N[2017-05-09 00:50:00], "555.022461"}], [{~N[2017-05-09 00:00:00], "22.236534"}, {~N[2017-05-09 00:10:00], "22.206672"}, {~N[2017-05-09 00:20:00], "22.236534"}, {~N[2017-05-09 00:30:00], "22.236534"}, {~N[2017-05-09 00:40:00], "22.251465"}, {~N[2017-05-09 00:50:00], "22.191741"}], [{~N[2017-05-09 00:00:00], "375.461713"}, {~N[2017-05-09 00:10:00], "365.301436"}, {~N[2017-05-09 00:20:00], "355.14116"}, {~N[2017-05-09 00:30:00], "361.914677"}, {~N[2017-05-09 00:40:00], "358.527918"}, {~N[2017-05-09 00:50:00], "351.754401"}]]
	end

	test "Get and align data sets" do
		# This includes some 10min and some 5second resolution items
		data = Data.get_multiple(["BMS-L11O42S21","BMS-L1O11S55","BMS-L1O14S28"],start2(),end2())
		ts = Enum.map(List.zip(data), fn({a,b,c}) -> 
																			(Timex.compare(elem(a,0),elem(b,0)) == 0)
																			&&
																				(Timex.compare(elem(a,0),elem(c,0)) == 0)
																			&&
																				(Timex.compare(elem(b,0),elem(c,0)) == 0)
																	end)
		assert Enum.all?(ts, fn(t) -> t end)
	end

end