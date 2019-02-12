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

{ #category : #deleting }
TensorFlowLiteCAPI >> deleteInterpreter: interpreter [
	"TFL_CAPI_EXPORT extern void TFL_DeleteInterpreter(TFL_Interpreter* interpreter);"
	^ self ffiCall: #(void TFL_DeleteInterpreter(ExternalAddress* interpreter)) module: TensorFlowLiteCAPI.
]

{ #category : #deleting }
TensorFlowLiteCAPI >> deleteModel: model [
	"Destroys the model instance.
	TFL_CAPI_EXPORT extern void TFL_DeleteModel(TFL_Model* model);"
	^ self ffiCall: #(void TFL_DeleteModel(ExternalAddress* model)) module: TensorFlowLiteCAPI.
]

{ #category : #tensor }
TensorFlowLiteCAPI >> interpreterAllocateTensors: interpreter [
	"TFL_CAPI_EXPORT extern TFL_Status TFL_InterpreterAllocateTensors(TFL_Interpreter* interpreter);"
	^ self ffiCall: #(int TFL_InterpreterAllocateTensors(ExternalAddress* interpreter)) module: TensorFlowLiteCAPI.
]

{ #category : #tensor }
TensorFlowLiteCAPI >> interpreterGetInputTensor: interpreter index: i [
	"TFL_CAPI_EXPORT extern TFL_Tensor* TFL_InterpreterGetInputTensor(const TFL_Interpreter* interpreter, int32_t input_index);"
	^ self ffiCall: #(ExternalAddress* TFL_InterpreterGetInputTensor(const ExternalAddress* interpreter, int i)) module: TensorFlowLiteCAPI.
]

{ #category : #tensor }
TensorFlowLiteCAPI >> interpreterGetOutputTensor: interpreter index: i [
	"TFL_CAPI_EXPORT extern TFL_Tensor* TFL_InterpreterGetOutputTensor(const TFL_Interpreter* interpreter, int32_t input_index);"
	^ self ffiCall: #(ExternalAddress* TFL_InterpreterGetOutputTensor(const ExternalAddress* interpreter, int i)) module: TensorFlowLiteCAPI.
]

{ #category : #'as yet unclassified' }
TensorFlowLiteCAPI >> interpreterInvoke: interpreter [
	"TFL_CAPI_EXPORT extern TFL_Status TFL_InterpreterInvoke(TFL_Interpreter* interpreter);"
	^ self ffiCall: #(int TFL_InterpreterInvoke(ExternalAddress* interpreter)) module: TensorFlowLiteCAPI.
]

{ #category : #options }
TensorFlowLiteCAPI >> interpreterOptionsSetNumThreads: interpreter numberOfThreads: n [
	"Sets the number of CPU threads to use for the interpreter.
	TFL_CAPI_EXPORT extern void TFL_InterpreterOptionsSetNumThreads(TFL_InterpreterOptions* options, int32_t num_threads)"
	
	^ self ffiCall: #(void FL_InterpreterOptionsSetNumThreads(const ExternalAddress* options, int n)) module: TensorFlowLiteCAPI.
]

{ #category : #'accessing platform' }
TensorFlowLiteCAPI >> macModuleName [ 
	^ '/usr/local/lib/libtensorflowlite_c.so'
]

{ #category : #'as yet unclassified' }
TensorFlowLiteCAPI >> malloc: aNumber [
	^ self ffiCall: #(void *malloc (int aNumber))
]

{ #category : #'instance creation' }
TensorFlowLiteCAPI >> newInterpreter: model options: options [
	"TFL_CAPI_EXPORT extern TFL_Interpreter* TFL_NewInterpreter(const TFL_Model* model, const TFL_InterpreterOptions* optional_options);"
	^ self ffiCall: #(ExternalAddress* TFL_NewInterpreter(const ExternalAddress* model, const ExternalAddress* options)) module: TensorFlowLiteCAPI.
]

{ #category : #'instance creation' }
TensorFlowLiteCAPI >> newInterpreterOptions [
	"TFL_CAPI_EXPORT extern TFL_InterpreterOptions* TFL_NewInterpreterOptions();"
	^ self ffiCall: #(ExternalAddress* TFL_NewInterpreterOptions(void)) module: TensorFlowLiteCAPI.
]

{ #category : #'instance creation' }
TensorFlowLiteCAPI >> newModelFromFile: model_path [
	"TFL_CAPI_EXPORT extern TFL_Model* TFL_NewModelFromFile(const char* model_path)"
	^ self ffiCall: #(ExternalAddress* TFL_NewModelFromFile(String model_path)) module: TensorFlowLiteCAPI.
]

{ #category : #tensor }
TensorFlowLiteCAPI >> tensorByteSize: tensor [
	"TFL_CAPI_EXPORT extern size_t TFL_TensorByteSize(const TFL_Tensor* tensor);"
	^ self ffiCall: #(size_t TFL_TensorByteSize(const ExternalAddress* tensor)) module: TensorFlowLiteCAPI.
]

{ #category : #'as yet unclassified' }
TensorFlowLiteCAPI >> tensorCopyFromBuffer: tensor buffer: buffer size: size [
	"TFL_CAPI_EXPORT extern 
	 	TFL_Status TFL_TensorCopyFromBuffer(TFL_Tensor* tensor, const void* input_data, size_t input_data_size);"
	^ self ffiCall: #(int TFL_TensorCopyFromBuffer(ExternalAddress* tensor, const void* buffer, size_t size)) module: TensorFlowLiteCAPI.
]

{ #category : #'as yet unclassified' }
TensorFlowLiteCAPI >> tensorCopyToBuffer: tensor buffer: buffer size: size [
	"TFL_CAPI_EXPORT extern TFL_Status TFL_TensorCopyToBuffer(const TFL_Tensor* output_tensor, void* output_data,
    size_t output_data_size);"
	^ self ffiCall: #(int TFL_TensorCopyToBuffer(const ExternalAddress* tensor, void* buffer, size_t size)) module: TensorFlowLiteCAPI.
]

{ #category : #tensor }
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
