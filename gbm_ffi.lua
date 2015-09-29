local ffi = require("ffi")

--[[
  Generic Buffer Manager (gbm)

  References
  https://github.com/robclark/libgbm

  Packages
    Ubuntu - libgbm-dev
--]]

ffi.cdef[[
struct gbm_device;
struct gbm_bo;
struct gbm_surface;

union gbm_bo_handle {
   void *ptr;
   int32_t s32;
   uint32_t u32;
   int64_t s64;
   uint64_t u64;
};

// Format of the allocated buffer
enum gbm_bo_format {
   // RGB with 8 bits per channel in a 32 bit value
   GBM_BO_FORMAT_XRGB8888, 
   // ARGB with 8 bits per channel in a 32 bit value
   GBM_BO_FORMAT_ARGB8888
};
]]





ffi.cdef[[
/*
 * Flags to indicate the intended use for the buffer - these are passed into
 * gbm_bo_create(). The caller must set the union of all the flags that are
 * appropriate
 *
 * \sa Use gbm_device_is_format_supported() to check if the combination of format
 * and use flags are supported
*/
enum gbm_bo_flags {
   GBM_BO_USE_SCANOUT      = (1 << 0),
   GBM_BO_USE_CURSOR       = (1 << 1),
   GBM_BO_USE_RENDERING    = (1 << 2),
   GBM_BO_USE_WRITE    = (1 << 3),
};
]]

ffi.cdef[[
int
gbm_device_get_fd(struct gbm_device *gbm);

const char *
gbm_device_get_backend_name(struct gbm_device *gbm);

int
gbm_device_is_format_supported(struct gbm_device *gbm,
                               uint32_t format, uint32_t usage);

void
gbm_device_destroy(struct gbm_device *gbm);

struct gbm_device *
gbm_create_device(int fd);

struct gbm_bo *
gbm_bo_create(struct gbm_device *gbm,
              uint32_t width, uint32_t height,
              uint32_t format, uint32_t flags);
]]


ffi.cdef[[
struct gbm_import_fd_data {
   int fd;
   uint32_t width;
   uint32_t height;
   uint32_t stride;
   uint32_t format;
};

struct gbm_bo *
gbm_bo_import(struct gbm_device *gbm, uint32_t type,
              void *buffer, uint32_t usage);

uint32_t
gbm_bo_get_width(struct gbm_bo *bo);

uint32_t
gbm_bo_get_height(struct gbm_bo *bo);

uint32_t
gbm_bo_get_stride(struct gbm_bo *bo);

uint32_t
gbm_bo_get_format(struct gbm_bo *bo);

struct gbm_device *
gbm_bo_get_device(struct gbm_bo *bo);

union gbm_bo_handle
gbm_bo_get_handle(struct gbm_bo *bo);

int
gbm_bo_get_fd(struct gbm_bo *bo);

int
gbm_bo_write(struct gbm_bo *bo, const void *buf, size_t count);

void
gbm_bo_set_user_data(struct gbm_bo *bo, void *data,
		     void (*destroy_user_data)(struct gbm_bo *, void *));

void *
gbm_bo_get_user_data(struct gbm_bo *bo);

void
gbm_bo_destroy(struct gbm_bo *bo);

struct gbm_surface *
gbm_surface_create(struct gbm_device *gbm,
                   uint32_t width, uint32_t height,
		   uint32_t format, uint32_t flags);

int
gbm_surface_needs_lock_front_buffer(struct gbm_surface *surface);

struct gbm_bo *
gbm_surface_lock_front_buffer(struct gbm_surface *surface);

void
gbm_surface_release_buffer(struct gbm_surface *surface, struct gbm_bo *bo);

int
gbm_surface_has_free_buffers(struct gbm_surface *surface);

void
gbm_surface_destroy(struct gbm_surface *surface);
]]

return ffi.load("gbm")

