--Using Drop If Exists for testing purposes; still clean up at the end!
Drop Table If Exists #Day03Input
Create Table #Day03Input
(
	Info varchar(1000)
)

--Pull in the puzzle input; straight dump into single column table
Bulk Insert #Day03Input From 'F:\AdventOfCode\input_day03.txt'

--Second table for identity column and length of input string (in case it varies)
Drop Table If Exists #ModifiedInput
Create Table #ModifiedInput
(
	ID int Identity(1,1)
	,Input varchar(1000)
	,StringLength int
)
Insert Into #ModifiedInput(Input,StringLength)
Select	Info
		,LEN(Info)
From	#Day03Input

--Going to loop through the rows and characters to get a position mapping

--Create tables to hold the data
Drop Table If Exists #Symbols
Create Table #Symbols
(
	RowID int
	,Position int
)

Drop Table If Exists #Numbers
Create Table #Numbers
(
	RowID int
	,StartPosition int
	,EndPosition int
	,Number int
	,IncludeInSum bit
)

--Now for the loops
Declare @Row int = 1
		,@MaxRow int = 0
		,@Position int = 1
		,@MaxPosition int = 0

Set @MaxRow = (Select Max(ID) From #ModifiedInput)

;While @Row <= @MaxRow
Begin
	Declare @String varchar(1000) = ''
	Set @String = (Select Input From #ModifiedInput Where ID = @Row)

	Set @Position = 1
	Set @MaxPosition = LEN(@String)

	;While @Position <= @MaxPosition
	Begin
		--Is it a non-period symbol? 
		If SUBSTRING(@String,@Position,1) NOT LIKE '%[0123456789.]%'
		Begin
			Insert Into #Symbols(RowID,Position)
			Values (@Row,@Position)
		End

		--Is it the start of a number?
		If SUBSTRING(@String,@Position,1) LIKE '%[0123456789]%'
			and SUBSTRING(@String,@Position - 1,1) NOT LIKE '%[0123456789]%'
		Begin
			Insert Into #Numbers(RowID,StartPosition,EndPosition)
			Select	@Row
					,@Position
					,Case
						When SUBSTRING(@String,@Position + 1,1) NOT LIKE '%[0123456789]%' Then @Position --One digit number
						When SUBSTRING(@String,@Position + 2,1) NOT LIKE '%[0123456789]%' Then @Position + 1 --One digit number
						Else @Position + 2 --One digit number
					 End --Only accounting for a max number length of three characters
		End

		--Don't create an infinite loop!
		Set @Position += 1
	End

	--Don't create an infinite loop!
	Set @Row += 1
End

--Now, get the actual number values
Update	n
Set		Number = Convert(int,SUBSTRING(m.Input,n.StartPosition,EndPosition-StartPosition+1))
		,IncludeInSum = Case
							When Exists(Select	*
										From	#Symbols s
										Where	(s.RowID = n.RowID	--Same row, symbol immediately before or after number
													and ((s.Position = n.StartPosition - 1)
														or (s.Position = n.EndPosition + 1)))
												or (s.RowID = n.RowID - 1 --Previous row, symbol in proximity
													and s.Position BETWEEN n.StartPosition - 1 AND n.EndPosition + 1)
												or (s.RowID = n.RowID + 1 --Next row, symbol in proximity
													and s.Position BETWEEN n.StartPosition - 1 AND n.EndPosition + 1)) Then 1
							Else 0
						End
From	#Numbers n
		Inner Join #ModifiedInput m on m.ID = n.RowID

--Get a sum of all of the numbers adjacent to a symbol
Select	Sum(Number)
From	#Numbers
Where	IncludeInSum = 1

--Clean up
Drop Table #Day03Input
Drop Table #ModifiedInput
Drop Table #Symbols
Drop Table #Numbers