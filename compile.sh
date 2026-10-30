#!/usr/bin/env bash
PHP_VERSIONS=("7.0.33" "7.2.34" "7.3.33" "7.4.33")
PHP_VERSION_BASE="auto"

# ---- shared base ----
ZLIB_VERSION="1.3"
LIBDEFLATE_VERSION="dd12ff2b36d603dbb7fa8838fe7e7176fcbd4f6f"

OPENSSL_VERSION=""
CURL_VERSION=""
YAML_VERSION=""
GMP_VERSION=""
LIBPNG_VERSION=""
LIBJPEG_VERSION=""
SQLITE3_VERSION=""
LIBZIP_VERSION=""
LIBXML_VERSION=""

EXT_PTHREADS_VERSION=""
EXT_YAML_VERSION=""
EXT_LEVELDB_VERSION=""
EXT_CHUNKUTILS_VERSION=""
EXT_XDEBUG_VERSION=""
EXT_IGBINARY_VERSION=""
EXT_CRYPTO_VERSION=""
EXT_RECURSIONGUARD_VERSION=""
EXT_DS_VERSION=""
EXT_WEAKREF_VERSION=""

# ---- 7.0 (reference: 7.0.23) ----
OPENSSL_VERSION_70="1.1.1w"
CURL_VERSION_70="curl-7_71_1"
YAML_VERSION_70="0.2.2"
GMP_VERSION_70="6.1.2"
LIBPNG_VERSION_70="1.6.37"
LIBJPEG_VERSION_70="9c"
SQLITE3_VERSION_70="3140200"
LIBZIP_VERSION_70="1.8.0"
EXT_PTHREADS_VERSION_70="3.1.6"
EXT_YAML_VERSION_70="2.0.2"
EXT_LEVELDB_VERSION_70=""
EXT_CHUNKUTILS_VERSION_70=""
EXT_XDEBUG_VERSION_70=""
EXT_IGBINARY_VERSION_70=""
EXT_CRYPTO_VERSION_70=""
EXT_RECURSIONGUARD_VERSION_70=""
EXT_DS_VERSION_70="1.2.9"
EXT_WEAKREF_VERSION_70="0.3.3"

# ---- 7.2 (reference: 7.2.20) ----
OPENSSL_VERSION_72="1.1.1w"
CURL_VERSION_72="curl-7_71_1"
YAML_VERSION_72="0.2.4"
GMP_VERSION_72="6.1.2"
LIBPNG_VERSION_72="1.6.37"
LIBJPEG_VERSION_72="9c"
SQLITE3_VERSION_72="3200100"
LIBZIP_VERSION_72="1.8.0"
EXT_PTHREADS_VERSION_72="3.2.0"
EXT_YAML_VERSION_72="2.0.4"
EXT_LEVELDB_VERSION_72="1c7564468b41610da4f498430e795ca4de0931ff"
EXT_CHUNKUTILS_VERSION_72=""
EXT_XDEBUG_VERSION_72=""
EXT_IGBINARY_VERSION_72="3.0.1"
EXT_CRYPTO_VERSION_72="0.3.1"
EXT_RECURSIONGUARD_VERSION_72="0.1.0"
EXT_DS_VERSION_72="1.2.9"
EXT_WEAKREF_VERSION_72=""

# ---- 7.3 (reference: 7.3.7) ----
OPENSSL_VERSION_73="1.1.1w"
CURL_VERSION_73="curl-7_71_1"
YAML_VERSION_73="0.2.4"
GMP_VERSION_73="6.1.2"
LIBPNG_VERSION_73="1.6.37"
LIBJPEG_VERSION_73="9c"
SQLITE3_VERSION_73="3240000"
LIBZIP_VERSION_73="1.8.0"
EXT_PTHREADS_VERSION_73="3.2.0"
EXT_YAML_VERSION_73="2.0.4"
EXT_LEVELDB_VERSION_73="1c7564468b41610da4f498430e795ca4de0931ff"
EXT_CHUNKUTILS_VERSION_73="0.3.5"
EXT_XDEBUG_VERSION_73=""
EXT_IGBINARY_VERSION_73="3.0.1"
EXT_CRYPTO_VERSION_73="0.3.1"
EXT_RECURSIONGUARD_VERSION_73="0.1.0"
EXT_DS_VERSION_73="1.2.9"
EXT_WEAKREF_VERSION_73=""

# ---- 7.4 (reference: 7.4.22) ----
OPENSSL_VERSION_74="1.1.1w"
CURL_VERSION_74="curl-7_71_1"
YAML_VERSION_74="0.2.5"
GMP_VERSION_74="6.2.1"
LIBPNG_VERSION_74="1.6.37"
LIBJPEG_VERSION_74="9c"
SQLITE3_VERSION_74="3360000"
LIBZIP_VERSION_74="1.8.0"
EXT_PTHREADS_VERSION_74="3.2.0"
EXT_YAML_VERSION_74="2.2.1"
EXT_LEVELDB_VERSION_74="1c7564468b41610da4f498430e795ca4de0931ff"
EXT_CHUNKUTILS_VERSION_74=""
EXT_XDEBUG_VERSION_74=""
EXT_IGBINARY_VERSION_74="3.2.4"
EXT_CRYPTO_VERSION_74="0.3.2"
EXT_RECURSIONGUARD_VERSION_74="0.1.0"
EXT_DS_VERSION_74=""
EXT_WEAKREF_VERSION_74=""

function write_out()   { echo "[$1] $2"; }
function write_error() { write_out ERROR "$1" >&2; }
function write_status() { echo -n " $1..."; }
function write_library() { echo -n "[$1 $2]"; }
function write_caching()  { write_status "using cache"; }
function write_download() { write_status "downloading"; }
function write_configure(){ write_status "configuring"; }
function write_compile()  { write_status "compiling"; }
function write_install()  { write_status "installing"; }
function write_done()     { echo " done!"; }
function cant_use_cache { [ -f "$1/.compile.sh.cache" ] && return 1; return 0; }
function mark_cache { touch "./.compile.sh.cache"; }

write_out "PocketMine" "PHP 7.x compiler (legacy / old cores)"
DIR="$(pwd)"
BASE_BUILD_DIR="$DIR/install_data"
BUILD_DIR="$BASE_BUILD_DIR/subdir"
LIB_BUILD_DIR="$BUILD_DIR/lib"
INSTALL_DIR="$DIR/bin/php7"

