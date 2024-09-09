FROM ubuntu:20.04
ARG userid
ARG groupid
ARG username

# If apt-get need http proxy in your host's network environment, you can refer to the line below.
# COPY apt.conf /etc/apt/apt.conf

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y tzdata git-core gnupg flex bison apt-utils build-essential zip curl zlib1g-dev liblz-dev gcc-multilib g++-multilib libc6-dev-i386 libncurses5 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig uuid uuid-dev liblzo2-2 liblzo2-dev lzop git u-boot-tools mtd-utils android-sdk-libsparse-utils android-sdk-ext4-utils device-tree-compiler gdisk m4 make libssl-dev libghc-gnutls-dev swig libdw-dev dwarves python bc cpio tar lz4 rsync ninja-build clang xxd \
 && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
 && dpkg-reconfigure -f noninteractive tzdata

# If failed to connect to android.googlesource.com, you can refer to the line below.
# ENV https_proxy=http://username:password@example.com:8080
ENV GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64 arm-gnu-toolchain-12.3.rel1-x86_64-aarch64-none-linux-gnu
RUN curl -o ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64}.tar.xz https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu/12.3.rel1/binrel/${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64}.tar.xz \
 && tar -xvJf ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64}.tar.xz -C /opt \
 && rm -rf ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64}.tar.xz

ENV GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32 arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi
RUN curl -o ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32}.tar.xz https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu/12.3.rel1/binrel/${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32}.tar.xz \
 && tar -xvJf ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32}.tar.xz -C /opt \
 && rm -rf ${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32}.tar.xz

ENV AARCH64_GCC_CROSS_COMPILE=/opt/${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH64}/bin/aarch64-none-linux-gnu-
ENV AARCH32_GCC_CROSS_COMPILE=/opt/${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32}/bin/arm-none-eabi-
ENV ARMGCC_DIR=/opt/${GCC_CROSS_COMPILE_TOOL_CHAIN_AARCH32}

RUN git clone -b main-kernel-build-2024 --single-branch --depth 1 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 /opt/prebuilt-android-clang \
  && cd /opt/prebuilt-android-clang \
  && git fetch origin 7061673283909f372f4938e45149d23bd10cbd40 \
  && git checkout 7061673283909f372f4938e45149d23bd10cbd40

RUN git clone https://android.googlesource.com/kernel/prebuilts/build-tools --single-branch -b main-kernel-build-2024 /opt/prebuilt-android-kernel-build-tools \
  && cd /opt/prebuilt-android-kernel-build-tools \
  && git fetch origin b46264b70e3cdf70d08c9ae2df6ea3002b242ebc \
  && git checkout b46264b70e3cdf70d08c9ae2df6ea3002b242ebc

RUN git clone -b main-kernel-build-2024 --single-branch --depth 1 https://android.googlesource.com/platform/prebuilts/rust /opt/prebuilt-android-rust \
  && cd /opt/prebuilt-android-rust \
  && git fetch origin 442511af884f074018466f85b4daadd4b0ac0050 \
  && git checkout 442511af884f074018466f85b4daadd4b0ac0050

RUN git clone -b main-kernel-build-2024 --single-branch --depth 1 https://android.googlesource.com/platform/prebuilts/clang-tools /opt/prebuilt-android-clang-tools \
  && cd /opt/prebuilt-android-clang-tools \
  && git fetch origin 1634c6a556d1f2c24897bf74156c6449486e8941 \
  && git checkout 1634c6a556d1f2c24897bf74156c6449486e8941

ENV CLANG_PATH=/opt/prebuilt-android-clang
ENV PATH=/opt/prebuilt-android-kernel-build-tools/linux-x86/bin:$PATH
ENV PATH=/opt/prebuilt-android-rust/linux-x86/1.73.0b/bin:$PATH
ENV PATH=/opt/prebuilt-android-clang-tools/linux-x86/bin:$PATH
ENV LIBCLANG_PATH=/opt/prebuilt-android-clang/clang-r510928/lib

RUN groupadd -g $groupid $username \
 && useradd -m -u $userid -g $groupid $username \
 && echo $username >/root/username
ENV HOME=/home/$username
ENV USER=$username

ENTRYPOINT chroot --userspec=$(cat /root/username):$(cat /root/username) / /bin/bash -i


