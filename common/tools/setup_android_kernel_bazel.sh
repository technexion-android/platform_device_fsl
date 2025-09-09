#!/bin/bash

# Android Kernel Bazel Workspace Setup Script
# This script sets up Android kernel Bazel workspace with configurable Android project path

set -e  # Exit on any error

# Default configuration (can be overridden)
DEFAULT_MANIFEST_URL="https://android.googlesource.com/kernel/manifest"
DEFAULT_MANIFEST_BRANCH="common-android16-6.12-2025-08"
DEFAULT_SYNC_JOBS="32"
DEFAULT_WORKSPACE_SUFFIX="common-android16-6.12"

# Logging functions
log_info() {
    echo "[INFO] $1"
}

log_success() {
    echo "[SUCCESS] $1"
}

log_warning() {
    echo "[WARNING] $1"
}

log_error() {
    echo "[ERROR] $1"
}

log_step() {
    echo "[STEP] $1"
}

# Generate default workspace directory based on Android project directory
generate_default_workspace_dir() {
    local android_project_dir="$1"

    if [[ -z "$android_project_dir" ]]; then
        echo ""
        return
    fi

    # Get the parent directory of the Android project
    local parent_dir
    parent_dir=$(dirname "$android_project_dir")

    # Generate workspace directory: parent_dir/common-android16-6.12
    echo "$parent_dir/$DEFAULT_WORKSPACE_SUFFIX"
}

# Show usage information
show_usage() {
    cat << EOF
Usage: $0 -a ANDROID_PROJECT_DIR [OPTIONS]

Setup Android kernel workspace with repo initialization and symbolic links.

REQUIRED OPTIONS:
    -a, --android-project DIR   Android project directory (REQUIRED)

OPTIONAL OPTIONS:
    -w, --workspace DIR         Bazel workspace directory
                               (default: ANDROID_PROJECT_PARENT/$DEFAULT_WORKSPACE_SUFFIX)
    -u, --manifest-url URL      Manifest repository URL (default: $DEFAULT_MANIFEST_URL)
    -b, --manifest-branch BRANCH Manifest branch (default: $DEFAULT_MANIFEST_BRANCH)
    -j, --jobs NUM              Number of sync jobs (default: $DEFAULT_SYNC_JOBS)
    -c, --common-commit COMMIT  Checkout common directory to specific commit (optional)
    -h, --help                  Show this help message

WORKSPACE DIRECTORY LOGIC:
    If -w is not specified, the workspace directory will be automatically set to:
    \$(dirname ANDROID_PROJECT_DIR)/$DEFAULT_WORKSPACE_SUFFIX

    For example:
    - If -a /home/user/imx_android-16.0
    - Then default workspace: /home/user/$DEFAULT_WORKSPACE_SUFFIX

EXAMPLES:
    # Basic usage (workspace auto-generated)
    $0 -a ~/imx_android-16.0
    # Workspace will be: ~/$DEFAULT_WORKSPACE_SUFFIX

    # With specific common commit
    $0 -a ~/imx_android-16.0 -c abc123def456

    # Full example with all options
    $0 \\
        -a ~/imx_android-16.0 \\
        -w ~/bazel-workspace \\
        -b common-android16-6.12-2025-08 \\
        -j 16 \\
        -c abc123def456

SYMBOLIC LINKS CREATED:
    - kernel_imx -> ANDROID_PROJECT_DIR/vendor/nxp-opensource/kernel_imx
    - verisilicon_sw_isp_vvcam -> ANDROID_PROJECT_DIR/vendor/nxp-opensource/verisilicon_sw_isp_vvcam
    - nxp-mwifiex -> ANDROID_PROJECT_DIR/vendor/nxp-opensource/nxp-mwifiex

ENVIRONMENT VARIABLES SET:
    - BAZEL_WORKSPACE_DIR=WORKSPACE_DIR

NOTES:
    - The Android project directory (-a) is required and must be specified
    - Run this script as the user who will be building the kernel
    - Ensure you have write permissions to the workspace parent directory
    - The script will create directories and files with current user ownership
    - If --common-commit is specified, the common directory will be checked out to that commit after repo sync

EOF
}