date > "$DIR/install.log" 2>&1
uname -a >> "$DIR/install.log" 2>&1

write_out "INFO" "Checking dependencies"
DEPS=( make autoconf automake m4 getconf gzip bzip2 bison g++ git cmake pkg-config re2c libtool )
ERRORS=0
for d in "${DEPS[@]}"; do
	type "$d" >> "$DIR/install.log" 2>&1 || { write_error "Please install \"$d\""; ((ERRORS++)); }
done
type wget >> "$DIR/install.log" 2>&1 || type curl >> "$DIR/install.log" 2>&1 || { write_error "Need wget or curl"; ((ERRORS++)); }
if [ $ERRORS -ne 0 ]; then exit 1; fi

export CC="gcc"
export CXX="g++"
export RANLIB=ranlib

COMPILE_FOR_ANDROID=no
HAVE_MYSQLI="--enable-mysqlnd --with-mysqli=mysqlnd"
COMPILE_TARGET=""
IS_CROSSCOMPILE="no"
IS_WINDOWS="no"
DO_OPTIMIZE="yes"
DO_STATIC="no"
DO_CLEANUP="yes"
COMPILE_DEBUG="no"
HAVE_VALGRIND="--without-valgrind"
HAVE_OPCACHE="no"
COMPILE_GD="no"
PM_VERSION_MAJOR=""
DOWNLOAD_INSECURE="no"
DOWNLOAD_CACHE=""
SEPARATE_SYMBOLS="no"

while getopts "::t:j:sdDxfgnva:P:c:l:gz:" OPTION; do
	case $OPTION in
		l) mkdir "$OPTARG" 2>/dev/null; LIB_BUILD_DIR="$(cd $OPTARG; pwd)";;
		c) mkdir "$OPTARG" 2>/dev/null; DOWNLOAD_CACHE="$(cd $OPTARG; pwd)";;
		t) COMPILE_TARGET="$OPTARG";;
		j) THREADS="$OPTARG";;
		d) COMPILE_DEBUG="yes"; DO_CLEANUP="no"; DO_OPTIMIZE="no"; CFLAGS="$CFLAGS -g";;
		D) SEPARATE_SYMBOLS="yes"; CFLAGS="$CFLAGS -g";;
		x) IS_CROSSCOMPILE="yes";;
		s) DO_STATIC="yes"; CFLAGS="$CFLAGS -static";;
		f) : ;;
		g) COMPILE_GD="yes";;
		n) DO_CLEANUP="no";;
		v) HAVE_VALGRIND="--with-valgrind";;
		a) FSANITIZE_OPTIONS="$OPTARG";;
		P) PM_VERSION_MAJOR="$OPTARG";;
		i) DOWNLOAD_INSECURE="yes";;
		z) PHP_VERSION_BASE="$OPTARG";;
		\?) write_error "Invalid option: -$OPTARG"; exit 1;;
	esac
done

if [ "$PM_VERSION_MAJOR" == "" ]; then
	write_error "Please specify PocketMine-MP major version target with -P (e.g. -P3)"
	exit 1
fi

if [ "$PHP_VERSION_BASE" == "auto" ]; then PHP_VERSION_BASE="7.3"; fi

PHP_VERSION=""
for v in "${PHP_VERSIONS[@]}"; do
	if [[ "$v" == "$PHP_VERSION_BASE."* ]]; then PHP_VERSION="$v"; break; fi
done
if [ "$PHP_VERSION" == "" ]; then
	write_error "Unsupported PHP base version $PHP_VERSION_BASE (supported: 7.0, 7.2, 7.3, 7.4)"
	exit 1
fi

