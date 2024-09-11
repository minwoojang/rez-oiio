name = "oiio"

version = "2.5.15.0"

private_build_requires = [
    "pybind11-2"
]

requires = [
    "boost-1.82",
    "openexr-3.2",
    "ocio-2.3",
    "jpegturbo-2",
    "libpng-1",
    "libraw-0.21",
    "ffmpeg-5.1",
    "tbb-2020"
]

def pre_build_commands():
    env.Boost_ROOT = env.BOOST_ROOT
    env.Python_ROOT = env.PYTHON_ROOT
    env.Ffmpeg_ROOT = env.FFMPEG_ROOT
    unsetenv("BOOST_ROOT")
    unsetenv("PYTHON_ROOT")
    unsetenv("FFMPEG_ROOT")
    unsetenv("PYBIND11_ROOT")
    env.CMAKE_PREFIX_PATH.append(env.REZ_JPEGTURBO_ROOT)
    #setenv("libjpeg-turbo", env.REZ_JPEGTURBO_ROOT)

    # We explicitly disable some dependencies as we
    # don't want them to be accidentally picked up
    env.DISABLE_OPENCV="1"
    env.DISABLE_GIF="1"
    env.DISABLE_OPENVDB="1"
    env.DISABLE_R3DSDK="1"
    env.DISABLE_NUKE="1"
    env.DISABLE_QT6="1"
    env.DISABLE_QT5="1"
    env.DISABLE_PTEX="1"
    #env.DISABLE_DCMTK="1"
    #env.DISABLE_LIBHEIF="1"
    env.DISABLE_HEIF="1"
    env.DISABLE_WEBP="1"
    env.DISABLE_DICOM="1"
    env.DISABLE_IV="1"
    env.DISABLE_OPENJPEG="1"


build_requires = [
    "cmake-3.15+<4",
    "gcctoolset-9",
]

variants = [
    ["platform-linux", "python-3.10"],
    ["platform-linux", "python-3.11"],

]

build_command = "make -f {root}/Makefile {install}"

def commands():
    env.PATH.append("{root}/bin")
    env.LD_LIBRARY_PATH.append("{root}/lib64")
    env.PYTHONPATH.append(
        "{root}/lib64/python{resolve.python.version.major}.{resolve.python.version.minor}/site-packages"
    )
    if building:
        env.OpenImageIO_ROOT = "{root}" # CMake Hint

tests = {
    "python": {
        "command": """
        python -c "import OpenImageIO as oiio; assert oiio.VERSION_STRING == '{version}'"
        """,
        "run_on": [
            "pre_install",
            "pre_release",
        ],
        "on_variants": True
    },
}
