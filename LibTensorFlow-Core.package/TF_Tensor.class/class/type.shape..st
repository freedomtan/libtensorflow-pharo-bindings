instance creation
type: anInteger shape: anIntegerArray
" I understand dimensions are:
	#()		-> Scalar
	#(7)		-> Unidimensional array of 7 elements
	#(7 4)		-> 7x4 elements matrix
	#(2 5 9)	-> 2x5x9 elements cube
	etc."
	
	| bytesize elementSize |
	elementSize := self sizeForType: anInteger.
	bytesize := anIntegerArray inject: elementSize into: [:prev :each | prev * each].
	^self type: anInteger shape: anIntegerArray bytesize: bytesize