case "$PHP_VERSION" in
	7.0.*)
		OPENSSL_VERSION="$OPENSSL_VERSION_70"; CURL_VERSION="$CURL_VERSION_70"
		YAML_VERSION="$YAML_VERSION_70"; GMP_VERSION="$GMP_VERSION_70"
		LIBPNG_VERSION="$LIBPNG_VERSION_70"; LIBJPEG_VERSION="$LIBJPEG_VERSION_70"
		SQLITE3_VERSION="$SQLITE3_VERSION_70"; LIBZIP_VERSION="$LIBZIP_VERSION_70"
		EXT_PTHREADS_VERSION="$EXT_PTHREADS_VERSION_70"; EXT_YAML_VERSION="$EXT_YAML_VERSION_70"
		EXT_LEVELDB_VERSION="$EXT_LEVELDB_VERSION_70"; EXT_CHUNKUTILS_VERSION="$EXT_CHUNKUTILS_VERSION_70"
		EXT_XDEBUG_VERSION="$EXT_XDEBUG_VERSION_70"; EXT_IGBINARY_VERSION="$EXT_IGBINARY_VERSION_70"
		EXT_CRYPTO_VERSION="$EXT_CRYPTO_VERSION_70"; EXT_RECURSIONGUARD_VERSION="$EXT_RECURSIONGUARD_VERSION_70"
		EXT_DS_VERSION="$EXT_DS_VERSION_70"; EXT_WEAKREF_VERSION="$EXT_WEAKREF_VERSION_70"
		;;
	7.2.*)
		OPENSSL_VERSION="$OPENSSL_VERSION_72"; CURL_VERSION="$CURL_VERSION_72"
		YAML_VERSION="$YAML_VERSION_72"; GMP_VERSION="$GMP_VERSION_72"
		LIBPNG_VERSION="$LIBPNG_VERSION_72"; LIBJPEG_VERSION="$LIBJPEG_VERSION_72"
		SQLITE3_VERSION="$SQLITE3_VERSION_72"; LIBZIP_VERSION="$LIBZIP_VERSION_72"
		EXT_PTHREADS_VERSION="$EXT_PTHREADS_VERSION_72"; EXT_YAML_VERSION="$EXT_YAML_VERSION_72"
		EXT_LEVELDB_VERSION="$EXT_LEVELDB_VERSION_72"; EXT_CHUNKUTILS_VERSION="$EXT_CHUNKUTILS_VERSION_72"
		EXT_XDEBUG_VERSION="$EXT_XDEBUG_VERSION_72"; EXT_IGBINARY_VERSION="$EXT_IGBINARY_VERSION_72"
		EXT_CRYPTO_VERSION="$EXT_CRYPTO_VERSION_72"; EXT_RECURSIONGUARD_VERSION="$EXT_RECURSIONGUARD_VERSION_72"
		EXT_DS_VERSION="$EXT_DS_VERSION_72"; EXT_WEAKREF_VERSION="$EXT_WEAKREF_VERSION_72"
		;;
	7.3.*)
		OPENSSL_VERSION="$OPENSSL_VERSION_73"; CURL_VERSION="$CURL_VERSION_73"
		YAML_VERSION="$YAML_VERSION_73"; GMP_VERSION="$GMP_VERSION_73"
		LIBPNG_VERSION="$LIBPNG_VERSION_73"; LIBJPEG_VERSION="$LIBJPEG_VERSION_73"
		SQLITE3_VERSION="$SQLITE3_VERSION_73"; LIBZIP_VERSION="$LIBZIP_VERSION_73"
		EXT_PTHREADS_VERSION="$EXT_PTHREADS_VERSION_73"; EXT_YAML_VERSION="$EXT_YAML_VERSION_73"
		EXT_LEVELDB_VERSION="$EXT_LEVELDB_VERSION_73"; EXT_CHUNKUTILS_VERSION="$EXT_CHUNKUTILS_VERSION_73"
		EXT_XDEBUG_VERSION="$EXT_XDEBUG_VERSION_73"; EXT_IGBINARY_VERSION="$EXT_IGBINARY_VERSION_73"
		EXT_CRYPTO_VERSION="$EXT_CRYPTO_VERSION_73"; EXT_RECURSIONGUARD_VERSION="$EXT_RECURSIONGUARD_VERSION_73"
		EXT_DS_VERSION="$EXT_DS_VERSION_73"; EXT_WEAKREF_VERSION="$EXT_WEAKREF_VERSION_73"
		;;
	7.4.*)
		OPENSSL_VERSION="$OPENSSL_VERSION_74"; CURL_VERSION="$CURL_VERSION_74"
		YAML_VERSION="$YAML_VERSION_74"; GMP_VERSION="$GMP_VERSION_74"
		LIBPNG_VERSION="$LIBPNG_VERSION_74"; LIBJPEG_VERSION="$LIBJPEG_VERSION_74"
		SQLITE3_VERSION="$SQLITE3_VERSION_74"; LIBZIP_VERSION="$LIBZIP_VERSION_74"
		EXT_PTHREADS_VERSION="$EXT_PTHREADS_VERSION_74"; EXT_YAML_VERSION="$EXT_YAML_VERSION_74"
		EXT_LEVELDB_VERSION="$EXT_LEVELDB_VERSION_74"; EXT_CHUNKUTILS_VERSION="$EXT_CHUNKUTILS_VERSION_74"
		EXT_XDEBUG_VERSION="$EXT_XDEBUG_VERSION_74"; EXT_IGBINARY_VERSION="$EXT_IGBINARY_VERSION_74"
		EXT_CRYPTO_VERSION="$EXT_CRYPTO_VERSION_74"; EXT_RECURSIONGUARD_VERSION="$EXT_RECURSIONGUARD_VERSION_74"
		EXT_DS_VERSION="$EXT_DS_VERSION_74"; EXT_WEAKREF_VERSION="$EXT_WEAKREF_VERSION_74"
		;;
	*) write_error "Unhandled PHP version $PHP_VERSION"; exit 1;;
esac

write_out "opt" "Selected PHP $PHP_VERSION (OpenSSL $OPENSSL_VERSION, curl $CURL_VERSION, pthreads $EXT_PTHREADS_VERSION)"

shopt -s expand_aliases
if type wget >/dev/null 2>&1; then
	WGET_FLAGS=""
	[ "$DOWNLOAD_INSECURE" == "yes" ] && WGET_FLAGS="--no-check-certificate"
	alias _download_file="wget $WGET_FLAGS -nv -O -"
else
	CURL_FLAGS=""
	[ "$DOWNLOAD_INSECURE" == "yes" ] && CURL_FLAGS="--insecure"
	alias _download_file="curl $CURL_FLAGS --silent --show-error --location --globoff"
fi

function download_file {
	local url="$1" prefix="$2" cache="$prefix-${url##*/}"
	if [ -n "$DOWNLOAD_CACHE" ]; then
		mkdir -p "$DOWNLOAD_CACHE" >> "$DIR/install.log" 2>&1
		if [ ! -f "$DOWNLOAD_CACHE/$cache" ]; then
			_download_file "$url" > "$DOWNLOAD_CACHE/.temp" 2>> "$DIR/install.log"
			mv "$DOWNLOAD_CACHE/.temp" "$DOWNLOAD_CACHE/$cache" >> "$DIR/install.log" 2>&1
		fi
		cat "$DOWNLOAD_CACHE/$cache"
	else
		_download_file "$url" 2>> "$DIR/install.log"
	fi
}
function download_github_src { download_file "https://github.com/$1/archive/$2.tar.gz" "$3"; }

GMP_ABI=""
TOOLCHAIN_PREFIX=""
OPENSSL_TARGET=""
CMAKE_GLOBAL_EXTRA_FLAGS="-DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DBUILD_SHARED=OFF -DBUILD_SHARED_LIBS=OFF"

if [ "$IS_CROSSCOMPILE" == "yes" ]; then
	export CROSS_COMPILER="$PATH"
	if [ "$COMPILE_TARGET" == "android-aarch64" ]; then
		COMPILE_FOR_ANDROID=yes
		[ -z "$march" ] && march="armv8-a"
		[ -z "$mtune" ] && mtune=generic
		TOOLCHAIN_PREFIX="aarch64-linux-musl"
		CONFIGURE_FLAGS="--host=$TOOLCHAIN_PREFIX"
		CFLAGS="-static $CFLAGS"
		CXXFLAGS="-static $CXXFLAGS"
		LDFLAGS="-static -static-libgcc -Wl,-static"
		DO_STATIC="yes"
		OPENSSL_TARGET="linux-aarch64"
		export ac_cv_func_fnmatch_works=yes
		write_out "INFO" "Cross-compiling for Android ARMv8 (aarch64)"
	else
		write_error "Only android-aarch64 is supported for cross-compile"; exit 1
	fi
