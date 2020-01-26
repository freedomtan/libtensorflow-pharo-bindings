"
|capi model options interpreter inputTensor outputTensor labelImage data dataSize outputBuffer labels kv top_5|
capi := TensorFlowLiteCAPI current.
model := capi modelCreateFromFile: '/tmp/mobilenet_v1_1.0_224_quant.tflite'.
options := capi interpreterOptionsCreate.
interpreter := capi interpreterCreate: model options: options.
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
	"TFL_CAPI_EXPORT extern void TfLiteDeleteInterpreter(TfLiteInterpreter* interpreter);"
	^ self ffiCall: #(void TfLiteDeleteInterpreter(ExternalAddress* interpreter)) module: TensorFlowLiteCAPI.
]

{ #category : #deleting }
TensorFlowLiteCAPI >> deleteInterpreterOptions: options [
	"Destroys the interpreter options instance.
	TFL_CAPI_EXPORT extern void TfLiteDeleteInterpreterOptions(TfLiteInterpreterOptions* options);"
	
	^ self ffiCall: #(void TfLiteDeleteInterpreterOptions(ExternalAddress* options)) module: TensorFlowLiteCAPI.
]

{ #category : #deleting }
TensorFlowLiteCAPI >> deleteModel: model [
	"Destroys the model instance.
	TFL_CAPI_EXPORT extern void TfLiteDeleteModel(TfLiteModel* model);"
	^ self ffiCall: #(void TfLiteDeleteModel(ExternalAddress* model)) module: TensorFlowLiteCAPI.
]

{ #category : #tensor }
TensorFlowLiteCAPI >> interpreterAllocateTensors: interpreter [
	"TFL_CAPI_EXPORT extern TfLiteStatus TfLiteInterpreterAllocateTensors(TfLiteInterpreter* interpreter);"
	^ self ffiCall: #(int TfLiteInterpreterAllocateTensors(ExternalAddress* interpreter)) module: TensorFlowLiteCAPI.
]

{ #category : #'instance creation' }
TensorFlowLiteCAPI >> interpreterCreate: model options: options [
	"TFL_CAPI_EXPORT extern TfLiteInterpreter* TfLiteInterpreterCreate(const TfLiteModel* model, const TfLiteInterpreterOptions* optional_options);"
	^ self ffiCall: #(ExternalAddress* TfLiteInterpreterCreate(const ExternalAddress* model, const ExternalAddress* options)) module: TensorFlowLiteCAPI.
]

{ #category : #tensor }
TensorFlowLiteCAPI >> interpreterGetInputTensor: interpreter index: i [
	"TFL_CAPI_EXPORT extern TfLiteTensor* TfLiteInterpreterGetInputTensor(const TfLiteInterpreter* interpreter, int32_t input_index);"
	^ self ffiCall: #(ExternalAddress* TfLiteInterpreterGetInputTensor(const ExternalAddress* interpreter, int i)) module: TensorFlowLiteCAPI.
]

{ #category : #tensor }
TensorFlowLiteCAPI >> interpreterGetInputTensorCount: interpreter [
	"Returns the number of input tensors associated with the model.
	TFL_CAPI_EXPORT extern int TfLiteInterpreterGetInputTensorCount(const TfLiteInterpreter* interpreter);"
	^ self ffiCall: #(int TfLiteInterpreterGetInputTensorCounter(const ExternalAddress* interpreter)) module: TensorFlowLiteCAPI.
]

{ #category : #tensor }
TensorFlowLiteCAPI >> interpreterGetOutputTensor: interpreter index: i [
	"TFL_CAPI_EXPORT extern TfLiteTensor* TfLiteInterpreterGetOutputTensor(const TfLiteInterpreter* interpreter, int32_t input_index);"
	^ self ffiCall: #(ExternalAddress* TfLiteInterpreterGetOutputTensor(const ExternalAddress* interpreter, int i)) module: TensorFlowLiteCAPI.
]

{ #category : #tensor }
TensorFlowLiteCAPI >> interpreterGetOutputTensorCount: interpreter [
	"Returns the number of input tensors associated with the model.
	TFL_CAPI_EXPORT extern int TfLiteInterpreterGetOutputTensorCount(const TfLiteInterpreter* interpreter);"
	^ self ffiCall: #(int TfLiteInterpreterGetOutputTensorCounter(const ExternalAddress* interpreter)) module: TensorFlowLiteCAPI.
]

{ #category : #invoking }
TensorFlowLiteCAPI >> interpreterInvoke: interpreter [
	"TFL_CAPI_EXPORT extern TfLiteStatus TfLiteInterpreterInvoke(TfLiteInterpreter* interpreter);"
	^ self ffiCall: #(int TfLiteInterpreterInvoke(ExternalAddress* interpreter)) module: TensorFlowLiteCAPI.
]

{ #category : #'instance creation' }
TensorFlowLiteCAPI >> interpreterOptionsCreate [
	"TFL_CAPI_EXPORT extern TfLiteInterpreterOptions* TfLiteNewInterpreterOptions();"
	^ self ffiCall: #(ExternalAddress* TfLiteInterpreterOptionsCreate(void)) module: TensorFlowLiteCAPI.
]

{ #category : #options }
TensorFlowLiteCAPI >> interpreterOptionsSetNumThreads: interpreter numberOfThreads: n [
	"Sets the number of CPU threads to use for the interpreter.
	TFL_CAPI_EXPORT extern void TfLiteInterpreterOptionsSetNumThreads(TfLiteInterpreterOptions* options, int32_t num_threads)"
	
	^ self ffiCall: #(void FL_InterpreterOptionsSetNumThreads(const ExternalAddress* options, int n)) module: TensorFlowLiteCAPI.
]

{ #category : #tensor }
TensorFlowLiteCAPI >> interpreterResizeInputTensor: interpreter index: i dims: dims dimsSize: size [
	"FL_CAPI_EXPORT extern TfLiteStatus TfLiteInterpreterResizeInputTensor(
    TfLiteInterpreter* interpreter, int32_t input_index, const int* input_dims,
    int32_t input_dims_size);"
	^ self ffiCall: #(int TfLiteInterpreterResizeInputTensor(ExternalAddress* interpreter, int32_t index, const int* dims, int32_t dimsSize)) module: TensorFlowLiteCAPI.
]

{ #category : #'accessing platform' }
TensorFlowLiteCAPI >> macModuleName [ 
	^ '/usr/local/lib/libtensorflowlite_c.dylib'
]

{ #category : #'memory management' }
TensorFlowLiteCAPI >> malloc: aNumber [
	^ self ffiCall: #(void *malloc (int aNumber))
]

{ #category : #'instance creation' }
TensorFlowLiteCAPI >> modelCreateFromFile: model_path [
	"TFL_CAPI_EXPORT extern TfLiteModel* TfLiteModelCreateFromFile(const char* model_path)"
	^ self ffiCall: #(ExternalAddress* TfLiteModelCreateFromFile(String model_path)) module: TensorFlowLiteCAPI.
]

{ #category : #tensor }
TensorFlowLiteCAPI >> tensorByteSize: tensor [
	"TFL_CAPI_EXPORT extern size_t TfLiteTensorByteSize(const TfLiteTensor* tensor);"
	^ self ffiCall: #(size_t TfLiteTensorByteSize(const ExternalAddress* tensor)) module: TensorFlowLiteCAPI.
]

{ #category : #copying }
TensorFlowLiteCAPI >> tensorCopyFromBuffer: tensor buffer: buffer size: size [
	"TFL_CAPI_EXPORT extern 
	 	TfLiteStatus TfLiteTensorCopyFromBuffer(TfLiteTensor* tensor, const void* input_data, size_t input_data_size);"
	^ self ffiCall: #(int TfLiteTensorCopyFromBuffer(ExternalAddress* tensor, const void* buffer, size_t size)) module: TensorFlowLiteCAPI.
]

{ #category : #copying }
TensorFlowLiteCAPI >> tensorCopyToBuffer: tensor buffer: buffer size: size [
	"TFL_CAPI_EXPORT extern TfLiteStatus TfLiteTensorCopyToBuffer(const TfLiteTensor* output_tensor, void* output_data,
    size_t output_data_size);"
	^ self ffiCall: #(int TfLiteTensorCopyToBuffer(const ExternalAddress* tensor, void* buffer, size_t size)) module: TensorFlowLiteCAPI.
]

{ #category : #tensor }
TensorFlowLiteCAPI >> tensorName: tensor [
	"TFL_CAPI_EXPORT extern const char* TfLiteTensorName(const TfLiteTensor* tensor);"
	^ self ffiCall: #(String TfLiteTensorName(const ExternalAddress* tensor)) module: TensorFlowLiteCAPI.
]

{ #category : #'accessing platform' }
TensorFlowLiteCAPI >> unixModuleName [
	"Kept for backward compatibility. 
	 Users should use unix32* or unix64*"
	^ '/usr/local/lib/libtensorflowlite_c.so'
]