# Parse command line arguments
parse_arguments() {
    WORKSPACE_DIR=""  # Will be set after parsing Android project dir
    ANDROID_PROJECT_DIR=""  # Must be specified by user
    MANIFEST_URL="$DEFAULT_MANIFEST_URL"
    MANIFEST_BRANCH="$DEFAULT_MANIFEST_BRANCH"
    SYNC_JOBS="$DEFAULT_SYNC_JOBS"

    # Check if no arguments provided
    if [[ $# -eq 0 ]]; then
        log_error "No arguments provided. Android project directory (-a) is required."
        echo
        show_usage
        exit 1
    fi

    while [[ $# -gt 0 ]]; do
        case $1 in
            -w|--workspace)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Option -w/--workspace requires a directory path"
                    exit 1
                fi
                WORKSPACE_DIR="$2"
                WORKSPACE_DIR_SPECIFIED=true
                shift 2
                ;;
            -a|--android-project)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Option -a/--android-project requires a directory path"
                    exit 1
                fi
                ANDROID_PROJECT_DIR="$2"
                shift 2
                ;;
            -u|--manifest-url)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Option -u/--manifest-url requires a URL"
                    exit 1
                fi
                MANIFEST_URL="$2"
                shift 2
                ;;
            -b|--manifest-branch)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Option -b/--manifest-branch requires a branch name"
                    exit 1
                fi
                MANIFEST_BRANCH="$2"
                shift 2
                ;;
            -j|--jobs)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Option -j/--jobs requires a number"
                    exit 1
                fi
                SYNC_JOBS="$2"
                shift 2
                ;;
            -c|--common-commit)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Option -c/--common-commit requires a commit hash"
                    exit 1
                fi
                COMMON_COMMIT="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo
                show_usage
                exit 1
                ;;
        esac
    done

    # Check if Android project directory is provided
    if [[ -z "$ANDROID_PROJECT_DIR" ]]; then
        log_error "Android project directory (-a/--android-project) is required but not provided."
        echo
        echo "Example usage:"
        echo "  $0 -a ~/imx_android-16.0"
        echo
        echo "Use -h/--help for more information."
        exit 1
    fi

    # Convert to absolute path
    ANDROID_PROJECT_DIR=$(realpath "$ANDROID_PROJECT_DIR" 2>/dev/null || echo "$ANDROID_PROJECT_DIR")

    # Set default workspace directory if not specified
    if [[ "$WORKSPACE_DIR_SPECIFIED" != true ]]; then
        WORKSPACE_DIR=$(generate_default_workspace_dir "$ANDROID_PROJECT_DIR")
        if [[ -z "$WORKSPACE_DIR" ]]; then
            log_error "Failed to generate default workspace directory"
            exit 1
        fi
        log_info "Auto-generated workspace directory: $WORKSPACE_DIR"
    else
        # Convert to absolute path if specified by user
        WORKSPACE_DIR=$(realpath "$WORKSPACE_DIR" 2>/dev/null || echo "$WORKSPACE_DIR")
        log_info "Using user-specified workspace directory: $WORKSPACE_DIR"
    fi
}

