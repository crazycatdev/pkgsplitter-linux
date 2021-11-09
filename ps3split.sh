#!/bin/bash
# Are you using Mac OS X?
# You need to install coreutils for this to work.
# try `brew install coreutils`
# or `sudo port install coreutils`

# set a part size that works with FAT32 drives
PART_SIZE=3999

# nice little intro
echo ""
echo ""
echo ""

echo "C R A Z Y  C A T  &  F R E E M A N  I N D U S T R I E S"
echo ""
echo "This script copies a directory in its entirety to a new destination, and automatically splits files greater than 4gb along the way without compression."
echo ""
echo "The 3rd argument, prefix, is optional. If left out, files will be outputted as .00, .01."
echo "Here's an example - specify abc as the prefix, and the result will be .abc00, .abc01."
echo ""
echo "I, freeman, built this to easily copy my PS3 backups to a FAT32 drive."
echo "For Multiman backups, specify 666 and the split files will be output as .66600, .66601 which Multiman successfully extracts."
echo "I, crazy_cat modified it and fixed it, so it actually works and has some optimizations."

echo ""
echo ""
echo ""

# validate args
USAGE="Usage: ./copyToFat32 \$INPUT_DIR \$OUTPUT_DIR \$PREFIX"
if [[ -z "$1" ]]; then
    echo "You're missing \$INPUT_DIR."
    echo $USAGE 1>&2
    echo ""
    exit 1
fi
if [[ -z "$2" ]]; then
    echo "You're missing \$OUTPUT_DIR."
    echo $USAGE 1>&2
    echo ""
    exit 1
fi

# grab input & output from arguments
INPUT_DIR=$(realpath $1)
OUTPUT_DIR=$(realpath $2)
PREFIX=$3

# make sure the output dir exists.
mkdir -p "$OUTPUT_DIR"

# read through contents of input directory recursively...
find $INPUT_DIR | while read FILE; do
	echo ""

	# get the relative path by replacing the input directory prefix with a blank string. also replace the initial slash.
	RELATIVE_PATH="$OUTPUT_DIR/${FILE/$INPUT_DIR/}"

	if [[ -d "$FILE" ]]
	then
		# this is a directory, so we create it at the destination.
		mkdir -p "$RELATIVE_PATH"

		echo "📁 Created a directory at $OUTPUT_DIR"
		continue
	fi

	if [[ -f "$FILE" ]]
	then
		# this is a file, so we need to copy it over.
		echo "📂 $FILE"

		# get file size
		FILE_SIZE=$(du -m "$FILE" | cut -f1)

		# if the file is already smaller than the part size, we just need to copy it. splitting isn't necessary.
		if [ "$FILE_SIZE" -le "$PART_SIZE" ]
		then
			echo "📋 This file is small enough to just be copied (${FILE_SIZE}mb)"

			cp "$FILE" "$RELATIVE_PATH"
		fi

		# if the file size is larger than the minimum, then we need to split it into parts.
		if [ "$FILE_SIZE" -gt "$PART_SIZE" ]
		then
			echo "✂️ This file needs to be split into multiple parts (${FILE_SIZE}mb)"

		        split -a 5 -b 4294967295 -d --numeric-suffixes="$PREFIX" "$FILE"  "${RELATIVE_PATH.${PREFIX}"
		fi

		echo "✅ Saved to $RELATIVE_PATH"

		continue
	fi
done
