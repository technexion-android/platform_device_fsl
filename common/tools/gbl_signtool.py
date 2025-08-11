#!/usr/bin/env python3

import argparse
import struct
import sys
import hashlib
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding

# This signing tool is designed to create a signed GBL image file with the following structure:
# +-----------------------------------------+
# |                                         |
# |           Original Image Data           |  <-- Original GBL image
# |                                         |
# +-----------------------------------------+  <-- metadata_offset
# |                                         |
# |                 Metadata                |  <-- metadata (20 bytes)
# |                (20 bytes)               |
# |                                         |
# +-----------------------------------------+  <-- signature_offset
# |                                         |
# |                Signature                |  <-- RSA signature (512 bytes for 4096-bit key)
# |               (512 bytes)               |
# |                                         |
# +-----------------------------------------+
# |                                         |
# |                 Padding                 |  <-- Padding (0x00)
# |                                         |
# +-----------------------------------------+
# |                                         |
# |                  Footer                 |  <-- Footer (16 bytes)
# |                (16 bytes)               |
# |                                         |
# +-----------------------------------------+  <-- End of final image

# Expected key and signature sizes (bits/bytes) for RSA 4096
EXPECTED_KEY_SIZE = 4096
SIGNATURE_SIZE = EXPECTED_KEY_SIZE // 8

# Metadata structure definition: magic(8s), origin_size(I), rollback_index_location(I), rollback_index(I)
# '<' denotes Little-Endian byte order
METADATA_FORMAT = '<8sIII'
METADATA_MAGIC = b'GBL0\0\0\0\0' # Padded to 8 bytes

# Footer structure definition: magic(8s), metadata_offset(I), image_size(I)
FOOTER_FORMAT = '<8sII'
FOOTER_MAGIC = b'GBLf\0\0\0\0' # Padded to 8 bytes
FOOTER_SIZE = struct.calcsize(FOOTER_FORMAT)


def main():
    """Main function to parse arguments and execute the signing process."""
    parser = argparse.ArgumentParser(
        description='Signs gbl image and corresponding metadata with spcified key, padded to a specific partition size.',
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument('--key', required=True, help='Path to the RSA 4096 private key file for signing.')
    parser.add_argument('--image', required=True, help='Path to the gbl image file to be signed.')
    parser.add_argument('--rollback_index_location', required=True, type=int, help='The rollback protection index location.')
    parser.add_argument('--rollback_index', required=True, type=int, help='The rollback protection index (integer).')
    parser.add_argument('--partition_size', required=True, type=int, help='The total size of the final output image in bytes.')
    parser.add_argument('--out', required=True, help='Output path for the final signed image.')

    args = parser.parse_args()

    # Print command-line arguments
    print("Running gbl_signtool with arguments:")
    for arg, value in vars(args).items():
        print(f"    {arg.replace('_', '-')}: {value}")

    # Read the original image and load the private key
    print(f"gbl_signtool: Loading files and key")
    try:
        with open(args.image, 'rb') as f:
            original_image_data = f.read()
        origin_gbl_size = len(original_image_data)
        print(f"        Successfully loaded original image: {args.image} ({origin_gbl_size} bytes)")
    except FileNotFoundError:
        print(f"Error: Original image file not found: {args.image}", file=sys.stderr)
        sys.exit(1)

    try:
        with open(args.key, "rb") as key_file:
            private_key = serialization.load_pem_private_key(key_file.read(), password=None)
        # Strictly check the key size
        if private_key.key_size != EXPECTED_KEY_SIZE:
            print(f"Error: Key size is {private_key.key_size} bits, but this tool requires a {EXPECTED_KEY_SIZE}-bit key.", file=sys.stderr)
            sys.exit(1)
        print(f"        Successfully loaded and verified {EXPECTED_KEY_SIZE}-bit private key: {args.key}")
    except (FileNotFoundError, ValueError, TypeError) as e:
        print(f"Error: Failed to load or parse the key file: {e}", file=sys.stderr)
        sys.exit(1)

    # Create file1 (Image + Metadata)
    print(f"\ngbl_signtool: Constructing metadata and data to be signed")

    # The metadata is appended immediately after the original image data.
    metadata_offset = origin_gbl_size

    metadata = struct.pack(
        METADATA_FORMAT,
        METADATA_MAGIC,
        origin_gbl_size,
        args.rollback_index_location,
        args.rollback_index
    )

    # This is the complete data block that will be signed, referred to as file1.
    file1_data = original_image_data + metadata

    print(f"        Metadata offset: {metadata_offset}")
    print(f"        Total size of data to be signed: {len(file1_data)} bytes")

    # Create file2 (file1 + Signature)
    print(f"\ngbl_signtool: Generating signature and creating signed image")

    # The signature is appended immediately after file1's data.
    signature_offset = len(file1_data)

    # Print the SHA256 hash of file1's data.
    sha256_hash = hashlib.sha256(file1_data).digest()
    print(f"        SHA256 hash: {sha256_hash.hex()}")

    # Then, sign the file using the private key.
    signature = private_key.sign(
        file1_data,
        padding.PKCS1v15(),
        hashes.SHA256()
    )

    if len(signature) != SIGNATURE_SIZE:
        print(f"Error: Generated signature length ({len(signature)}) does not match expected length ({SIGNATURE_SIZE}).", file=sys.stderr)
        sys.exit(1)

    # This is the data for file2.
    file2_data = file1_data + signature
    image_size = len(file2_data)

    print(f"        Signature offset: {signature_offset}")
    print(f"        Signature size: {len(signature)} bytes")
    print(f"        Total signed image size: {image_size} bytes")

    #  Construct the final image (file2 + Padding + Footer)
    print(f"\ngbl_signtool: Constructing the final image layout")

    # Construct the footer with the calculated offsets.
    footer = struct.pack(
        FOOTER_FORMAT,
        FOOTER_MAGIC,
        metadata_offset,
        image_size
    )

    # Calculate the size of the padding needed.
    current_size = len(file2_data)
    if args.partition_size < current_size + FOOTER_SIZE:
        print(
            f"Error: Partition size ({args.partition_size}) is too small to hold the data, signature, and footer "
            f"(at least {current_size + FOOTER_SIZE} bytes required).",
            file=sys.stderr
        )
        sys.exit(1)

    padding_size = args.partition_size - current_size - FOOTER_SIZE
    padding_data = b'\0' * padding_size

    print(f"        Padding size: {padding_size} bytes")
    print(f"        Footer size: {FOOTER_SIZE} bytes")

    # Assemble all parts: file2 data, then padding, then the footer at the very end.
    final_image_data = file2_data + padding_data + footer
    final_size = len(final_image_data)

    if final_size != args.partition_size:
        print(f"Fatal Error: Final file size ({final_size}) does not match partition size ({args.partition_size}). Please check script logic.", file=sys.stderr)
        sys.exit(1)

    # Write the final image to the output file
    print(f"\ngbl_signtool: Writing to output file")
    try:
        with open(args.out, 'wb') as f:
            f.write(final_image_data)
    except IOError as e:
        print(f"Error: Failed to write to output file '{args.out}': {e}", file=sys.stderr)
        sys.exit(1)

    print("\n" + "="*40)
    print(f" Successfully created signed image: {args.out}")
    print(f" Final file size: {final_size} bytes")
    print("="*40)


if __name__ == "__main__":
    main()
