supported_platforms=("linux-x86-64" "macos-x86-64" "macos-arm-64" "android-arm-64" "windows-x86-64")

if [ -z "$1" ]; then
  echo "missing <platform>"
  echo "usage: ./setup.sh <platform> [destination=deps]"
  echo "environment arguments:"
  echo "  registry=<url>    set a registry for downloading"
  echo "  build_type=debug|release|min-release    choose dependencies' build_type"
  echo "  download_command=<string>    %url %name to replace"
  exit 1
fi

platform="$1"
found=false

for supported_platform in "${supported_platforms[@]}"; do
  if [ "$supported_platform" == "$platform" ]; then
    found=true
    break
  fi
done

if ! $found; then
  echo "error: unknown or unsupported platform '$platform'"
  echo "available platforms: ${supported_platforms[*]}"
  exit 1
fi

destination_dir="$2"
if [ -z $destination_dir ]; then
  destination_dir=deps
fi

deps_type="release" #
if [ -z $registry ]; then
  registry="https://raw.githubusercontent.com/litlang/cpplit-deps/main"
fi
if [ -z $download_command ]; then
  download_command="curl -o %out %url"
fi

mkdir -p $destination_dir
cd $destination_dir
dep_list=("codec" "losh" "gmp" "number_converter" "ranges" "trie")
for dep in "${dep_list[@]}"; do
  url="${registry}/${dep}/latest/${platform}.zip"
  # realtime download command
  download_command_rt="${download_command//%out/${dep}.zip}"
  echo $download_command_rt
  download_command_rt="${download_command_rt//%url/$url}"
  ${download_command_rt} &&
  unzip -d $dep "${dep}.zip" &&
  rm "${dep}.zip"
  if [[ $? != 0 ]] then
    exit $?
  fi
done
