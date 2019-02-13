"
|capi model options interpreter inputTensor outputTensor labelImage data dataSize outputBuffer labels kv top_5|
capi := TensorFlowLiteCAPI current.
model := capi newModelFromFile: '/tmp/mobilenet_v1_1.0_224_quant.tflite'.
options := capi newInterpreterOptions.
interpreter := capi newInterpreter: model options: options.
capi interpreterAllocateTensors: interpreter.

inputTensor := capi interpreterGetInputTensor: interpreter index: 0.
outputTensor := capi interpreterGetOutputTensor: interpreter index: 0.
Transcript cr.
Transcript show: 'input tensor: '; show: (capi tensorName: inputTensor);cr.
Transcript show: 'output tensor: '; show: (capi tensorName: outputTensor);cr.
labelImage := LabelImage new prepareQuantImageInput.
data := labelImage inputValues data.
dataSize := labelImage inputValues size * labelImage inputValues elementSize.

capi tensorCopyFromBuffer: inputTensor buffer: data size: dataSize.
capi interpreterInvoke: interpreter.
outputTensor := capi interpreterGetOutputTensor: interpreter index: 0.
Transcript show: 'input size: '; show: (capi tensorByteSize: inputTensor); cr.
Transcript show: 'output size: '; show: (capi tensorByteSize: outputTensor); cr.

outputBuffer := capi malloc: 1001.
capi tensorCopyToBuffer: outputTensor buffer: outputBuffer size: 1001.

labels := '/tmp/labels.txt' asFileReference contents lines.
kv := Array new: 1001.
1 to: 1001 do: [ :x|
	kv at: x put: (Array with: (labels at: x) with: (outputBuffer getHandle byteAt: x)/255.0).
].

top_5 := (kv sort: [:k1 :k2 | (k1 at: 2) > (k2 at: 2)]) first: 5.
top_5 do: [ :each|
	Transcript show: each;cr].
"
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
TensorFlowLiteCAPI >> deleteInterpreterOptions: options [
	"Destroys the interpreter options instance.
	TFL_CAPI_EXPORT extern void TFL_DeleteInterpreterOptions(TFL_InterpreterOptions* options);"
	
	^ self ffiCall: #(void TFL_DeleteInterpreterOptions(ExternalAddress* options)) module: TensorFlowLiteCAPI.
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
TensorFlowLiteCAPI >> interpreterGetInputTensorCount: interpreter [
	"Returns the number of input tensors associated with the model.
	TFL_CAPI_EXPORT extern int TFL_InterpreterGetInputTensorCount(const TFL_Interpreter* interpreter);"
	^ self ffiCall: #(int TFL_InterpreterGetInputTensorCounter(const ExternalAddress* interpreter)) module: TensorFlowLiteCAPI.
]

{ #category : #tensor }
TensorFlowLiteCAPI >> interpreterGetOutputTensor: interpreter index: i [
	"TFL_CAPI_EXPORT extern TFL_Tensor* TFL_InterpreterGetOutputTensor(const TFL_Interpreter* interpreter, int32_t input_index);"
	^ self ffiCall: #(ExternalAddress* TFL_InterpreterGetOutputTensor(const ExternalAddress* interpreter, int i)) module: TensorFlowLiteCAPI.
]

{ #category : #tensor }
TensorFlowLiteCAPI >> interpreterGetOutputTensorCount: interpreter [
	"Returns the number of input tensors associated with the model.
	TFL_CAPI_EXPORT extern int TFL_InterpreterGetOutputTensorCount(const TFL_Interpreter* interpreter);"
	^ self ffiCall: #(int TFL_InterpreterGetOutputTensorCounter(const ExternalAddress* interpreter)) module: TensorFlowLiteCAPI.
]

{ #category : #invoking }
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

{ #category : #tensor }
TensorFlowLiteCAPI >> interpreterResizeInputTensor: interpreter index: i dims: dims dimsSize: size [
	"FL_CAPI_EXPORT extern TFL_Status TFL_InterpreterResizeInputTensor(
    TFL_Interpreter* interpreter, int32_t input_index, const int* input_dims,
    int32_t input_dims_size);"
	^ self ffiCall: #(int TFL_InterpreterResizeInputTensor(ExternalAddress* interpreter, int32_t index, const int* dims, int32_t dimsSize)) module: TensorFlowLiteCAPI.
]

{ #category : #'accessing platform' }
TensorFlowLiteCAPI >> macModuleName [ 
	^ '/usr/local/lib/libtensorflowlite_c.so'
]

{ #category : #'memory management' }
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

{ #category : #copying }
TensorFlowLiteCAPI >> tensorCopyFromBuffer: tensor buffer: buffer size: size [
	"TFL_CAPI_EXPORT extern 
	 	TFL_Status TFL_TensorCopyFromBuffer(TFL_Tensor* tensor, const void* input_data, size_t input_data_size);"
	^ self ffiCall: #(int TFL_TensorCopyFromBuffer(ExternalAddress* tensor, const void* buffer, size_t size)) module: TensorFlowLiteCAPI.
]

{ #category : #copying }
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
