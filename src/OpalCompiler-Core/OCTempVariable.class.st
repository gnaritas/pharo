"
I model temp variables. With Closures, there are two kinds: Copying and those that are stores in a so called temp vector, a heap allocated array that itself is stored in an un-named copying temp variable.
"
Class {
	#name : #OCTempVariable,
	#superclass : #OCAbstractLocalVariable,
	#instVars : [
		'escaping'
	],
	#category : #'OpalCompiler-Core-Semantics'
}

{ #category : #accessing }
OCTempVariable class >> semanticNodeClass [

	^RBTemporaryNode 
]

{ #category : #comparing }
OCTempVariable >> = aTempVar [

	^aTempVar class = self class 
		and: [aTempVar scope = self scope 
		and: [aTempVar name = self name
		and: [aTempVar usage = self usage]]].

	
]

{ #category : #emitting }
OCTempVariable >> emitStore: methodBuilder [

	methodBuilder storeTemp: name. 
]

{ #category : #emitting }
OCTempVariable >> emitValue: methodBuilder [

	methodBuilder pushTemp: name.
]

{ #category : #escaping }
OCTempVariable >> escaping [
	^escaping
]

{ #category : #escaping }
OCTempVariable >> escaping: anObject [
	escaping := anObject
]

{ #category : #comparing }
OCTempVariable >> hash [

	^ name hash bitXor: (usage hash bitXor: scope hash).
]

{ #category : #debugging }
OCTempVariable >> indexFromIR [
	^scope outerNotOptimizedScope node irInstruction indexForVarNamed: name
]

{ #category : #initialization }
OCTempVariable >> initialize [
	super initialize.
	escaping := false.
]

{ #category : #testing }
OCTempVariable >> isCopying [
	^false
]

{ #category : #escaping }
OCTempVariable >> isEscaping [
	^escaping = #escapingRead or: [escaping = #escapingWrite]
]

{ #category : #escaping }
OCTempVariable >> isEscapingRead [
	^escaping = #escapingRead

]

{ #category : #escaping }
OCTempVariable >> isEscapingWrite [
	^escaping = #escapingWrite

]

{ #category : #testing }
OCTempVariable >> isStoringTempVector [
	"I am a temp that stores a temp vector. Those generated temps have a invalid name starting with 0"
	^name first = $0.
]

{ #category : #testing }
OCTempVariable >> isTemp [

	^ true
]

{ #category : #testing }
OCTempVariable >> isTempVectorTemp [
	^false
]

{ #category : #escaping }
OCTempVariable >> markEscapingRead [
	escaping = #escapingWrite ifFalse: [escaping := #escapingRead]
]

{ #category : #escaping }
OCTempVariable >> markEscapingWrite [
	escaping := #escapingWrite.
	self isRepeatedWrite ifFalse:[usage := #write]
]

{ #category : #escaping }
OCTempVariable >> markRepeatedWrite [
	"same as write"
	self markWrite.
	super markRepeatedWrite.
]

{ #category : #escaping }
OCTempVariable >> markWrite [

	"if an escaping var is wrote to later, it needs to be remote"
	self isEscaping 
		ifTrue: [self markEscapingWrite].
	super markWrite.
]

{ #category : #debugging }
OCTempVariable >> readFromContext: aContext [

	^ aContext tempAt: self indexFromIR
]

{ #category : #debugging }
OCTempVariable >> readFromContext: aContext scope: contextScope [
	| definitionContext |
	definitionContext := contextScope lookupDefiningContextFor: name startingFrom: aContext.
	^ self readFromContext: definitionContext
]

{ #category : #debugging }
OCTempVariable >> writeFromContext: aContext scope: contextScope value: aValue [

	| definitionContext |
	definitionContext := contextScope lookupDefiningContextFor: name startingFrom: aContext.

	^definitionContext 
		tempAt: self indexFromIR
		put: aValue
]
