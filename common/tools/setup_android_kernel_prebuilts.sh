#!/bin/bash

# Android Kernel Prebuilts Setup Script
# This script sets up external clang, kernel-build-tools, rust and clang-tools for kernel building

set -e  # Exit on any error

# Configuration - Allow customizable base directory
PREBUILTS_ROOT="${PREBUILTS_ROOT:-/opt}"
PREBUILTS_BASE="$PREBUILTS_ROOT/android-kernel-prebuilts-6.12"
KERNEL_PREBUILTS_PATH="$PREBUILTS_BASE"
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
# Check if running as root or with sudo
check_permissions() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root or with sudo"
        exit 1
    fi
}

# Get current commit hash of a git repository
get_current_commit() {
    local repo_path="$1"
    if [[ -d "$repo_path/.git" ]]; then
        cd "$repo_path"
        git rev-parse HEAD 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# Check if repository exists and has correct commit
check_repo_status() {
    local name="$1"
    local target_path="$2"
    local target_commit="$3"

    if [[ ! -d "$target_path" ]]; then
        log_info "$name: Repository does not exist at $target_path"
        return 1
    fi

    if [[ ! -d "$target_path/.git" ]]; then
        log_warning "$name: Directory exists but is not a git repository"
        return 1
    fi

    local current_commit
    current_commit=$(get_current_commit "$target_path")
    if [[ "$current_commit" == "$target_commit" ]]; then
        log_success "$name: Already at correct commit ($target_commit)"
        return 0
    else
        log_info "$name: Current commit ($current_commit) differs from target ($target_commit)"
        return 1
    fi
}

# Clone or update repository
setup_repository() {
    local name="$1"
    local url="$2"
    local branch="$3"
    local target_commit="$4"
    local target_path="$5"

    log_info "Setting up $name..."

    # Check current status
    if check_repo_status "$name" "$target_path" "$target_commit"; then
        return 0
    fi

    # Create parent directory if it doesn't exist
    local parent_dir
    parent_dir=$(dirname "$target_path")
    mkdir -p "$parent_dir"

    # Remove existing directory if it's not a proper git repo
    if [[ -d "$target_path" && ! -d "$target_path/.git" ]]; then
        log_warning "$name: Removing existing non-git directory"
        rm -rf "$target_path"
    fi

    # Clone if directory doesn't exist
    if [[ ! -d "$target_path" ]]; then
        log_info "$name: Cloning repository..."
        git clone -b "$branch" --single-branch --depth 1 "$url" "$target_path"
    fi

    # Navigate to repository and update
    cd "$target_path"

    # Fetch the specific commit
    log_info "$name: Fetching commit $target_commit..."
    git fetch origin "$target_commit" --depth 1

    # Checkout the specific commit
    log_info "$name: Checking out commit $target_commit..."
    git checkout "$target_commit"

    # Verify the checkout
    local current_commit
    current_commit=$(git rev-parse HEAD)
    if [[ "$current_commit" == "$target_commit" ]]; then
        log_success "$name: Successfully set to commit $target_commit"
    else
        log_error "$name: Failed to checkout correct commit"
        return 1
    fi
}

# Setup individual tools
setup_clang() {
    setup_repository "clang" \
        "https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86" \
        "main-kernel" \
        "9a98ca4072ec000f301bd3ece481ea2baca76ca5" \
        "$PREBUILTS_BASE/clang/host/linux-x86"
}

setup_kernel_build_tools() {
    setup_repository "kernel-build-tools" \
        "https://android.googlesource.com/kernel/prebuilts/build-tools" \
        "main" \
        "e65603ef822477b059f35d8c6ac2be6b2113e14f" \
        "$PREBUILTS_BASE/kernel-build-tools"
}

setup_rust() {
    setup_repository "rust" \
        "https://android.googlesource.com/platform/prebuilts/rust" \
        "main-kernel" \
        "8d38f3f31e9a0c9a5cb537b9f73da400bedb9a75" \
        "$PREBUILTS_BASE/rust"
}

setup_clang_tools() {
    setup_repository "clang-tools" \
        "https://android.googlesource.com/platform/prebuilts/clang-tools" \
        "main" \
        "edb3c73c0398462492e7371fae68ce2db7afb6c7" \
        "$PREBUILTS_BASE/clang-tools"
}

# Main function
main() {
    log_info "Starting Android Kernel Prebuilts Setup"
    log_info "Target directory: $PREBUILTS_BASE"

    # Check permissions
    check_permissions

    # Create base directory
    mkdir -p "$PREBUILTS_BASE"

    # Setup each tool
    echo
    setup_clang || { log_error "Failed to setup clang"; exit 1; }

    echo
    setup_kernel_build_tools || { log_error "Failed to setup kernel-build-tools"; exit 1; }

    echo
    setup_rust || { log_error "Failed to setup rust"; exit 1; }

    echo
    setup_clang_tools || { log_error "Failed to setup clang-tools"; exit 1; }

    # Add to system-wide environment via /etc/profile
    echo
    log_info "Setting up environment variable..."

    # Add to /etc/profile for system-wide availability on boot
    PROFILE_LINE="export KERNEL_PREBUILTS_PATH=$KERNEL_PREBUILTS_PATH"

    if ! grep -q "KERNEL_PREBUILTS_PATH" /etc/profile 2>/dev/null; then
        echo "" >> /etc/profile
        echo "# Android Kernel Prebuilts Path" >> /etc/profile
        echo "$PROFILE_LINE" >> /etc/profile
        log_success "Added KERNEL_PREBUILTS_PATH to /etc/profile"
    else
        # Update existing entry
        sed -i "s|^export KERNEL_PREBUILTS_PATH=.*|$PROFILE_LINE|" /etc/profile
        log_info "Updated existing KERNEL_PREBUILTS_PATH in /etc/profile"
    fi

    echo
    log_success "Android Kernel Prebuilts setup completed successfully!"
    log_info "You may need to restart your shell or run 'source /etc/profile' to use the environment variable"

    # Display summary
    echo
    log_info "Setup Summary:"
    echo "  - clang: $PREBUILTS_BASE/clang/host/linux-x86"
    echo "  - kernel-build-tools: $PREBUILTS_BASE/kernel-build-tools"
    echo "  - rust: $PREBUILTS_BASE/rust"
    echo "  - clang-tools: $PREBUILTS_BASE/clang-tools"
}

# Run main function
main "$@"
