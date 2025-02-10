##########################################################################################
# Config Flags
##########################################################################################
# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=true

# Set to true if you need post-fs-data script
POSTFSDATA=true

# Set to true if you need late_start service script
LATESTARTSERVICE=true

Manufacturer=$(getprop ro.product.vendor.manufacturer)
Codename=$(getprop ro.product.device)
Model=$(getprop ro.product.vendor.model)
Build=$(getprop ro.build.version.incremental)
Android=$(getprop ro.build.version.release)
CPU_ABI=$(getprop ro.product.cpu.abi)
MIUI=$(getprop ro.miui.ui.version.code)
MODVER=`grep_prop version $MODPATH/module.prop`
MINMIUI=13
MINSDK=31
MAXSDK=0

# 检测ROOT环境
ROOT_ENV="Magisk"
[ -f "/data/adb/ksud" ] && ROOT_ENV="KernelSU"
[ -f "/data/adb/apd" ] && ROOT_ENV="APatch"

print_modname() {
    ui_print "===================================================="
    sleep 0.05
    ui_print "- 设备: $Model"
    sleep 0.05
    ui_print "- 制造商: $Manufacturer"
    sleep 0.05
    ui_print "- SDK 平台: API level $API"
    sleep 0.05
    ui_print "- 安卓版本: Android $Android"
    sleep 0.05
    ui_print "- 系统版本: MIUI $MIUI"
    sleep 0.05
    ui_print "- 构建版本: $Build"
    sleep 0.05
    ui_print "- 运行环境: $ROOT_ENV"  # 新增环境显示
    ui_print "===================================================="
    sleep 0.3
    ui_print " "
    ui_print " "
    ui_print " "
    ui_print " - Modules Author : Fleshy grape"
    ui_print " "
    sleep 0.75
    ui_print " - Modules Name: AutoPurge、克洛琳德的狗 "
    sleep 0.5
    ui_print " "
    ui_print " - Modules Version: 1.7.0"
    sleep 0.5
    ui_print " "
    ui_print " - 最后构建日期: 2025-02-09 8:00 "
    sleep 0.5
    ui_print " "
    ui_print " "
    ui_print " "
    ui_print " "
    ui_print "————————————————————————————————————————————————————————————————"
    ui_print " "
    ui_print " - 欢迎使用 【AutoPurge Pro】"
    ui_print " "
    ui_print " - 模块配置目录位于:/data/media/0/Android/Clear/清理垃圾/"
    sleep 0.8
    ui_print " "
    ui_print " - 模块自定义清理时间位于:/data/media/0/Android/Clear/清理垃圾/自定义定时设置/ "
    ui_print " "
    ui_print "————————————————————————————————————————————————————————————————"
    sleep 15
}

# Copy/extract your module files into $MODPATH in on_install.
on_install() {
    # 解压模块文件
    unzip -o "$ZIPFILE" -x "META-INF/*" -x "install.sh" -d "$MODPATH" >/dev/null

    PrintX(){
        printf "- $1\n"
    }
    PATH="/data/media/0/Android/Clear/清理垃圾/"

    sleep 5
    ui_print " "
    echo " - 开始安装..."
    ui_print " "
    echo " - 创建路径"
    ui_print " "
    mkdir -p "/data/media/0/Android/Clear/清理垃圾"
    mkdir -p "/data/media/0/Android/Clear/清理垃圾/自定义定时设置/"

    sleep 2
    echo " - 安装名单"
    mv  $MODPATH/Name_list/白名单.prop /data/media/0/Android/Clear/清理垃圾/
    mv  $MODPATH/Name_list/黑名单.prop /data/media/0/Android/Clear/清理垃圾/
    mv  $MODPATH/Name_list/定时设置.conf /data/media/0/Android/Clear/清理垃圾/自定义定时设置/
    mv  $MODPATH/Name_list/Timing_Settings.sh /data/media/0/Android/Clear/清理垃圾/自定义定时设置/
    
    [ -d "${PATH}" ] && {
        Start
        Run
    } || PrintX
}

set_permissions() {
    # 设置模块目录权限
    set_perm_recursive $MODPATH 0 0 0755 0644
    
    # 设置数据目录权限（兼容APatch/KernelSU）
    set_perm_recursive "/data/media/0/Android/Clear" 1000 1000 0755 0644
    
    # 特殊权限设置（如果需要）
    [ -f "$MODPATH/service.sh" ] && {
        chmod 0755 $MODPATH/service.sh
        chcon u:object_r:system_file:s0 $MODPATH/service.sh
    }
}