else
	if [[ "$COMPILE_TARGET" == "linux" ]] || [[ "$COMPILE_TARGET" == "linux64" ]]; then
		[ -z "$march" ] && march=x86-64
		[ -z "$mtune" ] && mtune=skylake
		CFLAGS="$CFLAGS -m64"; GMP_ABI="64"
		OPENSSL_TARGET="linux-x86_64"
	elif [[ "$COMPILE_TARGET" != "" ]]; then
		write_error "Unsupported compile target $COMPILE_TARGET"; exit 1
	elif [ -z "$CFLAGS" ]; then
		if [ `getconf LONG_BIT` == "64" ]; then
			[ "$(uname -m)" != "aarch64" ] && CFLAGS="-m64 $CFLAGS"
			GMP_ABI="64"
		else write_error "32-bit is not supported"; exit 1; fi
	fi
fi

if [ "$DO_STATIC" == "yes" ]; then HAVE_OPCACHE="no"; fi

if [ "$TOOLCHAIN_PREFIX" != "" ]; then
	export CC="$TOOLCHAIN_PREFIX-gcc"
	export CXX="$TOOLCHAIN_PREFIX-g++"
	export AR="$TOOLCHAIN_PREFIX-ar"
	export RANLIB="$TOOLCHAIN_PREFIX-ranlib"
	export CPP="$TOOLCHAIN_PREFIX-cpp"
	export LD="$TOOLCHAIN_PREFIX-ld"
fi

[ -z "$THREADS" ] && THREADS=1
[ -z "$march" ] && march=native
[ -z "$mtune" ] && mtune=native
[ -z "$CFLAGS" ] && CFLAGS=""
[ -z "$CONFIGURE_FLAGS" ] && CONFIGURE_FLAGS=""
[ -z "$LDFLAGS" ] && LDFLAGS=""

if [ "$DO_OPTIMIZE" != "no" ]; then
	CFLAGS="$CFLAGS -O2 -ffast-math -ftree-vectorize -fomit-frame-pointer -funswitch-loops -fivopts -funsafe-loop-optimizations -fpredictive-commoning -ftracer -ftree-loop-im -frename-registers -fcx-limited-range"
fi

export CC CXX CFLAGS CXXFLAGS LDFLAGS CPPFLAGS
export CFLAGS="-O2 -fPIC $CFLAGS"
export CXXFLAGS="$CFLAGS $CXXFLAGS"
export LIBRARY_PATH="$INSTALL_DIR/lib:$LIBRARY_PATH"
export PKG_CONFIG_PATH="$INSTALL_DIR/lib/pkgconfig"
export PKG_CONFIG_ALLOW_SYSTEM_LIBS="yes"
export PKG_CONFIG_ALLOW_SYSTEM_CFLAGS="yes"

rm -rf "$BASE_BUILD_DIR" bin/ >> "$DIR/install.log" 2>&1
mkdir -p "$BUILD_DIR" "$LIB_BUILD_DIR" "$INSTALL_DIR" >> "$DIR/install.log" 2>&1
cd "$BUILD_DIR"
set -e

write_library "PHP" "$PHP_VERSION"
write_download
download_github_src "php/php-src" "php-$PHP_VERSION" "php" | tar -zx >> "$DIR/install.log" 2>&1
mv php-src-php-$PHP_VERSION php
write_done

# ----- library builds -----
function build_zlib {
	[ "$DO_STATIC" == "yes" ] && local EXTRA="--static" || local EXTRA="--shared"
	write_library zlib "$ZLIB_VERSION"
	local d="./zlib-$ZLIB_VERSION"
	if cant_use_cache "$d"; then
		rm -rf "$d"; write_download
		download_github_src "madler/zlib" "v$ZLIB_VERSION" "zlib" | tar -zx >> "$DIR/install.log" 2>&1
		write_configure; cd "$d"
		RANLIB=$RANLIB ./configure --prefix="$INSTALL_DIR" $EXTRA >> "$DIR/install.log" 2>&1
		write_compile; make -j $THREADS >> "$DIR/install.log" 2>&1 && mark_cache
	else write_caching; cd "$d"; fi
	write_install; make install >> "$DIR/install.log" 2>&1; cd ..
	[ "$DO_STATIC" != "yes" ] && rm -f "$INSTALL_DIR/lib/libz.a"
	write_done
}

function build_gmp {
	export jm_cv_func_working_malloc=yes ac_cv_func_malloc_0_nonnull=yes
	export jm_cv_func_working_realloc=yes ac_cv_func_realloc_0_nonnull=yes
	[ "$IS_CROSSCOMPILE" == "yes" ] && local EXTRA="" || local EXTRA="--disable-assembly"
	write_library gmp "$GMP_VERSION"
	local d="./gmp-$GMP_VERSION"
	if cant_use_cache "$d"; then
		rm -rf "$d"; write_download
		download_file "https://github.com/YoutuberPlay/PHP-Binaries/releases/download/pm3/gmp-$GMP_VERSION.tar.xz" "gmp" | tar -Jx >> "$DIR/install.log" 2>&1
		write_configure; cd "$d"
		RANLIB=$RANLIB ./configure --prefix="$INSTALL_DIR" $EXTRA \
			--disable-posix-threads --enable-static --disable-shared \
			$CONFIGURE_FLAGS ABI="$GMP_ABI" >> "$DIR/install.log" 2>&1
		write_compile; make -j $THREADS >> "$DIR/install.log" 2>&1 && mark_cache
	else write_caching; cd "$d"; fi
	write_install; make install >> "$DIR/install.log" 2>&1; cd ..
	write_done
}

function build_openssl {
	OPENSSL_CMD="./config"
	[ "$OPENSSL_TARGET" != "" ] && local OPENSSL_CMD="./Configure $OPENSSL_TARGET"
	[ "$DO_STATIC" == "yes" ] && local EXTRA="no-shared -static" || local EXTRA="shared"
	write_library openssl "$OPENSSL_VERSION"
	local d="./openssl-$OPENSSL_VERSION"
	if cant_use_cache "$d"; then
		rm -rf "$d"; write_download
		download_file "https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz" "openssl" | tar -zx >> "$DIR/install.log" 2>&1
		write_configure; cd "$d"
		RANLIB=$RANLIB $OPENSSL_CMD --prefix="$INSTALL_DIR" --openssldir="$INSTALL_DIR" \
			--libdir="$INSTALL_DIR/lib" no-asm no-hw no-engine $EXTRA >> "$DIR/install.log" 2>&1
		write_compile; make -j $THREADS >> "$DIR/install.log" 2>&1 && mark_cache
	else write_caching; cd "$d"; fi
	write_install; make install_sw >> "$DIR/install.log" 2>&1; cd ..
	write_done
}

