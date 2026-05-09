#!/vendor/bin/sh

# 1. Read all properties set by ZramUtils.java
zram_size_gb=$(getprop persist.vendor.zram.size)
zram_comp=$(getprop persist.vendor.zram.comp_algorithm)
swappiness=$(getprop persist.vendor.vm.swappiness)

# 2. Set Defaults (matching your Java fallbacks)
[ -z "$zram_size_gb" ] || [ "$zram_size_gb" = "-1" ] && zram_size_gb=12
[ -z "$zram_comp" ] && zram_comp="lz4"
[ -z "$swappiness" ] && swappiness=60

# 3. Apply ZRAM configuration
if [ -f /sys/block/zram0/disksize ]; then
    # Disable swap and reset to apply new size/algorithm
    swapoff /dev/block/zram0 > /dev/null 2>&1
    echo 1 > /sys/block/zram0/reset

    # Apply the compression algorithm from the UI
    echo "$zram_comp" > /sys/block/zram0/comp_algorithm

    # Apply the disksize
    let zRamSizeMB="$zram_size_gb * 1024"
    echo "${zRamSizeMB}M" > /sys/block/zram0/disksize

    # Re-initialize
    mkswap /dev/block/zram0
    swapon /dev/block/zram0 -p 32758
fi

# 4. Apply Swappiness
if [ -f /proc/sys/vm/swappiness ]; then
    echo "$swappiness" > /proc/sys/vm/swappiness
fi