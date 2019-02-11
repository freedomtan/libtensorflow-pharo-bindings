Class {
	#name : #TensorFlowLiteCAPI,
	#superclass : #FFILibrary,
	#classInstVars : [
		'current'
	],
	#category : #'LibTensorFlow-Core'
}

{ #category : #accessing }
TensorFlowLiteCAPI class >> current [
	^ current ifNil: [ current := self uniqueInstance ]
]

{ #category : #'as yet unclassified' }
TensorFlowLiteCAPI >> interpreterAllocateTensors: interpreter [
	"TFL_CAPI_EXPORT extern TFL_Status TFL_InterpreterAllocateTensors(TFL_Interpreter* interpreter);"
	^ self ffiCall: #(int TFL_InterpreterAllocateTensors(ExternalAddress* interpreter)) module: TensorFlowLiteCAPI.
]

{ #category : #'as yet unclassified' }
TensorFlowLiteCAPI >> interpreterGetInputTensor: interpreter index: i [
	"TFL_CAPI_EXPORT extern TFL_Tensor* TFL_InterpreterGetInputTensor(const TFL_Interpreter* interpreter, int32_t input_index);"
	^ self ffiCall: #(ExternalAddress* TFL_InterpreterGetInputTensor(const ExternalAddress* interpreter, int i)) module: TensorFlowLiteCAPI.
]

{ #category : #'as yet unclassified' }
TensorFlowLiteCAPI >> interpreterGetOutputTensor: interpreter index: i [
	"TFL_CAPI_EXPORT extern TFL_Tensor* TFL_InterpreterGetOutputTensor(const TFL_Interpreter* interpreter, int32_t input_index);"
	^ self ffiCall: #(ExternalAddress* TFL_InterpreterGetOutputTensor(const ExternalAddress* interpreter, int i)) module: TensorFlowLiteCAPI.
]

{ #category : #'accessing platform' }
TensorFlowLiteCAPI >> macModuleName [ 
	^ '/usr/local/lib/libtensorflowlite_c.so'
]

{ #category : #'instance creation' }
TensorFlowLiteCAPI >> newInterpreter: model options: options [
	"TFL_CAPI_EXPORT extern TFL_Model* TFL_NewModelFromFile(const char* model_path)"
	^ self ffiCall: #(ExternalAddress* TFL_NewInterpreter(const ExternalAddress* model, const ExternalAddress* options)) module: TensorFlowLiteCAPI.
]

{ #category : #'instance creation' }
TensorFlowLiteCAPI >> newInterpreterOptions [
	"TFL_CAPI_EXPORT extern TFL_Model* TFL_NewModelFromFile(const char* model_path)"
	^ self ffiCall: #(ExternalAddress* TFL_NewInterpreterOptions(void)) module: TensorFlowLiteCAPI.
]

{ #category : #'instance creation' }
TensorFlowLiteCAPI >> newModelFromFile: model_path [
	"TFL_CAPI_EXPORT extern TFL_Model* TFL_NewModelFromFile(const char* model_path)"
	^ self ffiCall: #(ExternalAddress* TFL_NewModelFromFile(String model_path)) module: TensorFlowLiteCAPI.
]

{ #category : #'as yet unclassified' }
TensorFlowLiteCAPI >> tensorName: tensor [
	"TFL_CAPI_EXPORT extern const char* TFL_TensorName(const TFL_Tensor* tensor);"
	^ self ffiCall: #(String TFL_TensorName(const ExternalAddress* tensor)) module: TensorFlowLiteCAPI.
]

{ #category : #'accessing platform' }
TensorFlowLiteCAPI >> unixModuleName [
	"Kept for backward compatibility. 
	 Users should use unix32* or unix64*"
	^ '/usr/local/lib/libtensorflowlite_c.so'
]
