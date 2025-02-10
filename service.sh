#!/system/bin/sh

# 等待系统完全启动
while [ "$(getprop 'sys.boot_completed')" != '1' ]; do sleep 1; done
while [ "$(getprop 'init.svc.bootanim')" != 'stopped' ]; do sleep 1; done

# 删除旧的标志文件
[ -f '/sdcard/._start_test' ] && rm -rf '/sdcard/._start_test'

# 直到创建新的标志文件
until [ -f '/sdcard/._start_test' ]; do
true > '/sdcard/._start_test'
done

# 删除标志文件
rm -rf '/sdcard/._start_test'

sleep 10

Module_Path="/data/adb/modules"

# 检测KernelSU和APatch环境
KernelSu() {
    if [ -f "/data/adb/ksud" ]; then
        S=$(awk '/ksud/{gsub("ksud ", ""); print substr($0,1,4)}' </data/adb/ksud -V)
        if [ "$S" = "v0.3" ]; then
            Module_Path="/data/adb/ksu/modules"
        fi
    fi
}

APatch() {
    # 检测APatch存在
    if [ -f "/data/adb/apd" ]; then
        APATCH_ENV=1
    fi
}

KernelSu
APatch

#检查并创建定时文件
directory="/data/adb/modules/Clear_Rubbish/cron.d/"
file="root"

if [ -d "$directory" ]; then
    if [ ! -f "$directory$file" ]; then
        touch "$directory$file"
    fi
fi

# 设置Clear_thermal路径
Rubbish_Path="$Module_Path/Clear_Rubbish"
Timing_Clear="/data/media/0/Android/Clear/清理垃圾/"

# 更改文件夹及其子文件夹权限为755
find "$Rubbish_Path" -type d -exec chmod -R 755 {} + >/dev/null 2>&1
find "$Timing_Clear" -type d -exec chmod -R 755 {} + >/dev/null 2>&1

# 读取时间设置并转换为cron格式
if [ -f "/data/media/0/Android/Clear/清理垃圾/自定义定时设置/定时设置.conf" ]; then
    Set_Time1=$(grep 'Set_Time1=' "/data/media/0/Android/Clear/清理垃圾/自定义定时设置/定时设置.conf" | cut -d'=' -f2)
    Set_minute1=$(grep 'Set_minute1=' "/data/media/0/Android/Clear/清理垃圾/自定义定时设置/定时设置.conf" | cut -d'=' -f2)
    Set_Time2=$(grep 'Set_Time2=' "/data/media/0/Android/Clear/清理垃圾/自定义定时设置/定时设置.conf" | cut -d'=' -f2)
    Set_minute2=$(grep 'Set_minute2=' "/data/media/0/Android/Clear/清理垃圾/自定义定时设置/定时设置.conf" | cut -d'=' -f2)
    Set_weekday1=$(grep 'Set_weekday1=' "/data/media/0/Android/Clear/清理垃圾/自定义定时设置/定时设置.conf" | cut -d'=' -f2)
    Set_weekday2=$(grep 'Set_weekday2=' "/data/media/0/Android/Clear/清理垃圾/自定义定时设置/定时设置.conf" | cut -d'=' -f2)

    # 检查分钟是否为00，如果是，则转换为0
    [ "$Set_minute1" = "00" ] && Set_minute1="0"
    [ "$Set_minute2" = "00" ] && Set_minute2="0"

    Cron_Time1="$Set_minute1 $Set_Time1 * * $Set_weekday1"
    Cron_Time2="$Set_minute2 $Set_Time2 * * $Set_weekday2"

    # 传递到【root】中
    echo "$Cron_Time1 /system/bin/sh $Rubbish_Path/Clear.sh" > "$Rubbish_Path/cron.d/root"
    echo "$Cron_Time2 /system/bin/sh $Rubbish_Path/Clear.sh" >> "$Rubbish_Path/cron.d/root"
fi

# 根据环境启动crond
if [ "$APATCH_ENV" = "1" ]; then
    # APatch使用自己的busybox路径
    /data/adb/apd/bin/busybox crond -c "$Rubbish_Path/cron.d/"
elif [ -f "/data/adb/ksud" ]; then
    /data/adb/ksu/bin/busybox crond -c "$Rubbish_Path/cron.d/"
else
    $(magisk --path)/.magisk/busybox/crond -c "$Rubbish_Path/cron.d/"
fi