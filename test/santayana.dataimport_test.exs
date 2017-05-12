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
		assert data == [{~N[2017-05-09 00:00:00], ["22.001108", "581.060849", "22.236534", "375.461713"]}, {~N[2017-05-09 00:10:00], ["22.042026", "570.645494", "22.206672", "365.301436"]}, {~N[2017-05-09 00:20:00], ["22.065408", "575.853172", "22.236534", "355.14116"]}, {~N[2017-05-09 00:30:00], ["22.030336", "591.476205", "22.236534", "361.914677"]}, {~N[2017-05-09 00:40:00], ["22.018645", "575.853172", "22.251465", "358.527918"]}, {~N[2017-05-09 00:50:00], ["21.919272", "555.022461", "22.191741", "351.754401"]}]
	end

	test "Get and align data sets" do
		# This includes some 10min and some 5second resolution items
		data = Data.get_multiple(["BMS-L11O42S21","BMS-L1O11S55","BMS-L1O14S28"],start2(),end2())
		assert data == [{~N[2017-05-09 00:00:00], ["22.001108", "24.56997", "21.549697"]}, {~N[2017-05-09 00:10:00], ["22.042026", "24.56997", "21.549697"]}, {~N[2017-05-09 00:20:00], ["22.065408", "24.56997", "21.571879"]}, {~N[2017-05-09 00:30:00], ["22.030336", "24.56997", "21.549697"]}, {~N[2017-05-09 00:40:00], ["22.018645", "24.56997", "21.549697"]}, {~N[2017-05-09 00:50:00], ["21.919272", "24.56997", "21.566949"]}]
	end

end