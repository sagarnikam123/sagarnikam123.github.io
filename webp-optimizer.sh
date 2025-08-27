#!/bin/bash

# WebP Optimizer Script
# Converts images to WebP format with optimal settings for blog posts
# Generates LQIP (Low Quality Image Placeholder) for performance
# Author: Sagar Nikam
# Usage: ./webp-optimizer.sh [input_file] [output_dir] [type]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default settings
DEFAULT_QUALITY=85
DEFAULT_LQIP_QUALITY=20
DEFAULT_LQIP_SIZE="32x32"
DEFAULT_SHARPNESS=2

# WebP Quality Settings: 0-100 (0=smallest/worst, 100=largest/best) | Recommended: 75-85 for photos, 85-95 for graphics
# Sharpness Settings: 0-7 (0=off, 1-2=photos, 3-4=graphics/text, 5-7=screenshots) | Recommended: 0 for photos, 2 for blog images, 3+ for text/diagrams

# Check dependencies
check_dependencies() {
    local missing_deps=()

    if ! command -v cwebp &> /dev/null; then
        missing_deps+=("cwebp (libwebp)")
    fi

    if ! command -v base64 &> /dev/null; then
        missing_deps+=("base64")
    fi

    if ! command -v convert &> /dev/null; then
        missing_deps+=("convert (ImageMagick)")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}Error: Missing dependencies:${NC}"
        printf '%s\n' "${missing_deps[@]}"
        echo -e "${YELLOW}Install missing dependencies and try again.${NC}"
        exit 1
    fi
}

# Print usage
usage() {
    echo -e "${BLUE}WebP Optimizer Script${NC}"
    echo ""
    echo "Usage: $0 [input_file] [output_dir] [type]"
    echo ""
    echo "Parameters:"
    echo "  input_file  - Path to input image file"
    echo "  output_dir  - Output directory (optional, defaults to same as input)"
    echo "  type        - Image type: header|lqip|auto (optional, defaults to auto)"
    echo ""
    echo "Image Types:"
    echo "  header - Blog header image (1200x630px, quality 85, sharpness 2)"
    echo "  lqip   - Low Quality Image Placeholder (32x32px, quality 20)"
    echo "  auto   - Auto-detect based on image dimensions"
    echo ""
    echo "Quality: 0-100 (75-85 photos, 85-95 graphics) | Sharpness: 0-7 (0 photos, 2 blog, 3+ text)"
    echo ""
    echo "Examples:"
    echo "  $0 image.jpg"
    echo "  $0 image.png assets/img/posts/"
    echo "  $0 header.jpg assets/img/posts/ header"
    echo "  $0 image.png . lqip"
}

# Get image dimensions
get_dimensions() {
    local file="$1"
    identify -format "%wx%h" "$file" 2>/dev/null
}

# Auto-detect image type based on dimensions
auto_detect_type() {
    local dimensions="$1"
    local width=$(echo "$dimensions" | cut -d'x' -f1)
    local height=$(echo "$dimensions" | cut -d'x' -f2)

    # Header image detection (wide aspect ratio)
    if [ "$width" -ge 1000 ] && [ "$height" -ge 500 ]; then
        echo "header"
    # Small image detection
    elif [ "$width" -le 100 ] && [ "$height" -le 100 ]; then
        echo "lqip"
    else
        echo "standard"
    fi
}

# Convert to WebP
convert_to_webp() {
    local input_file="$1"
    local output_file="$2"
    local quality="$3"
    local sharpness="$4"
    local width="$5"
    local height="$6"

    local cmd="cwebp"

    # Add quality
    cmd="$cmd -q $quality"

    # Add sharpness if specified
    if [ -n "$sharpness" ]; then
        cmd="$cmd -sharpness $sharpness"
    fi

    # Add resize if specified
    if [ -n "$width" ] && [ -n "$height" ]; then
        cmd="$cmd -resize $width $height"
    fi

    # Add input and output
    cmd="$cmd \"$input_file\" -o \"$output_file\""

    echo -e "${BLUE}Converting:${NC} $cmd"
    eval "$cmd"
}

