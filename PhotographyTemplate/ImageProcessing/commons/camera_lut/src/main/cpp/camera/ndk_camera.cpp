#include "ndk_camera.h"
#include "../common/common.h"

namespace OHOS_CAMERA_SAMPLE {
NDKCamera *NDKCamera::ndkCamera_ = nullptr;
std::mutex NDKCamera::mtx_;

NDKCamera::NDKCamera(const char *surfaceId, uint32_t focusMode, uint32_t cameraDeviceIndex)
    : previewSurfaceId_(surfaceId), cameras_(nullptr), focusMode_(focusMode), cameraDeviceIndex_(cameraDeviceIndex),
      cameraOutputCapability_(nullptr), cameraInput_(nullptr), captureSession_(nullptr), size_(0),
      isCameraMuted_(nullptr), profile_(nullptr), photoSurfaceId_(nullptr), previewOutput_(nullptr),
      photoOutput_(nullptr), metaDataObjectType_(nullptr), metadataOutput_(nullptr), isExposureModeSupported_(false),
      isFocusModeSupported_(false), exposureMode_(EXPOSURE_MODE_LOCKED), minExposureBias_(0), maxExposureBias_(0),
      step_(0), ret_(CAMERA_OK) {
    OH_LOG_Print(LOG_APP, LOG_INFO, NativeXComponentSample::LOG_PRINT_DOMAIN, "RenderThread",
                 "start create NDKCamera.");
    valid_ = false;
    Camera_ErrorCode ret = OH_Camera_GetCameraManager(&cameraManager_);
    if (cameraManager_ == nullptr || ret != CAMERA_OK) {
    }

    ret = OH_CameraManager_CreateCaptureSession(cameraManager_, &captureSession_);
    if (captureSession_ == nullptr || ret != CAMERA_OK) {
    }
    CaptureSessionRegisterCallback();
    GetSupportedCameras();
    GetSupportedOutputCapability();
    CreatePreviewOutput();
    CreateCameraInput();
    CameraInputOpen();
    CameraManagerRegisterCallback();
    SessionFlowFn();
    valid_ = true;
    OH_LOG_Print(LOG_APP, LOG_INFO, NativeXComponentSample::LOG_PRINT_DOMAIN, "RenderThread",
                 "create NDKCamera finish.");
}

NDKCamera::~NDKCamera() {
    OH_LOG_Print(LOG_APP, LOG_INFO, NativeXComponentSample::LOG_PRINT_DOMAIN, "RenderThread", "NDKCamera 开始析构.");
    valid_ = false;
    Camera_ErrorCode ret = CAMERA_OK;
    ReleaseCamera();

    if (cameraManager_) {
        ret = OH_CameraManager_DeleteSupportedCameraOutputCapability(cameraManager_, cameraOutputCapability_);
        if (ret != CAMERA_OK) {
        } else {
        }

        ret = OH_CameraManager_DeleteSupportedCameras(cameraManager_, cameras_, size_);
        if (ret != CAMERA_OK) {
        } else {
        }

        ret = OH_Camera_DeleteCameraManager(cameraManager_);
        if (ret != CAMERA_OK) {
        } else {
        }
        cameraManager_ = nullptr;
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, NativeXComponentSample::LOG_PRINT_DOMAIN, "RenderThread", "NDKCamera 析构完成.");
}

Camera_ErrorCode NDKCamera::ReleaseCamera(void) {
    if (previewOutput_) {
        PreviewOutputStop();
        PreviewOutputRelease();
    }
    if (photoOutput_) {
        PhotoOutputRelease();
    }
    if (captureSession_) {
        SessionRelease();
    }
    if (cameraInput_) {
        CameraInputClose();
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, NativeXComponentSample::LOG_PRINT_DOMAIN, "RenderThread",
                 "ReleaseCamera completed.");
    return ret_;
}

Camera_ErrorCode NDKCamera::ReleaseSession(void) {
    PreviewOutputStop();
    PhotoOutputRelease();
    SessionRelease();
    return ret_;
}

Camera_ErrorCode NDKCamera::SessionRelease(void) {
    Camera_ErrorCode ret = OH_CaptureSession_Release(captureSession_);
    captureSession_ = nullptr;
    return ret;
}

Camera_ErrorCode NDKCamera::HasFlashFn(uint32_t mode) {
    Camera_FlashMode flashMode = static_cast<Camera_FlashMode>(mode);
    // Check for flashing lights
    bool hasFlash = false;
    Camera_ErrorCode ret = OH_CaptureSession_HasFlash(captureSession_, &hasFlash);
    if (captureSession_ == nullptr || ret != CAMERA_OK) {
    }
    if (hasFlash) {
    } else {
    }

    // Check if the flash mode is supported
    bool isSupported = false;
    ret = OH_CaptureSession_IsFlashModeSupported(captureSession_, flashMode, &isSupported);
    if (ret != CAMERA_OK) {
    }
    if (isSupported) {
    } else {
    }

    // Set flash mode
    ret = OH_CaptureSession_SetFlashMode(captureSession_, flashMode);
    if (ret == CAMERA_OK) {
    } else {
    }

    // Obtain the flash mode of the current device
    ret = OH_CaptureSession_GetFlashMode(captureSession_, &flashMode);
    if (ret == CAMERA_OK) {
    } else {
    }
    return ret;
}

Camera_ErrorCode NDKCamera::IsVideoStabilizationModeSupportedFn(uint32_t mode) {
    Camera_VideoStabilizationMode videoMode = static_cast<Camera_VideoStabilizationMode>(mode);
    // Check if the specified video anti shake mode is supported
    bool isSupported = false;
    Camera_ErrorCode ret =
        OH_CaptureSession_IsVideoStabilizationModeSupported(captureSession_, videoMode, &isSupported);
    if (ret != CAMERA_OK) {
    }
    if (isSupported) {
    } else {
    }

    // Set video stabilization
    ret = OH_CaptureSession_SetVideoStabilizationMode(captureSession_, videoMode);
    if (ret == CAMERA_OK) {
    } else {
    }

    ret = OH_CaptureSession_GetVideoStabilizationMode(captureSession_, &videoMode);
    if (ret == CAMERA_OK) {
    } else {
    }
    return ret;
}

Camera_ErrorCode NDKCamera::setZoomRatioFn(uint32_t zoomRatio) {
    float zoom = float(zoomRatio);
    // Obtain supported zoom range
    float minZoom;
    float maxZoom;
    Camera_ErrorCode ret = OH_CaptureSession_GetZoomRatioRange(captureSession_, &minZoom, &maxZoom);
    if (captureSession_ == nullptr || ret != CAMERA_OK) {
    } else {
    }

    // Set Zoom
    ret = OH_CaptureSession_SetZoomRatio(captureSession_, zoom);
    if (ret == CAMERA_OK) {
    } else {
    }

    // Obtain the zoom value of the current device
    ret = OH_CaptureSession_GetZoomRatio(captureSession_, &zoom);
    if (ret == CAMERA_OK) {
    } else {
    }
    return ret;
}

Camera_ErrorCode NDKCamera::SessionBegin(void) {
    Camera_ErrorCode ret = OH_CaptureSession_BeginConfig(captureSession_);
    if (ret == CAMERA_OK) {
    } else {
    }
    return ret;
}

Camera_ErrorCode NDKCamera::SessionCommitConfig(void) {
    Camera_ErrorCode ret = OH_CaptureSession_CommitConfig(captureSession_);
    if (ret == CAMERA_OK) {
    } else {
    }
    return ret;
}

Camera_ErrorCode NDKCamera::SessionStart(void) {
    Camera_ErrorCode ret = OH_CaptureSession_Start(captureSession_);
    if (ret == CAMERA_OK) {
    } else {
    }
    return ret;
}

Camera_ErrorCode NDKCamera::SessionStop(void) {
    Camera_ErrorCode ret = OH_CaptureSession_Stop(captureSession_);
    if (ret == CAMERA_OK) {
    } else {
    }
    return ret;
}

Camera_ErrorCode NDKCamera::SessionFlowFn(void) {
    // Start configuring session
    Camera_ErrorCode ret = OH_CaptureSession_BeginConfig(captureSession_);

    // Add CameraInput to the session
    ret = OH_CaptureSession_AddInput(captureSession_, cameraInput_);

    // Add previewOutput to the session
    ret = OH_CaptureSession_AddPreviewOutput(captureSession_, previewOutput_);

    // Adding PhotoOutput to the Session

    // Submit configuration information
    ret = OH_CaptureSession_CommitConfig(captureSession_);

    // Start Session Work
    ret = OH_CaptureSession_Start(captureSession_);

    // Start focusing
    ret = IsFocusMode(focusMode_);
    return ret;
}

Camera_ErrorCode NDKCamera::CreateCameraInput(void) {
    ret_ = OH_CameraManager_CreateCameraInput(cameraManager_, &cameras_[cameraDeviceIndex_], &cameraInput_);
    if (cameraInput_ == nullptr || ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    CameraInputRegisterCallback();
    return ret_;
}

Camera_ErrorCode NDKCamera::CameraInputOpen(void) {
    ret_ = OH_CameraInput_Open(cameraInput_);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret_;
}

Camera_ErrorCode NDKCamera::CameraInputClose(void) {
    ret_ = OH_CameraInput_Close(cameraInput_);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret_;
}

Camera_ErrorCode NDKCamera::CameraInputRelease(void) {
    ret_ = OH_CameraInput_Release(cameraInput_);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret_;
}

Camera_ErrorCode NDKCamera::GetSupportedCameras(void) {
    ret_ = OH_CameraManager_GetSupportedCameras(cameraManager_, &cameras_, &size_);
    if (cameras_ == nullptr || ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret_;
}

Camera_ErrorCode NDKCamera::GetSupportedOutputCapability(void) {
    ret_ = OH_CameraManager_GetSupportedCameraOutputCapability(cameraManager_, &cameras_[cameraDeviceIndex_],
                                                               &cameraOutputCapability_);
    if (cameraOutputCapability_ == nullptr || ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret_;
}

Camera_ErrorCode NDKCamera::CreatePreviewOutput(void) {
    for (int i = 0; i < cameraOutputCapability_->previewProfilesSize; i++) {
        if (cameraOutputCapability_->previewProfiles[i]->size.height == 1080 &&
            cameraOutputCapability_->previewProfiles[i]->size.width == 1920) {
            profile_ = cameraOutputCapability_->previewProfiles[i];
            break;
        }
    }
    if (profile_ == nullptr) {
        return CAMERA_INVALID_ARGUMENT;
    }
    ret_ = OH_CameraManager_CreatePreviewOutput(cameraManager_, profile_, previewSurfaceId_, &previewOutput_);
    if (previewSurfaceId_ == nullptr || previewOutput_ == nullptr || ret_ != CAMERA_OK) {
        OH_LOG_ERROR(LOG_APP, "CreatePreviewOutput failed.");
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret_;
}

Camera_ErrorCode NDKCamera::CreatePhotoOutput(char *photoSurfaceId) {
    profile_ = cameraOutputCapability_->photoProfiles[0];
    if (profile_ == nullptr) {
        return CAMERA_INVALID_ARGUMENT;
    }

    if (photoSurfaceId == nullptr) {
        return CAMERA_INVALID_ARGUMENT;
    }

    ret_ = OH_CameraManager_CreatePhotoOutput(cameraManager_, profile_, photoSurfaceId, &photoOutput_);
    PhotoOutputRegisterCallback();
    return ret_;
}

Camera_ErrorCode NDKCamera::CreateVideoOutput(char *videoId) {
    videoProfile_ = cameraOutputCapability_->videoProfiles[0];

    if (videoProfile_ == nullptr) {
        return CAMERA_INVALID_ARGUMENT;
    }
    ret_ = OH_CameraManager_CreateVideoOutput(cameraManager_, videoProfile_, videoId, &videoOutput_);
    if (videoId == nullptr || videoOutput_ == nullptr || ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }

    return ret_;
}

Camera_ErrorCode NDKCamera::AddVideoOutput(void) {
    Camera_ErrorCode ret = OH_CaptureSession_AddVideoOutput(captureSession_, videoOutput_);
    if (ret == CAMERA_OK) {
    } else {
    }
    return ret;
}

Camera_ErrorCode NDKCamera::AddPhotoOutput() {
    Camera_ErrorCode ret = OH_CaptureSession_AddPhotoOutput(captureSession_, photoOutput_);
    if (ret == CAMERA_OK) {
    } else {
    }
    return ret;
}

Camera_ErrorCode NDKCamera::CreateMetadataOutput(void) {
    metaDataObjectType_ = cameraOutputCapability_->supportedMetadataObjectTypes[0];
    if (metaDataObjectType_ == nullptr) {
        return CAMERA_INVALID_ARGUMENT;
    }
    ret_ = OH_CameraManager_CreateMetadataOutput(cameraManager_, metaDataObjectType_, &metadataOutput_);
    if (metadataOutput_ == nullptr || ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    MetadataOutputRegisterCallback();
    return ret_;
}

Camera_ErrorCode NDKCamera::IsCameraMuted(void) {
    ret_ = OH_CameraManager_IsCameraMuted(cameraManager_, isCameraMuted_);
    if (isCameraMuted_ == nullptr || ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret_;
}

Camera_ErrorCode NDKCamera::PreviewOutputStop(void) {
    ret_ = OH_PreviewOutput_Stop(previewOutput_);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret_;
}

Camera_ErrorCode NDKCamera::PreviewOutputRelease(void) {
    ret_ = OH_PreviewOutput_Release(previewOutput_);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    previewOutput_ = nullptr;
    return ret_;
}

Camera_ErrorCode NDKCamera::PhotoOutputRelease(void) {
    ret_ = OH_PhotoOutput_Release(photoOutput_);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    photoOutput_ = nullptr;
    return ret_;
}

Camera_ErrorCode NDKCamera::StartVideo(char *videoId, char *photoId) {
    Camera_ErrorCode ret = SessionStop();
    if (ret == CAMERA_OK) {
    } else {
    }
    ret = SessionBegin();
    if (ret == CAMERA_OK) {
    } else {
    }
    OH_CaptureSession_RemovePhotoOutput(captureSession_, photoOutput_);
    CreatePhotoOutput(photoId);
    AddPhotoOutput();
    CreateVideoOutput(videoId);
    AddVideoOutput();
    SessionCommitConfig();
    SessionStart();
    VideoOutputRegisterCallback();
    return ret;
}

Camera_ErrorCode NDKCamera::VideoOutputStart(void) {
    Camera_ErrorCode ret = OH_VideoOutput_Start(videoOutput_);
    if (ret == CAMERA_OK) {
    } else {
    }
    return ret;
}

Camera_ErrorCode NDKCamera::StartPhoto(char *mSurfaceId) {
    Camera_ErrorCode ret = CAMERA_OK;
    if (takePictureTimes == 0) {
        ret = SessionStop();
        if (ret == CAMERA_OK) {
        } else {
        }
        ret = SessionBegin();
        if (ret == CAMERA_OK) {
        } else {
        }
        ret = CreatePhotoOutput(mSurfaceId);
        ret = OH_CaptureSession_AddPhotoOutput(captureSession_, photoOutput_);
        ret = SessionCommitConfig();
        ret = SessionStart();
    }
    ret = TakePicture();
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    takePictureTimes++;
    return ret_;
}

// exposure mode
Camera_ErrorCode NDKCamera::IsExposureModeSupportedFn(uint32_t mode) {
    exposureMode_ = static_cast<Camera_ExposureMode>(mode);
    ret_ = OH_CaptureSession_IsExposureModeSupported(captureSession_, exposureMode_, &isExposureModeSupported_);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    ret_ = OH_CaptureSession_SetExposureMode(captureSession_, exposureMode_);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    ret_ = OH_CaptureSession_GetExposureMode(captureSession_, &exposureMode_);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret_;
}

Camera_ErrorCode NDKCamera::IsMeteringPoint(int x, int y) {
    ret_ = OH_CaptureSession_GetExposureMode(captureSession_, &exposureMode_);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    Camera_Point exposurePoint;
    exposurePoint.x = x;
    exposurePoint.y = y;
    ret_ = OH_CaptureSession_SetMeteringPoint(captureSession_, exposurePoint);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    ret_ = OH_CaptureSession_GetMeteringPoint(captureSession_, &exposurePoint);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret_;
}

Camera_ErrorCode NDKCamera::IsExposureBiasRange(int exposureBias) {
    float exposureBiasValue = static_cast<float>(exposureBias);
    ret_ = OH_CaptureSession_GetExposureBiasRange(captureSession_, &minExposureBias_, &maxExposureBias_, &step_);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    ret_ = OH_CaptureSession_SetExposureBias(captureSession_, exposureBiasValue);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    ret_ = OH_CaptureSession_GetExposureBias(captureSession_, &exposureBiasValue);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret_;
}

// focus mode
Camera_ErrorCode NDKCamera::IsFocusModeSupported(uint32_t mode) {
    Camera_FocusMode focusMode = static_cast<Camera_FocusMode>(mode);
    ret_ = OH_CaptureSession_IsFocusModeSupported(captureSession_, focusMode, &isFocusModeSupported_);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret_;
}

Camera_ErrorCode NDKCamera::IsFocusMode(uint32_t mode) {
    Camera_FocusMode focusMode = static_cast<Camera_FocusMode>(mode);
    ret_ = OH_CaptureSession_IsFocusModeSupported(captureSession_, focusMode, &isFocusModeSupported_);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    ret_ = OH_CaptureSession_SetFocusMode(captureSession_, focusMode);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    ret_ = OH_CaptureSession_GetFocusMode(captureSession_, &focusMode);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret_;
}

Camera_ErrorCode NDKCamera::IsFocusPoint(float x, float y) {
    Camera_Point focusPoint;
    focusPoint.x = x;
    focusPoint.y = y;
    ret_ = OH_CaptureSession_SetFocusPoint(captureSession_, focusPoint);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    ret_ = OH_CaptureSession_GetFocusPoint(captureSession_, &focusPoint);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret_;
}

int32_t NDKCamera::GetVideoFrameWidth(void) {
    videoProfile_ = cameraOutputCapability_->videoProfiles[0];
    if (videoProfile_ == nullptr) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return videoProfile_->size.width;
}

int32_t NDKCamera::GetVideoFrameHeight(void) {
    videoProfile_ = cameraOutputCapability_->videoProfiles[0];
    if (videoProfile_ == nullptr) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return videoProfile_->size.height;
}

int32_t NDKCamera::GetVideoFrameRate(void) {
    videoProfile_ = cameraOutputCapability_->videoProfiles[0];
    if (videoProfile_ == nullptr) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return videoProfile_->range.min;
}

Camera_ErrorCode NDKCamera::VideoOutputStop(void) {
    ret_ = OH_VideoOutput_Stop(videoOutput_);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret_;
}

Camera_ErrorCode NDKCamera::VideoOutputRelease(void) {
    ret_ = OH_VideoOutput_Release(videoOutput_);
    if (ret_ != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret_;
}

Camera_ErrorCode NDKCamera::TakePicture(void) {
    Camera_ErrorCode ret = CAMERA_OK;
    ret = OH_PhotoOutput_Capture(photoOutput_);
    if (ret != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret;
}

Camera_ErrorCode NDKCamera::TakePictureWithPhotoSettings(Camera_PhotoCaptureSetting photoSetting) {
    Camera_ErrorCode ret = CAMERA_OK;
    ret = OH_PhotoOutput_Capture_WithCaptureSetting(photoOutput_, photoSetting);
    if (ret != CAMERA_OK) {
        return CAMERA_INVALID_ARGUMENT;
    }
    return ret;
}

// CameraManager Callback
void CameraManagerStatusCallback(Camera_Manager *cameraManager, Camera_StatusInfo *status) {}

CameraManager_Callbacks *NDKCamera::GetCameraManagerListener(void) {
    static CameraManager_Callbacks cameraManagerListener = {.onCameraStatus = CameraManagerStatusCallback};
    return &cameraManagerListener;
}

Camera_ErrorCode NDKCamera::CameraManagerRegisterCallback(void) {
    ret_ = OH_CameraManager_RegisterCallback(cameraManager_, GetCameraManagerListener());
    if (ret_ != CAMERA_OK) {
    }
    return ret_;
}

// CameraInput Callback
void OnCameraInputError(const Camera_Input *cameraInput, Camera_ErrorCode errorCode) {}

CameraInput_Callbacks *NDKCamera::GetCameraInputListener(void) {
    static CameraInput_Callbacks cameraInputCallbacks = {.onError = OnCameraInputError};
    return &cameraInputCallbacks;
}

Camera_ErrorCode NDKCamera::CameraInputRegisterCallback(void) {
    ret_ = OH_CameraInput_RegisterCallback(cameraInput_, GetCameraInputListener());
    if (ret_ != CAMERA_OK) {
    }
    return ret_;
}

// PreviewOutput Callback
void PreviewOutputOnFrameStart(Camera_PreviewOutput *previewOutput) {}

void PreviewOutputOnFrameEnd(Camera_PreviewOutput *previewOutput, int32_t frameCount) {}

void PreviewOutputOnError(Camera_PreviewOutput *previewOutput, Camera_ErrorCode errorCode) {}

PreviewOutput_Callbacks *NDKCamera::GetPreviewOutputListener(void) {
    static PreviewOutput_Callbacks previewOutputListener = {.onFrameStart = PreviewOutputOnFrameStart,
                                                            .onFrameEnd = PreviewOutputOnFrameEnd,
                                                            .onError = PreviewOutputOnError};
    return &previewOutputListener;
}

Camera_ErrorCode NDKCamera::PreviewOutputRegisterCallback(void) {
    ret_ = OH_PreviewOutput_RegisterCallback(previewOutput_, GetPreviewOutputListener());
    if (ret_ != CAMERA_OK) {
    }
    return ret_;
}

// PhotoOutput Callback
void PhotoOutputOnFrameStart(Camera_PhotoOutput *photoOutput) {}

void PhotoOutputOnFrameShutter(Camera_PhotoOutput *photoOutput, Camera_FrameShutterInfo *info) {}

void PhotoOutputOnFrameEnd(Camera_PhotoOutput *photoOutput, int32_t frameCount) {}

void PhotoOutputOnError(Camera_PhotoOutput *photoOutput, Camera_ErrorCode errorCode) {}

PhotoOutput_Callbacks *NDKCamera::GetPhotoOutputListener(void) {
    static PhotoOutput_Callbacks photoOutputListener = {.onFrameStart = PhotoOutputOnFrameStart,
                                                        .onFrameShutter = PhotoOutputOnFrameShutter,
                                                        .onFrameEnd = PhotoOutputOnFrameEnd,
                                                        .onError = PhotoOutputOnError};
    return &photoOutputListener;
}

Camera_ErrorCode NDKCamera::PhotoOutputRegisterCallback(void) {
    ret_ = OH_PhotoOutput_RegisterCallback(photoOutput_, GetPhotoOutputListener());
    if (ret_ != CAMERA_OK) {
    }
    return ret_;
}

// VideoOutput Callback
void VideoOutputOnFrameStart(Camera_VideoOutput *videoOutput) {}

void VideoOutputOnFrameEnd(Camera_VideoOutput *videoOutput, int32_t frameCount) {}

void VideoOutputOnError(Camera_VideoOutput *videoOutput, Camera_ErrorCode errorCode) {}

VideoOutput_Callbacks *NDKCamera::GetVideoOutputListener(void) {
    static VideoOutput_Callbacks videoOutputListener = {
        .onFrameStart = VideoOutputOnFrameStart, .onFrameEnd = VideoOutputOnFrameEnd, .onError = VideoOutputOnError};
    return &videoOutputListener;
}

Camera_ErrorCode NDKCamera::VideoOutputRegisterCallback(void) {
    ret_ = OH_VideoOutput_RegisterCallback(videoOutput_, GetVideoOutputListener());
    if (ret_ != CAMERA_OK) {
    }
    return ret_;
}

// Metadata Callback
void OnMetadataObjectAvailable(Camera_MetadataOutput *metadataOutput, Camera_MetadataObject *metadataObject,
                               uint32_t size) {}

void OnMetadataOutputError(Camera_MetadataOutput *metadataOutput, Camera_ErrorCode errorCode) {}

MetadataOutput_Callbacks *NDKCamera::GetMetadataOutputListener(void) {
    static MetadataOutput_Callbacks metadataOutputListener = {.onMetadataObjectAvailable = OnMetadataObjectAvailable,
                                                              .onError = OnMetadataOutputError};
    return &metadataOutputListener;
}

Camera_ErrorCode NDKCamera::MetadataOutputRegisterCallback(void) {
    ret_ = OH_MetadataOutput_RegisterCallback(metadataOutput_, GetMetadataOutputListener());
    if (ret_ != CAMERA_OK) {
    }
    return ret_;
}

// Session Callback
void CaptureSessionOnFocusStateChange(Camera_CaptureSession *session, Camera_FocusState focusState) {}

void CaptureSessionOnError(Camera_CaptureSession *session, Camera_ErrorCode errorCode) {}

CaptureSession_Callbacks *NDKCamera::GetCaptureSessionRegister(void) {
    static CaptureSession_Callbacks captureSessionCallbacks = {.onFocusStateChange = CaptureSessionOnFocusStateChange,
                                                               .onError = CaptureSessionOnError};
    return &captureSessionCallbacks;
}

Camera_ErrorCode NDKCamera::CaptureSessionRegisterCallback(void) {
    ret_ = OH_CaptureSession_RegisterCallback(captureSession_, GetCaptureSessionRegister());
    if (ret_ != CAMERA_OK) {
    }
    return ret_;
}
} // namespace OHOS_CAMERA_SAMPLE