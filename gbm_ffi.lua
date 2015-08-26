local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor;
local lshift = bit.lshift;

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

local Lib_gbm = ffi.load("gbm")



local function __gbm_fourcc_code(a,b,c,d) 
  return bor(bor(a, lshift(b, 8)), bor(lshift(c, 16), lshift(d, 24)));
end

local b = string.byte;

local exports = {
  Lib_gbm = Lib_gbm;

  -- Functions 
  gbm_bo_import = Lib_gbm.gbm_bo_import;
  gbm_bo_get_width = Lib_gbm.gbm_bo_get_width;
  gbm_bo_get_height = Lib_gbm.gbm_bo_get_height;
  gbm_bo_get_stride = Lib_gbm.gbm_bo_get_stride;
  gbm_bo_get_format = Lib_gbm.gbm_bo_get_format;
  gbm_bo_get_device = Lib_gbm.gbm_bo_get_device;
  gbm_bo_get_handle = Lib_gbm.gbm_bo_get_handle;
  gbm_bo_get_fd = Lib_gbm.gbm_bo_get_fd;
  gbm_bo_write = Lib_gbm.gbm_bo_write;
  gbm_bo_set_user_data = Lib_gbm.gbm_bo_set_user_data;
  gbm_bo_get_user_data = Lib_gbm.gbm_bo_get_user_data;
  gbm_bo_destroy = Lib_gbm.gbm_bo_destroy;
  gbm_surface_create = Lib_gbm.gbm_surface_create;
  --gbm_surface_needs_lock_front_buffer = Lib_gbm.gbm_surface_needs_lock_front_buffer;
  gbm_surface_lock_front_buffer = Lib_gbm.gbm_surface_lock_front_buffer;
  gbm_surface_release_buffer = Lib_gbm.gbm_surface_release_buffer;
  gbm_surface_has_free_buffers = Lib_gbm.gbm_surface_has_free_buffers;
  gbm_surface_destroy = Lib_gbm.gbm_surface_destroy;

  -- Constants
  GBM_BO_IMPORT_WL_BUFFER        = 0x5501;
  GBM_BO_IMPORT_EGL_IMAGE        = 0x5502;
  GBM_BO_IMPORT_FD               = 0x5503; 

	GBM_FORMAT_BIG_ENDIAN = lshift(1,31); -- format is big endian instead of little endian

--[[ color index --]]
	GBM_FORMAT_C8   = __gbm_fourcc_code(b'C', b'8', b' ', b' '); --[[ [7:0] C --]]

--[[ 8 bpp RGB --]]
	GBM_FORMAT_RGB332 = __gbm_fourcc_code(b'R', b'G', b'B', b'8'); --[[ [7:0] R:G:B 3:3:2 --]]
	GBM_FORMAT_BGR233 = __gbm_fourcc_code(b'B', b'G', b'R', b'8'); --[[ [7:0] B:G:R 2:3:3 --]]

--[[ 16 bpp RGB --]]
	GBM_FORMAT_XRGB4444 = __gbm_fourcc_code(b'X', b'R', b'1', b'2'); --[[ [15:0] x:R:G:B 4:4:4:4 little endian --]]
	GBM_FORMAT_XBGR4444 = __gbm_fourcc_code(b'X', b'B', b'1', b'2'); --[[ [15:0] x:B:G:R 4:4:4:4 little endian --]]
	GBM_FORMAT_RGBX4444 = __gbm_fourcc_code(b'R', b'X', b'1', b'2'); --[[ [15:0] R:G:B:x 4:4:4:4 little endian --]]
	GBM_FORMAT_BGRX4444 = __gbm_fourcc_code(b'B', b'X', b'1', b'2'); --[[ [15:0] B:G:R:x 4:4:4:4 little endian --]]

	GBM_FORMAT_ARGB4444 = __gbm_fourcc_code(b'A', b'R', b'1', b'2'); --[[ [15:0] A:R:G:B 4:4:4:4 little endian --]]
	GBM_FORMAT_ABGR4444 = __gbm_fourcc_code(b'A', b'B', b'1', b'2'); --[[ [15:0] A:B:G:R 4:4:4:4 little endian --]]
	GBM_FORMAT_RGBA4444 = __gbm_fourcc_code(b'R', b'A', b'1', b'2'); --[[ [15:0] R:G:B:A 4:4:4:4 little endian --]]
	GBM_FORMAT_BGRA4444 = __gbm_fourcc_code(b'B', b'A', b'1', b'2'); --[[ [15:0] B:G:R:A 4:4:4:4 little endian --]]

	GBM_FORMAT_XRGB1555 = __gbm_fourcc_code(b'X', b'R', b'1', b'5'); --[[ [15:0] x:R:G:B 1:5:5:5 little endian --]]
	GBM_FORMAT_XBGR1555 = __gbm_fourcc_code(b'X', b'B', b'1', b'5'); --[[ [15:0] x:B:G:R 1:5:5:5 little endian --]]
	GBM_FORMAT_RGBX5551 = __gbm_fourcc_code(b'R', b'X', b'1', b'5'); --[[ [15:0] R:G:B:x 5:5:5:1 little endian --]]
	GBM_FORMAT_BGRX5551 = __gbm_fourcc_code(b'B', b'X', b'1', b'5'); --[[ [15:0] B:G:R:x 5:5:5:1 little endian --]]

	GBM_FORMAT_ARGB1555 = __gbm_fourcc_code(b'A', b'R', b'1', b'5'); --[[ [15:0] A:R:G:B 1:5:5:5 little endian --]]
	GBM_FORMAT_ABGR1555 = __gbm_fourcc_code(b'A', b'B', b'1', b'5'); --[[ [15:0] A:B:G:R 1:5:5:5 little endian --]]
	GBM_FORMAT_RGBA5551 = __gbm_fourcc_code(b'R', b'A', b'1', b'5'); --[[ [15:0] R:G:B:A 5:5:5:1 little endian --]]
	GBM_FORMAT_BGRA5551 = __gbm_fourcc_code(b'B', b'A', b'1', b'5'); --[[ [15:0] B:G:R:A 5:5:5:1 little endian --]]

	GBM_FORMAT_RGB565 = __gbm_fourcc_code(b'R', b'G', b'1', b'6'); --[[ [15:0] R:G:B 5:6:5 little endian --]]
	GBM_FORMAT_BGR565 = __gbm_fourcc_code(b'B', b'G', b'1', b'6'); --[[ [15:0] B:G:R 5:6:5 little endian --]]

--[[ 24 bpp RGB --]]
	GBM_FORMAT_RGB888 = __gbm_fourcc_code(b'R', b'G', b'2', b'4'); --[[ [23:0] R:G:B little endian --]]
	GBM_FORMAT_BGR888 = __gbm_fourcc_code(b'B', b'G', b'2', b'4'); --[[ [23:0] B:G:R little endian --]]

--[[ 32 bpp RGB --]]
	GBM_FORMAT_XRGB8888 = __gbm_fourcc_code(b'X', b'R', b'2', b'4'); --[[ [31:0] x:R:G:B 8:8:8:8 little endian --]]
	GBM_FORMAT_XBGR8888 = __gbm_fourcc_code(b'X', b'B', b'2', b'4'); --[[ [31:0] x:B:G:R 8:8:8:8 little endian --]]
	GBM_FORMAT_RGBX8888 = __gbm_fourcc_code(b'R', b'X', b'2', b'4'); --[[ [31:0] R:G:B:x 8:8:8:8 little endian --]]
	GBM_FORMAT_BGRX8888 = __gbm_fourcc_code(b'B', b'X', b'2', b'4'); --[[ [31:0] B:G:R:x 8:8:8:8 little endian --]]

	GBM_FORMAT_ARGB8888 = __gbm_fourcc_code(b'A', b'R', b'2', b'4'); --[[ [31:0] A:R:G:B 8:8:8:8 little endian --]]
	GBM_FORMAT_ABGR8888 = __gbm_fourcc_code(b'A', b'B', b'2', b'4'); --[[ [31:0] A:B:G:R 8:8:8:8 little endian --]]
	GBM_FORMAT_RGBA8888 = __gbm_fourcc_code(b'R', b'A', b'2', b'4'); --[[ [31:0] R:G:B:A 8:8:8:8 little endian --]]
	GBM_FORMAT_BGRA8888 = __gbm_fourcc_code(b'B', b'A', b'2', b'4'); --[[ [31:0] B:G:R:A 8:8:8:8 little endian --]]

	GBM_FORMAT_XRGB2101010  = __gbm_fourcc_code(b'X', b'R', b'3', b'0'); --[[ [31:0] x:R:G:B 2:10:10:10 little endian --]]
	GBM_FORMAT_XBGR2101010  = __gbm_fourcc_code(b'X', b'B', b'3', b'0'); --[[ [31:0] x:B:G:R 2:10:10:10 little endian --]]
	GBM_FORMAT_RGBX1010102  = __gbm_fourcc_code(b'R', b'X', b'3', b'0'); --[[ [31:0] R:G:B:x 10:10:10:2 little endian --]]
	GBM_FORMAT_BGRX1010102  = __gbm_fourcc_code(b'B', b'X', b'3', b'0'); --[[ [31:0] B:G:R:x 10:10:10:2 little endian --]]

	GBM_FORMAT_ARGB2101010  = __gbm_fourcc_code(b'A', b'R', b'3', b'0'); --[[ [31:0] A:R:G:B 2:10:10:10 little endian --]]
	GBM_FORMAT_ABGR2101010  = __gbm_fourcc_code(b'A', b'B', b'3', b'0'); --[[ [31:0] A:B:G:R 2:10:10:10 little endian --]]
	GBM_FORMAT_RGBA1010102  = __gbm_fourcc_code(b'R', b'A', b'3', b'0'); --[[ [31:0] R:G:B:A 10:10:10:2 little endian --]]
	GBM_FORMAT_BGRA1010102  = __gbm_fourcc_code(b'B', b'A', b'3', b'0'); --[[ [31:0] B:G:R:A 10:10:10:2 little endian --]]

--[[ packed YCbCr --]]
	GBM_FORMAT_YUYV   = __gbm_fourcc_code(b'Y', b'U', b'Y', b'V'); --[[ [31:0] Cr0:Y1:Cb0:Y0 8:8:8:8 little endian --]]
	GBM_FORMAT_YVYU   = __gbm_fourcc_code(b'Y', b'V', b'Y', b'U'); --[[ [31:0] Cb0:Y1:Cr0:Y0 8:8:8:8 little endian --]]
	GBM_FORMAT_UYVY   = __gbm_fourcc_code(b'U', b'Y', b'V', b'Y'); --[[ [31:0] Y1:Cr0:Y0:Cb0 8:8:8:8 little endian --]]
	GBM_FORMAT_VYUY   = __gbm_fourcc_code(b'V', b'Y', b'U', b'Y'); --[[ [31:0] Y1:Cb0:Y0:Cr0 8:8:8:8 little endian --]]

	GBM_FORMAT_AYUV   = __gbm_fourcc_code(b'A', b'Y', b'U', b'V'); --[[ [31:0] A:Y:Cb:Cr 8:8:8:8 little endian --]]

--[[
 * 2 plane YCbCr
 * index 0 = Y plane, [7:0] Y
 * index 1 = Cr:Cb plane, [15:0] Cr:Cb little endian
 * or
 * index 1 = Cb:Cr plane, [15:0] Cb:Cr little endian
 --]]
	GBM_FORMAT_NV12   = __gbm_fourcc_code(b'N', b'V', b'1', b'2'); --[[ 2x2 subsampled Cr:Cb plane --]]
	GBM_FORMAT_NV21   = __gbm_fourcc_code(b'N', b'V', b'2', b'1'); --[[ 2x2 subsampled Cb:Cr plane --]]
	GBM_FORMAT_NV16   = __gbm_fourcc_code(b'N', b'V', b'1', b'6'); --[[ 2x1 subsampled Cr:Cb plane --]]
	GBM_FORMAT_NV61   = __gbm_fourcc_code(b'N', b'V', b'6', b'1'); --[[ 2x1 subsampled Cb:Cr plane --]]

--[[
 * 3 plane YCbCr
 * index 0: Y plane, [7:0] Y
 * index 1: Cb plane, [7:0] Cb
 * index 2: Cr plane, [7:0] Cr
 * or
 * index 1: Cr plane, [7:0] Cr
 * index 2: Cb plane, [7:0] Cb
 --]]
	GBM_FORMAT_YUV410 = __gbm_fourcc_code(b'Y', b'U', b'V', b'9'); --[[ 4x4 subsampled Cb (1) and Cr (2) planes --]]
	GBM_FORMAT_YVU410 = __gbm_fourcc_code(b'Y', b'V', b'U', b'9'); --[[ 4x4 subsampled Cr (1) and Cb (2) planes --]]
	GBM_FORMAT_YUV411 = __gbm_fourcc_code(b'Y', b'U', b'1', b'1'); --[[ 4x1 subsampled Cb (1) and Cr (2) planes --]]
	GBM_FORMAT_YVU411 = __gbm_fourcc_code(b'Y', b'V', b'1', b'1'); --[[ 4x1 subsampled Cr (1) and Cb (2) planes --]]
	GBM_FORMAT_YUV420 = __gbm_fourcc_code(b'Y', b'U', b'1', b'2'); --[[ 2x2 subsampled Cb (1) and Cr (2) planes --]]
	GBM_FORMAT_YVU420 = __gbm_fourcc_code(b'Y', b'V', b'1', b'2'); --[[ 2x2 subsampled Cr (1) and Cb (2) planes --]]
	GBM_FORMAT_YUV422 = __gbm_fourcc_code(b'Y', b'U', b'1', b'6'); --[[ 2x1 subsampled Cb (1) and Cr (2) planes --]]
	GBM_FORMAT_YVU422 = __gbm_fourcc_code(b'Y', b'V', b'1', b'6'); --[[ 2x1 subsampled Cr (1) and Cb (2) planes --]]
	GBM_FORMAT_YUV444 = __gbm_fourcc_code(b'Y', b'U', b'2', b'4'); --[[ non-subsampled Cb (1) and Cr (2) planes --]]
	GBM_FORMAT_YVU444 = __gbm_fourcc_code(b'Y', b'V', b'2', b'4'); --[[ non-subsampled Cr (1) and Cb (2) planes --]]


}

setmetatable(exports, {
  __call = function(self, ...)
    for k,v in pairs(Constants) do
      _G[k] = v;
    end

    for k,v in pairs(Functions) do
      _G[k] = v;
    end

    return self;
  end,
})

return exports
