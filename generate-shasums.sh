#!/bin/bash

set -e

image_name="redis"

script="$(basename "$0")"
script_dir="$(dirname "$0")"

usage() {
	cat 1>&2 <<EOUSAGE
This script generates the SHASUMS256.txt file used by the Dockerfile.

   usage: ./$script
      ie: ./$script   - Generate SHASUMS256.txt

EOUSAGE
exit 1
}

# NOTE: As of 05/05/17, Redis does not publish general sha256 checksums for
# their releases. So we generate the shasums using the downloaded tarball.
generate_shasums() {
  tmp=$( mktemp -d /tmp/${image_name}_sha.XXXXXX )
  shasum_file="${script_dir}/${image_name}/SHASUMS256.txt"

  download_url="http://download.redis.io/releases"

  versions=(
    "3.2.8" "3.0.7"
  )

  if [ -f "${shasum_file}" ]; then
    rm -f "${shasum_file}"
  fi

  touch "${shasum_file}"
  echo "### ${image_name} Official Checksums" > ${shasum_file}

  for ver in "${versions[@]}"; do
    curl -sSL "$download_url/redis-$ver.tar.gz" \
      -o ${tmp}/redis-$ver.tar.gz

    sha256sum "${tmp}/redis-$ver.tar.gz" >> ${shasum_file}

    rm ${tmp}/redis-$ver.tar.gz
  done

  # NOTE: Currently, the script does not replace the temporary directory in the
  # generated `SHASUMS256.txt` file. It needs to be removed manually before
  # committing.
  sed -e "s@${tmp}/@@g" ${shasum_file}
}

# Parse options/flags.
options=$(getopt -u --options ':h' --longoptions 'help' --name "${script}" -- "$@")
eval set -- "${options}"

# Handle options/flags.
while true; do
	case "$1" in
		-h|--help )
      usage ;;
		-- )
      shift ; break ;;
    *)
      cat 1>&2 <<-EOF
			Error: Invalid option. Option: $1
			EOF
      exit 1
      ;;
	esac
done

generate_shasums
