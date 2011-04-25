#!/bin/bash

# Script to debian package install from lbackup core source code
#
# Copyright (C)2011 - Henri Shustak
# Released under the GUN GPL v3 or later
#
# Ensure that the parent directory contatins the lbackup_core source code directory


# various varibles
tmp_build_file=`mktemp /tmp/lbackup_core.tar.gz.XXXXXXXXX`
rm "${tmp_build_file}"
output_lbackup_core_tar_archive_name="lbackup_core.tar.gz"
input_lbackup_core_directory_name="lbackup_core"
relaitive_parent_directory_contianing_lbackup_core_source="../"
script_directory_realitive=`dirname "${0}"`
cd "${script_directory_realitive}"
script_directory=`pwd`
excludes_file_name="exclude.txt"
debian_control_file_name="control"

# direcotry used for build input (source) and output (.deb/.deb.tar.gz) files
build_source_dir_name="build_source"
build_output_dir_name="build_output"

# directory containing the debian template files
debian_template_dir_name="debian_template/DEBIAN"

output_tar_file_source_absolute_path="${script_directory}/${build_source_dir_name}/${output_lbackup_core_tar_archive_name}"
excludes_file_absolute_path="${script_directory}/${excludes_file_name}"
debian_template_dir_absolute_path="${script_directory}/${debian_template_dir_name}"
debian_template_control_file_absolute_path="${debian_template_dir_absolute_path}/${debian_control_file_name}"

# check that a version has been provided for this build (pretty lax)
num_arguments=$#
if [ $num_arguments != 1 ] ; then
    echo "ERROR! : You must specify the version build number."
    echo "         Usage : ./build.bash \"0.9.8r5\""
    exit -1
fi

# additional settings from arguments
build_version="${1}"
source_version_direcotry_name="lbackup_${build_version}_all"
source_version_direcotry_absolute="${script_directory}/${build_source_dir_name}/${source_version_direcotry_name}"
source_version_DEBIAN_directory_absolute="${source_version_direcotry_absolute}/DEBIAN"
source_debian_control_file_absolute_path="${source_version_DEBIAN_directory_absolute}/${debian_control_file_name}"
source_debian_package_name="lbackup_${build_version}_all.deb"
output_debian_package_arachive_absolute="${script_directory}/${build_output_dir_name}/lbackup_${build_version}_all.deb.tar.gz"
output_debian_source_archive_absolute="${script_directory}/${build_output_dir_name}/lbackup_${build_version}_deb_source.tar.gz"

# check we are running as root
current_user=`whoami`
if [ "${current_user}" != "root" ] ; then 
    echo ""
    echo "    ERROR! : This build script must be run with super user privileges."
    echo ""
    exit -1
fi

# move to directory containing lbackup core source code direcotry
cd "${script_directory}"

# if a previous build output directory exits then remove this
if [ -d "${build_source_dir_name}" ] ; then 
    rm -R "${build_source_dir_name}"
    if [ $? != 0 ] ; then
        echo ""
        echo "    ERROR! : Failed during old build_source directory removal."
        echo ""
        exit -1
    fi
fi

# if a previous build output directory exits then remove this
if [ -d "${build_output_dir_name}" ] ; then 
    rm -R "${build_output_dir_name}"
    if [ $? != 0 ] ; then
        echo ""
        echo "    ERROR! : Failed during old build_output directory removal."
        echo ""
        exit -1
    fi
fi

# make the source and output build directories
mkdir "${build_source_dir_name}"
if [ $? != 0 ] ; then 
    echo ""
    echo "    ERROR! : Failed to create the build source directory."
    echo ""
    exit -1
fi
mkdir "${build_output_dir_name}"
if [ $? != 0 ] ; then 
    echo ""
    echo "    ERROR! : Failed to create the build output directory."
    echo ""
    exit -1
fi
mkdir "${source_version_direcotry_absolute}"
if [ $? != 0 ] ; then 
    echo ""
    echo "    ERROR! : Failed to create the source version output directory."
    echo ""
    exit -1
fi


# tar the backup core using the excludes file (to remove various parts)
cd "${relaitive_parent_directory_contianing_lbackup_core_source}"
tar -czvf "${output_tar_file_source_absolute_path}" -X "${excludes_file_absolute_path}" "${input_lbackup_core_directory_name}" 
if [ $? != 0 ] ; then
    echo ""
    echo "    ERROR! : Failed during new tarball creation."
    echo ""
    exit -1
fi

# jump back to the script direcotry
cd "${script_directory}"

# copy the template DEBIAN files into the build source directory
cp -r "${debian_template_dir_absolute_path}" "${source_version_DEBIAN_directory_absolute}"
if [ $? != 0 ] ; then 
    echo "    ERROR!: Unable to copy the debian template directory into the build_source debian directory"
    exit -1
fi

# fill in the source debian control file with the verson we are building
sed s/XXXXXXXXXXX/${build_version}/g "${debian_template_control_file_absolute_path}" > "${source_debian_control_file_absolute_path}"
if [ $? != 0 ] ; then 
    echo "    ERROR!: LBackup setting version in make file failed!"
    exit -1
fi

# expland the lbackup core files into the source directory
cd "${script_directory}/${build_source_dir_name}"
tar -xf "${output_tar_file_source_absolute_path}"
if [ $? != 0 ] ; then 
    echo "    ERROR!: Error while expanding the lbackup source files within the build_source directory!"
    exit -1
fi
cd "${script_directory}"

# copy over the build files to the package build directory
cp -r "${script_directory}/${build_source_dir_name}/${input_lbackup_core_directory_name}/"* "${source_version_direcotry_absolute}/"
if [ $? != 0 ] ; then 
    echo "    ERROR!: Error copying over the lbackup source data to the lbackup source files within the source directory!"
    exit -1
fi

# ensure files have correct ownership
chown -R 0:0 "${source_version_direcotry_absolute}"
if [ $? != 0 ] ; then 
    echo "    ERROR!: Setting appropriate permissions on the build files"
    exit -1
fi

# build the .deb installer package
cd "${script_directory}/${build_source_dir_name}"
dpkg --build "${source_version_direcotry_absolute}"
if [ $? != 0 ] ; then 
    echo "    ERROR!: Building the .deb installer"
    exit -1
fi
cd "${script_directory}"

# tar up the source directory and the .deb installer and place these into the build_output directory for collection
cd "${script_directory}/${build_source_dir_name}"
tar -czf "${output_debian_source_archive_absolute}" "${source_version_direcotry_name}"
if [ $? != 0 ] ; then 
    echo "    ERROR!: Generating the archived .deb installer within the build_output directory"
    exit -1
fi
cd "${script_directory}"

# tar up the .deb installer within the build_output directory for collection
cd "${script_directory}/${build_source_dir_name}"
tar -czf "${output_debian_package_arachive_absolute}" "${source_debian_package_name}"
if [ $? != 0 ] ; then 
    echo "    ERROR!: Generating the archived source for the .deb installer within the build_output directory"
    exit -1
fi
cd "${script_directory}"

echo ""
echo "---------------------------------------------------------------------------------"
echo " Package for LBackup was successfully created from the LBackup core source code. "
echo "---------------------------------------------------------------------------------"
echo ""

exit 0

