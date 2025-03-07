"
A copying temp is a temp that is copied into a block that later reads this variable.

Not: the temp vector is passed as a copying temp, too.
"
Class {
	#name : #OCCopyingTempVariable,
	#superclass : #OCTempVariable,
	#instVars : [
		'originalVar'
	],
	#category : #'OpalCompiler-Core-Semantics'
}

{ #category : #debugging }
OCCopyingTempVariable >> indexInTempVectorFromIR: aName [
	^(scope methodScope node irInstruction tempVectorNamed: name) indexForVarNamed: aName.
]

{ #category : #testing }
OCCopyingTempVariable >> isCopying [
	^true
]

{ #category : #accessing }
OCCopyingTempVariable >> originalVar [
	^ originalVar
]

{ #category : #accessing }
OCCopyingTempVariable >> originalVar: anObject [
	originalVar := anObject
]

{ #category : #'temp vector' }
OCCopyingTempVariable >> tempVectorForTempStoringIt [
	"If I am stroring a temp Vector, this method returns this victor.
	useful for analysis e.g. which variables are active in a context"
	
	| searchScope |
	self isStoringTempVector ifFalse: [^nil].
	searchScope := scope.
	
	[searchScope isInstanceScope or: [searchScope tempVectorName = name]] 
		whileFalse: [searchScope := searchScope outerScope].
	searchScope isInstanceScope 
		ifTrue: [ ^nil] "not found"
		ifFalse: [^ searchScope tempVector]
	
]

{ #category : #debugging }
OCCopyingTempVariable >> writeFromContext: aContext scope: contextScope value: aValue [
	
	| definitionContext |
	definitionContext := contextScope lookupDefiningContextFor: name startingFrom: aContext.
	
	originalVar writeFromContext: aContext scope: contextScope value: aValue.
	
	self flag: #FIXME.
	"we need to change all the copies and the original, too"
	
	^definitionContext 
		tempAt: self indexFromIR
		put: aValue
]