# Generate LQIP Base64
generate_lqip_base64() {
    local webp_file="$1"
    local temp_lqip="/tmp/lqip_temp.webp"

    # Create LQIP version
    cwebp -q "$DEFAULT_LQIP_QUALITY" -resize 32 32 "$webp_file" -o "$temp_lqip" 2>/dev/null

    # Generate Base64
    local base64_data=$(base64 -i "$temp_lqip" | tr -d '\n')
    local data_uri="data:image/webp;base64,$base64_data"

    # Cleanup
    rm -f "$temp_lqip"

    echo "$data_uri"
}

# Process single image
process_image() {
    local input_file="$1"
    local output_dir="$2"
    local image_type="$3"

    # Validate input file
    if [ ! -f "$input_file" ]; then
        echo -e "${RED}Error: Input file '$input_file' not found${NC}"
        return 1
    fi

    # Get file info
    local filename=$(basename "$input_file")
    local name="${filename%.*}"
    local dimensions=$(get_dimensions "$input_file")

    if [ -z "$dimensions" ]; then
        echo -e "${RED}Error: Could not read image dimensions for '$input_file'${NC}"
        return 1
    fi

    # Auto-detect type if not specified
    if [ "$image_type" = "auto" ]; then
        image_type=$(auto_detect_type "$dimensions")
    fi

    # Set output file
    local output_file="$output_dir/${name}.webp"

    echo -e "${GREEN}Processing:${NC} $filename ($dimensions) as $image_type"

    # Process based on type
    case "$image_type" in
        "header")
            convert_to_webp "$input_file" "$output_file" "$DEFAULT_QUALITY" "$DEFAULT_SHARPNESS" "1200" "630"
            ;;
        "lqip")
            convert_to_webp "$input_file" "$output_file" "$DEFAULT_LQIP_QUALITY" "" "32" "32"
            ;;
        "standard")
            convert_to_webp "$input_file" "$output_file" "$DEFAULT_QUALITY" "$DEFAULT_SHARPNESS" "" ""
            ;;
        *)
            echo -e "${RED}Error: Unknown image type '$image_type'${NC}"
            return 1
            ;;
    esac

    # Generate LQIP Base64 for all images except LQIP type
    if [ "$image_type" != "lqip" ]; then
        echo -e "${BLUE}Generating LQIP Base64...${NC}"
        local lqip_data=$(generate_lqip_base64 "$output_file")
        local lqip_length=${#lqip_data}

        echo -e "${GREEN}LQIP Generated:${NC} $lqip_length characters"
        echo -e "${YELLOW}LQIP Data:${NC}"
        echo "$lqip_data"
        echo ""

        # Save LQIP to file
        local lqip_file="$output_dir/${name}_lqip.txt"
        echo "$lqip_data" > "$lqip_file"
        echo -e "${GREEN}LQIP saved to:${NC} $lqip_file"
    fi

    # Show file sizes
    local input_size=$(du -h "$input_file" | cut -f1)
    local output_size=$(du -h "$output_file" | cut -f1)

    echo -e "${GREEN}Conversion complete:${NC}"
    echo -e "  Input:  $input_size ($input_file)"
    echo -e "  Output: $output_size ($output_file)"
    echo ""
}

# Main function
main() {
    # Check dependencies first
    check_dependencies

    # Parse arguments
    local input_file="$1"
    local output_dir="$2"
    local image_type="${3:-auto}"

    # Show usage if no arguments
    if [ -z "$input_file" ]; then
        usage
        exit 0
    fi

    # Set default output directory
    if [ -z "$output_dir" ]; then
        output_dir=$(dirname "$input_file")
    fi

    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"

    # Process single file or batch
    if [ -f "$input_file" ]; then
        # Single file
        process_image "$input_file" "$output_dir" "$image_type"
    elif [ -d "$input_file" ]; then
        # Directory - batch process
        echo -e "${BLUE}Batch processing directory:${NC} $input_file"
        echo ""

        local processed=0
        local failed=0

        # Process common image formats
        for ext in jpg jpeg png gif bmp tiff; do
            for file in "$input_file"/*."$ext" "$input_file"/*."${ext^^}"; do
                if [ -f "$file" ]; then
                    if process_image "$file" "$output_dir" "$image_type"; then
                        ((processed++))
                    else
                        ((failed++))
                    fi
                fi
            done
        done

        echo -e "${GREEN}Batch processing complete:${NC}"
        echo -e "  Processed: $processed files"
        echo -e "  Failed: $failed files"
    else
        echo -e "${RED}Error: '$input_file' is not a valid file or directory${NC}"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
