Drop Table If Exists #AdventDayOne

Create Table #AdventDayOne
(
	AdventID int Identity(1,1)
	,Lines varchar(100)
	,OnlyNumbers varchar(25)
	,FullNumber int
)

Drop Table If Exists #InputTable
Create Table #InputTable (inputString varchar(max))

Bulk Insert #InputTable From 'F:\AdventOfCode\input.txt'

Insert Into #AdventDayOne(Lines)
Select	inputString
From	#InputTable

Declare @Row int
Set @Row = (Select Max(AdventID) From #AdventDayOne)

;While @Row > 0
Begin
	Declare @Counter int = NULL
			,@MaxCounter int = NULL
			,@string varchar(100) = NULL
			,@onlynumbers varchar(25) = ''

	Set @Counter = 1

	Set @string = (Select Lines From #AdventDayOne Where AdventID = @Row)

	Set @MaxCounter = LEN(@string)

	;While @Counter <= @MaxCounter
	Begin
		If ISNUMERIC(SUBSTRING(@string,@Counter,1)) = 1 
		Begin
			Set @onlynumbers += Convert(varchar(1),SUBSTRING(@string,@Counter,1))
		End
		Else
		Begin
			If SUBSTRING(@string,@Counter,3) LIKE 'one'
			Begin
				Set @onlynumbers += '1'
			End
			Else If SUBSTRING(@string,@Counter,3) LIKE 'two'
			Begin
				Set @onlynumbers += '2'
			End
			Else If SUBSTRING(@string,@Counter,5) LIKE 'three'
			Begin
				Set @onlynumbers += '3'
			End
			Else If SUBSTRING(@string,@Counter,4) LIKE 'four'
			Begin
				Set @onlynumbers += '4'
			End
			Else If SUBSTRING(@string,@Counter,4) LIKE 'five'
			Begin
				Set @onlynumbers += '5'
			End
			Else If SUBSTRING(@string,@Counter,3) LIKE 'six'
			Begin
				Set @onlynumbers += '6'
			End
			Else If SUBSTRING(@string,@Counter,5) LIKE 'seven'
			Begin
				Set @onlynumbers += '7'
			End
			Else If SUBSTRING(@string,@Counter,5) LIKE 'eight'
			Begin
				Set @onlynumbers += '8'
			End
			Else If SUBSTRING(@string,@Counter,4) LIKE 'nine'
			Begin
				Set @onlynumbers += '9'
			End

		End
		Set @Counter = @Counter + 1
	End

	Update	#AdventDayOne
	Set		OnlyNumbers = @onlynumbers
	Where	AdventID = @Row

	Set @Row = @Row - 1
End

Update	#AdventDayOne
Set		FullNumber = Convert(int,LEFT(OnlyNumbers,1) + RIGHT(OnlyNumbers,1))

Select	*
From	#AdventDayOne

Select	SUM(FullNumber)
From	#AdventDayOne

--54728

Drop Table #AdventDayOne
Drop Table #InputTable