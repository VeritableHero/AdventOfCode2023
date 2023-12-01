Drop Table If Exists #Temp

Create Table #Temp
(
	Lines varchar(100)
	,FirstNumberPosition int
	,FirstNumberValue int
	,LastNumberPosition int
	,LastNumberValue int
	,FullNumber int
)

Drop Table If Exists #inputTable
Create Table #inputTable (inputString varchar(max))

Bulk Insert #inputTable From 'F:\AdventOfCode\input.txt'

Insert Into #Temp(Lines)
Select	inputString
From	#inputTable

Drop Table If Exists #inputTable

Update	#Temp
Set		FirstNumberPosition = PATINDEX('%[0123456789]%',Lines)
		,LastNumberPosition = LEN(Lines) - PATINDEX('%[0123456789]%',REVERSE(Lines)) + 1

Update	#Temp
Set		FirstNumberValue = SUBSTRING(Lines,FirstNumberPosition,1)
		,LastNumberValue = SUBSTRING(Lines,LastNumberPosition,1)

Update	#Temp
Set		FullNumber = Convert(varchar(5),FirstNumberValue) + Convert(varchar(5),LastNumberValue)

Select	SUM(FullNumber)
From	#Temp

Drop Table #Temp