function build_curl {
	[ "$DO_STATIC" == "yes" ] && local EXTRA="--enable-static --disable-shared" || local EXTRA="--disable-static --enable-shared"
	write_library curl "$CURL_VERSION"
	local d="./curl-$CURL_VERSION"
	if cant_use_cache "$d"; then
		rm -rf "$d"; write_download
		download_github_src "curl/curl" "$CURL_VERSION" "curl" | tar -zx >> "$DIR/install.log" 2>&1
		write_configure; cd "$d"
		./buildconf --force >> "$DIR/install.log" 2>&1
		RANLIB=$RANLIB ./configure --disable-dependency-tracking \
			--enable-ipv6 --enable-optimize --enable-http --enable-ftp \
			--disable-dict --enable-file --without-librtmp --disable-gopher \
			--disable-imap --disable-pop3 --disable-rtsp --disable-smtp \
			--disable-telnet --disable-tftp --disable-ldap --disable-ldaps \
			--without-libidn --without-libidn2 --without-brotli --without-nghttp2 \
			--without-zstd --with-zlib="$INSTALL_DIR" --with-ssl="$INSTALL_DIR" \
			--enable-threaded-resolver --prefix="$INSTALL_DIR" \
			$EXTRA $CONFIGURE_FLAGS >> "$DIR/install.log" 2>&1
		write_compile; make -j $THREADS >> "$DIR/install.log" 2>&1 && mark_cache
	else write_caching; cd "$d"; fi
	write_install; make install >> "$DIR/install.log" 2>&1; cd ..
	write_done
}

function build_yaml {
	[ "$DO_STATIC" == "yes" ] && local EXTRA="--disable-shared --enable-static" || local EXTRA="--enable-shared --disable-static"
	write_library yaml "$YAML_VERSION"
	local d="./libyaml-$YAML_VERSION"
	if cant_use_cache "$d"; then
		rm -rf "$d"; write_download
		download_github_src "yaml/libyaml" "$YAML_VERSION" "yaml" | tar -zx >> "$DIR/install.log" 2>&1
		cd "$d"; ./bootstrap >> "$DIR/install.log" 2>&1
		write_configure
		RANLIB=$RANLIB ./configure --prefix="$INSTALL_DIR" $EXTRA $CONFIGURE_FLAGS >> "$DIR/install.log" 2>&1
		sed -i=".bak" 's/ tests win32/ win32/g' Makefile 2>/dev/null || true
		write_compile; make -j $THREADS all >> "$DIR/install.log" 2>&1 && mark_cache
	else write_caching; cd "$d"; fi
	write_install; make install >> "$DIR/install.log" 2>&1; cd ..
	write_done
}

function build_leveldb {
	write_library leveldb "$EXT_LEVELDB_VERSION"
	local d="./leveldb-$EXT_LEVELDB_VERSION"
	if cant_use_cache "$d"; then
		rm -rf "$d"; write_download
		download_github_src "pmmp/leveldb" "$EXT_LEVELDB_VERSION" "leveldb" | tar -zx >> "$DIR/install.log" 2>&1
		write_configure; cd "$d"
		[ "$DO_STATIC" != "yes" ] && local EXTRA="-DBUILD_SHARED_LIBS=ON" || local EXTRA=""
		cmake . -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" -DCMAKE_PREFIX_PATH="$INSTALL_DIR" \
			-DCMAKE_INSTALL_LIBDIR=lib -DLEVELDB_BUILD_TESTS=OFF \
			-DLEVELDB_BUILD_BENCHMARKS=OFF -DLEVELDB_SNAPPY=OFF -DLEVELDB_ZSTD=OFF \
			-DLEVELDB_TCMALLOC=OFF -DCMAKE_BUILD_TYPE=Release \
			$CMAKE_GLOBAL_EXTRA_FLAGS $EXTRA >> "$DIR/install.log" 2>&1
		write_compile; make -j $THREADS >> "$DIR/install.log" 2>&1 && mark_cache
	else write_caching; cd "$d"; fi
	write_install; make install >> "$DIR/install.log" 2>&1; cd ..
	write_done
}

function build_libpng {
	[ "$DO_STATIC" == "yes" ] && local EXTRA="--enable-shared=no --enable-static=yes" || local EXTRA="--enable-shared=yes --enable-static=no"
	write_library libpng "$LIBPNG_VERSION"
	local d="./libpng-$LIBPNG_VERSION"
	if cant_use_cache "$d"; then
		rm -rf "$d"; write_download
		download_file "https://github.com/pnggroup/libpng/archive/refs/tags/v$LIBPNG_VERSION.tar.gz" "libpng" | tar -zx >> "$DIR/install.log" 2>&1
		if [ ! -d "$d" ]; then mv "libpng-$LIBPNG_VERSION"* "$d" 2>/dev/null || true; fi
		write_configure; cd "$d"
		LDFLAGS="$LDFLAGS -L${INSTALL_DIR}/lib" CPPFLAGS="$CPPFLAGS -I${INSTALL_DIR}/include" \
			RANLIB=$RANLIB ./configure --prefix="$INSTALL_DIR" $EXTRA $CONFIGURE_FLAGS >> "$DIR/install.log" 2>&1
		write_compile; make -j $THREADS >> "$DIR/install.log" 2>&1 && mark_cache
	else write_caching; cd "$d"; fi
	write_install; make install >> "$DIR/install.log" 2>&1; cd ..
	write_done
}

