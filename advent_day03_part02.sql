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
	SymbolID int Identity(1,1)
	,RowID int
	,Position int
)

Drop Table If Exists #Numbers
Create Table #Numbers
(
	NumbersID int Identity(1,1)
	,RowID int
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
		If SUBSTRING(@String,@Position,1) = '*'
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
From	#Numbers n
		Inner Join #ModifiedInput m on m.ID = n.RowID

--First, get the symbol/number combinations where they are adjacent
;With Matches as
(
	Select	s.SymbolID
			,n.NumbersID
			,n.Number
	From	#Symbols s
			Inner Join #Numbers n on(s.RowID = n.RowID	--Same row, symbol immediately before or after number
										and ((s.Position = n.StartPosition - 1)
											or (s.Position = n.EndPosition + 1)))
									or (s.RowID = n.RowID - 1 --Previous row, symbol in proximity
										and s.Position BETWEEN n.StartPosition - 1 AND n.EndPosition + 1)
									or (s.RowID = n.RowID + 1 --Next row, symbol in proximity
										and s.Position BETWEEN n.StartPosition - 1 AND n.EndPosition + 1)
)
--Need to narrow it down to only symbols with exactly two adjacent numbers
,OnlyMultiplyThese as
(
	Select	SymbolID
			,NumbersID
			,Number
			,ROW_NUMBER() OVER (Partition By SymbolID
								Order By NumbersID) as OrderThem
	From	Matches
	Where	SymbolID IN(Select	SymbolID
						From	Matches	
						Group By SymbolID
						Having	Count(SymbolID) = 2	)
)
--Using the cleaned up data, multiply the two values to get the results
,Results as 
(
	Select	omt1.SymbolID
			,omt1.NumbersID
			,omt1.Number as 'Number1'
			,omt2.Number as 'Number2'
			,omt1.Number * omt2.Number as 'TotalForSymbol'
	From	OnlyMultiplyThese omt1
			Inner Join OnlyMultiplyThese omt2 on omt2.SymbolID = omt1.SymbolID
										and omt2.OrderThem = 2
	Where	omt1.OrderThem = 1
)
Select	Sum(TotalForSymbol)
From	Results

--Clean up
Drop Table #Day03Input
Drop Table #ModifiedInput
Drop Table #Symbols
Drop Table #Numbers