# Validate configuration
validate_config() {
    log_step "Validating configuration..."

    # Validate Android project directory
    if [[ -z "$ANDROID_PROJECT_DIR" ]]; then
        log_error "Android project directory is not specified"
        return 1
    fi

    # Validate workspace directory
    if [[ -z "$WORKSPACE_DIR" ]]; then
        log_error "Workspace directory could not be determined"
        return 1
    fi

    # Check if Android project directory exists (for symbolic links)
    if [[ ! -d "$ANDROID_PROJECT_DIR" ]]; then
        log_error "Android project directory does not exist: $ANDROID_PROJECT_DIR"
        log_info "Please ensure the directory exists"
        return 1
    fi

    # Validate that Android project directory looks like an Android project
    if [[ -d "$ANDROID_PROJECT_DIR" ]]; then
        if [[ ! -d "$ANDROID_PROJECT_DIR/vendor" ]]; then
            log_warning "Android project directory does not contain 'vendor' subdirectory"
            log_warning "This might not be a valid Android project directory: $ANDROID_PROJECT_DIR"

            # Check for NXP-specific directories
            local nxp_dirs=(
                "$ANDROID_PROJECT_DIR/vendor/nxp-opensource/kernel_imx"
                "$ANDROID_PROJECT_DIR/vendor/nxp-opensource/verisilicon_sw_isp_vvcam"
                "$ANDROID_PROJECT_DIR/vendor/nxp-opensource/nxp-mwifiex"
            )

            local missing_dirs=()
            for dir in "${nxp_dirs[@]}"; do
                if [[ ! -d "$dir" ]]; then
                    missing_dirs+=("$dir")
                fi
            done

            if [[ ${#missing_dirs[@]} -gt 0 ]]; then
                log_warning "The following expected NXP directories are missing:"
                for dir in "${missing_dirs[@]}"; do
                    echo "  - $dir"
                done
                log_warning "Symbolic links to missing directories will be skipped"
            fi
        fi
    fi

    # Check if repo command is available
    if ! command -v repo &> /dev/null; then
        log_error "repo command not found. Please install repo tool first."
        return 1
    fi

    # Validate sync jobs number
    if ! [[ "$SYNC_JOBS" =~ ^[0-9]+$ ]] || [[ "$SYNC_JOBS" -lt 1 ]]; then
        log_error "Invalid sync jobs number: $SYNC_JOBS"
        return 1
    fi

    # Validate common commit if provided
    if [[ -n "$COMMON_COMMIT" ]]; then
        if ! [[ "$COMMON_COMMIT" =~ ^[a-fA-F0-9]{7,40}$ ]]; then
            log_error "Invalid common commit hash format: $COMMON_COMMIT"
            log_info "Commit hash should be 7-40 hexadecimal characters"
            return 1
        fi
    fi

    # Check if workspace and Android project directories are the same
    if [[ "$WORKSPACE_DIR" == "$ANDROID_PROJECT_DIR" ]]; then
        log_error "Workspace directory cannot be the same as Android project directory"
        log_info "Workspace: $WORKSPACE_DIR"
        log_info "Android Project: $ANDROID_PROJECT_DIR"
        return 1
    fi

    # Check if workspace is inside Android project or vice versa
    if [[ "$WORKSPACE_DIR" == "$ANDROID_PROJECT_DIR"/* ]]; then
        log_warning "Workspace directory is inside Android project directory"
        log_warning "This might cause issues. Consider using a different workspace location."
    elif [[ "$ANDROID_PROJECT_DIR" == "$WORKSPACE_DIR"/* ]]; then
        log_warning "Android project directory is inside workspace directory"
        log_warning "This might cause issues with repo sync."
    fi

    log_success "Configuration validation passed"
    return 0
}

# Check if running with appropriate permissions
check_permissions() {
    local workspace_parent
    workspace_parent=$(dirname "$WORKSPACE_DIR")

    # Create parent directory if it doesn't exist and we have permission
    if [[ ! -d "$workspace_parent" ]]; then
        if ! mkdir -p "$workspace_parent" 2>/dev/null; then
            log_error "Cannot create parent directory: $workspace_parent"
            log_info "Please ensure you have write permissions or create the directory manually"
            return 1
        fi
        log_info "Created parent directory: $workspace_parent"
    fi

    # Check write permission to workspace parent directory
    if [[ ! -w "$workspace_parent" ]]; then
        log_error "No write permission to $workspace_parent"
        log_info "Please ensure you have write permissions to create the workspace directory"
        log_info "Current user: $(whoami)"
        log_info "Directory owner: $(ls -ld "$workspace_parent" 2>/dev/null | awk '{print $3}' || echo 'unknown')"
        return 1
    fi

    return 0
}

# Create workspace directory
create_workspace() {
    log_step "Creating workspace directory..."

    mkdir -p "$WORKSPACE_DIR"
    log_info "Creating workspace directory: $WORKSPACE_DIR"

    log_success "Workspace directory created: $WORKSPACE_DIR"
    log_info "Directory owner: $(whoami)"
}

# Initialize and sync repo
setup_repo() {
    log_step "Setting up repo..."

    # Change to workspace directory
    cd "$WORKSPACE_DIR"
    log_info "Changing to workspace directory"

    # Check if repo is already initialized
    if [[ -d "$WORKSPACE_DIR/.repo" ]]; then
        log_info "Repo already initialized, re-initializing with current configuration..."
        repo init -u "$MANIFEST_URL" -b "$MANIFEST_BRANCH"
        log_info "Re-initializing repo with manifest"
    else
        # Initialize repo
        repo init -u "$MANIFEST_URL" -b "$MANIFEST_BRANCH"
        log_info "Initializing repo"
    fi

    # Sync repo
    repo sync -j$SYNC_JOBS
    log_info "Syncing repo with $SYNC_JOBS jobs"

    # Checkout common directory to specific commit if provided
    if [[ -n "$COMMON_COMMIT" ]]; then
        local common_dir="$WORKSPACE_DIR/common"
        if [[ -d "$common_dir" ]]; then
            log_info "Checking out common directory to commit: $COMMON_COMMIT"
            cd "$common_dir"

            # Fetch the specific commit if it doesn't exist locally
            if ! git cat-file -e "$COMMON_COMMIT" 2>/dev/null; then
                log_info "Fetching commit $COMMON_COMMIT from remote..."
                git fetch origin "$COMMON_COMMIT" || {
                    log_warning "Failed to fetch specific commit, trying to fetch all refs..."
                    git fetch origin
                }
            fi

            # Checkout the specific commit
            if git checkout "$COMMON_COMMIT" 2>/dev/null; then
                log_success "Successfully checked out common directory to commit: $COMMON_COMMIT"
            else
                log_error "Failed to checkout common directory to commit: $COMMON_COMMIT"
                log_info "Please verify the commit hash is correct and exists in the repository"
                return 1
            fi

            # Return to workspace directory
            cd "$WORKSPACE_DIR"
        else
            log_warning "Common directory not found at: $common_dir"
            log_warning "Skipping common commit checkout"
        fi
    else
        log_info "No common commit specified, keeping default state"
    fi

    log_success "Repo setup completed"
    log_info "All files owned by: $(whoami)"
}

# Create symbolic links
create_symbolic_links() {
    log_step "Creating symbolic links..."

    # Define symbolic links: [link_name]="target_path"
    declare -A SYMLINKS=(
        ["kernel_imx"]="$ANDROID_PROJECT_DIR/vendor/nxp-opensource/kernel_imx"
        ["verisilicon_sw_isp_vvcam"]="$ANDROID_PROJECT_DIR/vendor/nxp-opensource/verisilicon_sw_isp_vvcam"
        ["nxp-mwifiex"]="$ANDROID_PROJECT_DIR/vendor/nxp-opensource/nxp-mwifiex"
    )

    # Change to workspace directory
    cd "$WORKSPACE_DIR"
    log_info "Changing to workspace directory for link creation"

    for link_name in "${!SYMLINKS[@]}"; do
        local target_path="${SYMLINKS[$link_name]}"
        local link_path="$WORKSPACE_DIR/$link_name"

        # Check if target exists
        if [[ ! -e "$target_path" ]]; then
            log_warning "Target does not exist: $target_path"
            log_warning "Skipping symbolic link: $link_name"
            continue
        fi

        # Remove existing link/file if it exists
        if [[ -e "$link_path" || -L "$link_path" ]]; then
            rm -f "$link_path"
            log_info "Removing existing $link_name"
        fi

        # Create symbolic link
        ln -s "$target_path" "$link_name"
        log_info "Creating symbolic link: $link_name -> $target_path"
    done

    log_success "Symbolic links created"
}

# Set up environment variables
setup_environment() {
    log_step "Setting up environment variables..."

    local bazel_workspace_dir="$WORKSPACE_DIR"

    # Add to user's bashrc for persistence
    local profile_file="$HOME/.bashrc"

    if ! grep -q "BAZEL_WORKSPACE_DIR" "$profile_file" 2>/dev/null; then
        {
            echo ""
            echo "# Android Kernel Workspace Environment"
            echo "export BAZEL_WORKSPACE_DIR='$bazel_workspace_dir'"
        } >> "$profile_file"
        log_success "Added BAZEL_WORKSPACE_DIR to $profile_file"
    else
        log_info "BAZEL_WORKSPACE_DIR already exists in $profile_file"
    fi

    log_success "Environment variables configured"
    log_info "BAZEL_WORKSPACE_DIR=$bazel_workspace_dir"
}

# Display summary
show_summary() {
    echo
    log_success "Android Kernel Workspace Setup Summary"
    echo "=================================================="
    echo "Workspace Directory: $WORKSPACE_DIR"
    echo "Android Project Dir: $ANDROID_PROJECT_DIR"
    echo "Manifest URL: $MANIFEST_URL"
    echo "Manifest Branch: $MANIFEST_BRANCH"
    echo "Sync Jobs: $SYNC_JOBS"
    if [[ -n "$COMMON_COMMIT" ]]; then
        echo "Common Commit: $COMMON_COMMIT"
    fi
    echo "Current User: $(whoami)"
    echo
    if [[ "$WORKSPACE_DIR_SPECIFIED" != true ]]; then
        echo "Workspace Directory Generation:"
        echo "  - Workspace: $WORKSPACE_DIR"
    fi
    echo
    echo "Symbolic Links Created:"
    echo "  - kernel_imx -> $ANDROID_PROJECT_DIR/vendor/nxp-opensource/kernel_imx"
    echo "  - verisilicon_sw_isp_vvcam -> $ANDROID_PROJECT_DIR/vendor/nxp-opensource/verisilicon_sw_isp_vvcam"
    echo "  - nxp-mwifiex -> $ANDROID_PROJECT_DIR/vendor/nxp-opensource/nxp-mwifiex"
    echo
    echo "Environment Variables:"
    echo "  - BAZEL_WORKSPACE_DIR=$WORKSPACE_DIR"
    echo
    echo "Next Steps:"
    echo "  1. cd $ANDROID_PROJECT_DIR"
    echo "  2. source ~/.bashrc"
    echo "  3. Start building the Android"
}

# Main function
main() {
    echo "Android Kernel Workspace Setup Script"
    echo "======================================"

    # Parse command line arguments
    parse_arguments "$@"

    # Show configuration
    log_info "Configuration:"
    echo "  Workspace Directory: $WORKSPACE_DIR"
    echo "  Android Project Dir: $ANDROID_PROJECT_DIR"
    echo "  Manifest URL: $MANIFEST_URL"
    echo "  Manifest Branch: $MANIFEST_BRANCH"
    echo "  Sync Jobs: $SYNC_JOBS"
    if [[ -n "$COMMON_COMMIT" ]]; then
        echo "  Common Commit: $COMMON_COMMIT"
    fi
    if [[ "$WORKSPACE_DIR_SPECIFIED" != true ]]; then
        echo "  Workspace Auto-Generated: Yes"
    else
        echo "  Workspace User-Specified: Yes"
    fi
    echo

    # Validate configuration
    if ! validate_config; then
        exit 1
    fi

    # Check permissions
    if ! check_permissions; then
        exit 1
    fi

    # Execute setup steps
    create_workspace
    setup_repo
    create_symbolic_links
    setup_environment

    # Show summary
    show_summary

    echo
    log_success "Android kernel workspace setup completed successfully!"
    log_info "You can now start building the Android in: $ANDROID_PROJECT_DIR"
}

# Run main function with all arguments
main "$@"