function build_libjpeg {
	[ "$DO_STATIC" == "yes" ] && local EXTRA="--enable-shared=no --enable-static=yes" || local EXTRA="--enable-shared=yes --enable-static=no"
	write_library libjpeg "$LIBJPEG_VERSION"
	local d="./libjpeg-$LIBJPEG_VERSION"
	if cant_use_cache "$d"; then
		rm -rf "$d"; write_download
		download_file "https://www.ijg.org/files/jpegsrc.v$LIBJPEG_VERSION.tar.gz" "libjpeg" | tar -zx >> "$DIR/install.log" 2>&1
		mv jpeg-$LIBJPEG_VERSION "$d"
		write_configure; cd "$d"
		LDFLAGS="$LDFLAGS -L${INSTALL_DIR}/lib" CPPFLAGS="$CPPFLAGS -I${INSTALL_DIR}/include" \
			RANLIB=$RANLIB ./configure --prefix="$INSTALL_DIR" $EXTRA $CONFIGURE_FLAGS >> "$DIR/install.log" 2>&1
		write_compile; make -j $THREADS >> "$DIR/install.log" 2>&1 && mark_cache
	else write_caching; cd "$d"; fi
	write_install; make install >> "$DIR/install.log" 2>&1; cd ..
	write_done
}

function build_libzip {
    write_library libzip "$LIBZIP_VERSION"
    local d="./libzip-$LIBZIP_VERSION"
    if cant_use_cache "$d"; then
        rm -rf "$d"; write_download
        download_file "https://libzip.org/download/libzip-$LIBZIP_VERSION.tar.gz" "libzip" | tar -zx >> "$DIR/install.log" 2>&1
        write_configure; cd "$d"
        cmake . -DCMAKE_PREFIX_PATH="$INSTALL_DIR" -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
            -DCMAKE_INSTALL_LIBDIR=lib \
            -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON \
            $CMAKE_GLOBAL_EXTRA_FLAGS \
            -DBUILD_TOOLS=OFF -DBUILD_REGRESS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_DOC=OFF \
            -DENABLE_BZIP2=OFF -DENABLE_COMMONCRYPTO=OFF -DENABLE_GNUTLS=OFF \
            -DENABLE_MBEDTLS=OFF -DENABLE_LZMA=OFF -DENABLE_ZSTD=OFF >> "$DIR/install.log" 2>&1
        write_compile; make -j $THREADS >> "$DIR/install.log" 2>&1 && mark_cache
    else write_caching; cd "$d"; fi
    write_install; make install >> "$DIR/install.log" 2>&1; cd ..
    write_done
}

function build_sqlite3 {
	[ "$DO_STATIC" == "yes" ] && local EXTRA="--enable-static=yes --enable-shared=no" || local EXTRA="--enable-static=no --enable-shared=yes"
	write_library sqlite3 "$SQLITE3_VERSION"
	local d="./sqlite3-$SQLITE3_VERSION"
	if cant_use_cache "$d"; then
		rm -rf "$d"; write_download
		local YEAR=""
		case "$SQLITE3_VERSION" in
			314*) YEAR=2016 ;;
			320*) YEAR=2017 ;;
			324*) YEAR=2018 ;;
			336*) YEAR=2021 ;;
			*) YEAR=2019 ;;
		esac
		download_file "https://www.sqlite.org/$YEAR/sqlite-autoconf-$SQLITE3_VERSION.tar.gz" "sqlite3" | tar -zx >> "$DIR/install.log" 2>&1
		mv sqlite-autoconf-$SQLITE3_VERSION "$d"
		write_configure; cd "$d"

		# SQLite explicitly refuses -ffast-math. Use a sanitized CFLAGS for this build only.
		local SAVED_CFLAGS="$CFLAGS"
		local SAVED_CXXFLAGS="$CXXFLAGS"
		export CFLAGS="$(echo "$CFLAGS" | sed -e 's/-ffast-math//g' -e 's/-funsafe-math-optimizations//g' -e 's/-ffinite-math-only//g' -e 's/-fno-rounding-math//g' -e 's/-fno-signaling-nans//g' -e 's/-fno-signed-zeros//g' -e 's/-fno-trapping-math//g' -e 's/-fcx-limited-range//g' -e 's/-fno-math-errno//g' -e 's/  */ /g' | xargs)"
		export CXXFLAGS="$(echo "$CXXFLAGS" | sed -e 's/-ffast-math//g' -e 's/-funsafe-math-optimizations//g' -e 's/-ffinite-math-only//g' -e 's/-fno-rounding-math//g' -e 's/-fno-signaling-nans//g' -e 's/-fno-signed-zeros//g' -e 's/-fno-trapping-math//g' -e 's/-fcx-limited-range//g' -e 's/-fno-math-errno//g' -e 's/  */ /g' | xargs)"

		LDFLAGS="$LDFLAGS -L${INSTALL_DIR}/lib" CPPFLAGS="$CPPFLAGS -I${INSTALL_DIR}/include" \
			RANLIB=$RANLIB ./configure --prefix="$INSTALL_DIR" \
			--disable-dependency-tracking --enable-static-shell=no \
			$EXTRA $CONFIGURE_FLAGS >> "$DIR/install.log" 2>&1
		write_compile; make -j $THREADS >> "$DIR/install.log" 2>&1 && mark_cache

		export CFLAGS="$SAVED_CFLAGS"
		export CXXFLAGS="$SAVED_CXXFLAGS"
	else write_caching; cd "$d"; fi
	write_install; make install >> "$DIR/install.log" 2>&1; cd ..
	write_done
}

cd "$LIB_BUILD_DIR"
build_zlib
build_gmp
build_openssl
build_curl
build_yaml

if [ "$COMPILE_GD" == "yes" ]; then
	build_libpng
	build_libjpeg
	HAS_GD="--with-gd"
	HAS_LIBJPEG="--with-jpeg-dir=$INSTALL_DIR"
	HAS_LIBPNG="--with-png-dir=$INSTALL_DIR"
else
	HAS_GD=""; HAS_LIBJPEG=""; HAS_LIBPNG=""
fi

if [ -n "$EXT_LEVELDB_VERSION" ]; then build_leveldb; fi
build_libzip
build_sqlite3

# ----- extensions -----
function get_extension_tar_gz {
    echo -n "  $1: downloading $2..."
    download_file "$3" "php-ext-$1" | tar -zx >> "$DIR/install.log" 2>&1
    mv "$4" "$BUILD_DIR/php/ext/$1" 2>/dev/null \
        || mv "${4,,}" "$BUILD_DIR/php/ext/$1" 2>/dev/null \
        || { write_error "ext $1: archive extracted to unexpected dir (expected $4)"; return 1; }
    write_done
}
function get_github_extension {
	get_extension_tar_gz "$1" "$2" "https://github.com/$3/$4/archive/$5$2.tar.gz" "$4-$2"
}

cd "$BUILD_DIR/php"
write_out "PHP" "Downloading additional extensions..."

case "$PHP_VERSION" in
	7.3.*)
		echo -n "  pthreads: downloading 3.2.0 (pmmp/ext-pmmpthread)..."
		get_github_extension "pthreads" "3.2.0" "pmmp" "ext-pmmpthread"
		THREAD_EXT_FLAGS="--enable-pthreads"
		;;
	7.4.*)
		echo -n "  pthreads: downloading 4.0.0 (pmmp/ext-pmmpthread)..."
		get_github_extension "pthreads" "4.0.0" "pmmp" "ext-pmmpthread"
		THREAD_EXT_FLAGS="--enable-pthreads"
		;;
	*)
		get_github_extension "pthreads" "$EXT_PTHREADS_VERSION" "krakjoe" "pthreads" "v"
		THREAD_EXT_FLAGS="--enable-pthreads"
		;;
esac

if [ -n "$EXT_CHUNKUTILS_VERSION" ]; then
	get_github_extension "chunkutils2" "$EXT_CHUNKUTILS_VERSION" "pmmp" "ext-chunkutils2"
fi

if [ -n "$EXT_YAML_VERSION" ]; then
	get_github_extension "yaml" "$EXT_YAML_VERSION" "php" "pecl-file_formats-yaml"
fi
if [ -n "$EXT_IGBINARY_VERSION" ]; then
	get_github_extension "igbinary" "$EXT_IGBINARY_VERSION" "igbinary" "igbinary"
fi
if [ -n "$EXT_RECURSIONGUARD_VERSION" ]; then
	get_github_extension "recursionguard" "$EXT_RECURSIONGUARD_VERSION" "pmmp" "ext-recursionguard"
fi
if [ -n "$EXT_CRYPTO_VERSION" ]; then
	echo -n "  crypto: downloading $EXT_CRYPTO_VERSION..."
	git clone https://github.com/bukka/php-crypto.git "$BUILD_DIR/php/ext/crypto" >> "$DIR/install.log" 2>&1
	cd "$BUILD_DIR/php/ext/crypto"
	git checkout "$EXT_CRYPTO_VERSION" >> "$DIR/install.log" 2>&1
	git submodule update --init --recursive >> "$DIR/install.log" 2>&1
	cd "$BUILD_DIR"
	write_done
fi
if [ -n "$EXT_LEVELDB_VERSION" ]; then
	get_github_extension "leveldb" "88071eb1b1eae96af043229104b9d813f7cbe40c" "pmmp" "php-leveldb"
fi
if [ -n "$EXT_DS_VERSION" ]; then
	get_github_extension "ds" "$EXT_DS_VERSION" "php-ds" "ext-ds" "v"
fi
if [ -n "$EXT_WEAKREF_VERSION" ]; then
	get_extension_tar_gz "weakref" "$EXT_WEAKREF_VERSION" \
		"https://pecl.php.net/get/Weakref-$EXT_WEAKREF_VERSION.tgz" \
		"Weakref-$EXT_WEAKREF_VERSION"
fi

write_library "PHP" "$PHP_VERSION"
write_configure
cd "$BUILD_DIR/php"
rm -f ./aclocal.m4 >> "$DIR/install.log" 2>&1
rm -rf ./autom4te.cache/ >> "$DIR/install.log" 2>&1
rm -f ./configure >> "$DIR/install.log" 2>&1
./buildconf --force >> "$DIR/install.log" 2>&1

if [ "$DO_STATIC" == "yes" ]; then
	if [ -z "$PKG_CONFIG" ]; then PKG_CONFIG="$(which pkg-config)" || true; fi
	if [ ! -z "$PKG_CONFIG" ]; then
		echo '#!/bin/sh' > "$BUILD_DIR/pkg-config-wrapper"
		echo 'exec '$PKG_CONFIG' "$@" --static' >> "$BUILD_DIR/pkg-config-wrapper"
		chmod +x "$BUILD_DIR/pkg-config-wrapper"
		export PKG_CONFIG="$BUILD_DIR/pkg-config-wrapper"
	fi
fi

if [ "$IS_CROSSCOMPILE" == "yes" ]; then
	sed -i=".bak" 's/pthreads_working=no/pthreads_working=yes/' ./configure 2>/dev/null || true
	if [ "$COMPILE_FOR_ANDROID" == "yes" ]; then
		sed -i=".bak" 's/cookie_io_functions_use_off64_t=yes/cookie_io_functions_use_off64_t=no/' ./configure 2>/dev/null || true
		export ac_cv_pread=yes ac_cv_pwrite=yes
		export php_cv_type_cookie_off64_t=no php_cv_func_pread=yes php_cv_func_pwrite=yes
		export LIBS="$LIBS -lpthread -lresolv"
	else
		export LIBS="$LIBS -lpthread -ldl -lresolv"
	fi
	mv ext/mysqlnd/config9.m4 ext/mysqlnd/config.m4 2>/dev/null || true
	sed -i=".bak" "s{ext/mysqlnd/php_mysqlnd_config.h{config.h{" ext/mysqlnd/mysqlnd_portability.h 2>/dev/null || true
elif [ "$DO_STATIC" == "yes" ]; then
	export LIBS="$LIBS -ldl"
fi

[ "$IS_WINDOWS" != "yes" ] && HAVE_PCNTL="--enable-pcntl" || HAVE_PCNTL="--disable-pcntl"
[[ "$COMPILE_DEBUG" == "yes" ]] && HAS_DEBUG="--enable-debug" || HAS_DEBUG="--disable-debug"

ZIP_FLAG=""
case "$PHP_VERSION" in
	7.0.*) ZIP_FLAG="--enable-zip" ;;
	7.2.*|7.3.*) ZIP_FLAG="--with-zip=$INSTALL_DIR" ;;
	7.4.*) ZIP_FLAG="--with-zip" ;;
esac

SQLITE_FLAG="--with-sqlite3=$INSTALL_DIR"

XML_FLAGS="--disable-libxml --disable-xml --disable-dom --disable-simplexml --disable-xmlreader --disable-xmlwriter"

PDO_FLAGS=""
case "$PHP_VERSION" in
	7.0.*|7.2.*|7.3.*) PDO_FLAGS="--disable-pdo --without-pdo-sqlite" ;;
	7.4.*)              PDO_FLAGS="--with-pdo-sqlite=$INSTALL_DIR --with-pdo-mysql" ;;
esac

EMBEDDED_MYSQLI=""
case "$PHP_VERSION" in
	7.0.*) EMBEDDED_MYSQLI="--enable-embedded-mysqli" ;;
esac

PCNTL_EXTRA=""
[[ "$PHP_VERSION" == 7.0.* ]] && PCNTL_EXTRA="--enable-weakref"

LEVELDB_FLAG=""
[ -n "$EXT_LEVELDB_VERSION" ] && LEVELDB_FLAG="--with-leveldb=$INSTALL_DIR"

EXTRA_EXT_FLAGS=""
[ -n "$EXT_CHUNKUTILS_VERSION" ] && EXTRA_EXT_FLAGS="$EXTRA_EXT_FLAGS --enable-pocketmine-chunkutils2"
[ -n "$EXT_IGBINARY_VERSION" ] && EXTRA_EXT_FLAGS="$EXTRA_EXT_FLAGS --enable-igbinary"
[ -n "$EXT_CRYPTO_VERSION" ] && EXTRA_EXT_FLAGS="$EXTRA_EXT_FLAGS --with-crypto"
[ -n "$EXT_RECURSIONGUARD_VERSION" ] && EXTRA_EXT_FLAGS="$EXTRA_EXT_FLAGS --enable-recursionguard"
[ -n "$EXT_DS_VERSION" ] && EXTRA_EXT_FLAGS="$EXTRA_EXT_FLAGS --enable-ds"
[ -n "$EXT_WEAKREF_VERSION" ] && EXTRA_EXT_FLAGS="$EXTRA_EXT_FLAGS --enable-weakref"

RANLIB=$RANLIB CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" ./configure \
--enable-inline-optimization \
--prefix="$INSTALL_DIR" --exec-prefix="$INSTALL_DIR" \
--with-curl="$INSTALL_DIR" \
--with-zlib="$INSTALL_DIR" --with-zlib-dir="$INSTALL_DIR" \
--with-gmp="$INSTALL_DIR" \
--with-yaml="$INSTALL_DIR" \
--with-openssl="$INSTALL_DIR" \
$ZIP_FLAG \
$SQLITE_FLAG \
$HAS_LIBPNG $HAS_LIBJPEG $HAS_GD \
$LEVELDB_FLAG \
--without-readline --without-ncurses \
$HAS_DEBUG \
--enable-mbstring --enable-calendar \
$THREAD_EXT_FLAGS \
--disable-fileinfo \
$XML_FLAGS \
--disable-cgi --disable-phpdbg --disable-session \
--without-pear --without-iconv \
$PDO_FLAGS \
$EMBEDDED_MYSQLI \
--with-pic --enable-phar --enable-ctype --enable-sockets \
--enable-shared=no --enable-static=yes \
--enable-shmop --enable-maintainer-zts \
--disable-short-tags \
$HAVE_PCNTL $HAVE_MYSQLI \
--enable-bcmath --enable-cli --enable-ftp \
--enable-opcache=$HAVE_OPCACHE \
$EXTRA_EXT_FLAGS \
$HAVE_VALGRIND \
$PCNTL_EXTRA \
$CONFIGURE_FLAGS >> "$DIR/install.log" 2>&1

write_compile
if [ "$COMPILE_FOR_ANDROID" == "yes" ]; then
	sed -i=".bak" 's/-export-dynamic/-all-static/g' Makefile 2>/dev/null || true
fi
sed -i=".bak" 's/PHP_BINARIES. pharcmd$/PHP_BINARIES)/g' Makefile 2>/dev/null || true
sed -i=".bak" 's/install-programs install-pharcmd$/install-programs/g' Makefile 2>/dev/null || true
[ "$DO_STATIC" == "yes" ] && sed -i=".bak" 's/--mode=link $(CC)/--mode=link $(CXX)/g' Makefile 2>/dev/null || true

make -j $THREADS >> "$DIR/install.log" 2>&1
write_install
make install >> "$DIR/install.log" 2>&1

write_status "generating php.ini"
TIMEZONE=$(date +%Z)
{
	echo "memory_limit=1024M"
	echo "date.timezone=$TIMEZONE"
	echo "short_open_tag=0"
	echo "asp_tags=0"
	echo "phar.require_hash=1"
	[ -n "$EXT_IGBINARY_VERSION" ] && echo "igbinary.compact_strings=0"
	if [[ "$COMPILE_DEBUG" == "yes" ]]; then echo "zend.assertions=1"; else echo "zend.assertions=-1"; fi
	echo "error_reporting=-1"
	echo "display_errors=1"
	echo "display_startup_errors=1"
	[ -n "$EXT_RECURSIONGUARD_VERSION" ] && echo "recursionguard.enabled=0 ;disabled due to minor performance impact"
	if [ "$HAVE_OPCACHE" == "yes" ]; then
		echo "zend_extension=opcache.so"
		echo "opcache.enable=1"
		echo "opcache.enable_cli=1"
		echo "opcache.save_comments=1"
		echo "opcache.validate_timestamps=1"
		echo "opcache.revalidate_freq=0"
		echo "opcache.file_update_protection=0"
	fi
} >> "$INSTALL_DIR/bin/php.ini"
write_done

cd "$DIR"
if [ "$DO_CLEANUP" == "yes" ]; then
	write_out "INFO" "Cleaning up"
	rm -rf "$BUILD_DIR"
	rm -f "$INSTALL_DIR/bin/curl"* "$INSTALL_DIR/bin/curl-config"* \
	      "$INSTALL_DIR/bin/c_rehash"* "$INSTALL_DIR/bin/openssl"*
	rm -rf "$INSTALL_DIR/man" "$INSTALL_DIR/share/man" "$INSTALL_DIR/php" \
	       "$INSTALL_DIR/misc" "$INSTALL_DIR/include"
	rm -f "$INSTALL_DIR/lib/"*.a "$INSTALL_DIR/lib/"*.la
fi

date >> "$DIR/install.log" 2>&1
write_out "PocketMine" "You should start the server now using \"./start.sh\"."
write_out "PocketMine" "If it doesn't work, please send the \"install.log\" file to the Bug Tracker."
