#!/system/bin/sh

# 动态模块路径检测
detect_module_path() {
    # 检测APatch
    [ -f "/data/adb/apd" ] && {
        echo "/data/adb/modules"  # APatch保持与Magisk相同路径
        return
    }
    
    # 检测KernelSU
    [ -f "/data/adb/ksud" ] && {
        S=$(awk '/ksud/{gsub("ksud ", ""); print substr($0,1,4)}' </data/adb/ksud -V 2>/dev/null)
        [ "$S" = "v0.3" ] && echo "/data/adb/ksu/modules" || echo "/data/adb/modules"
        return
    }
    
    # 默认Magisk路径
    echo "/data/adb/modules"
}

# 配置文件路径                                    
config_file="/data/media/0/Android/Clear/清理垃圾/自定义定时设置/定时设置.conf"
MODULE_PATH=$(detect_module_path)
SERVICE_SCRIPT="$MODULE_PATH/Clear_Rubbish/service.sh"

# 检查配置文件是否存在                           
if [ ! -f "$config_file" ]; then
    echo "错误：配置文件 $config_file 不存在"
    exit 1
fi

# 读取并验证时间设置
validation_error=0
while IFS='=' read -r key value; do
    # 跳过空行和注释
    [ -z "$key" ] && continue
    echo "$key" | grep -q '^#' && continue

    case "$key" in
        Set_Time1|Set_Time2)
            # 检查小时格式
            if ! echo "$value" | grep -qE '^[0-9]{1,2}$' || [ "$value" -lt 0 ] || [ "$value" -gt 23 ]; then
                echo "[错误] $key 值非法：$value（有效范围0-23）"
                validation_error=1
            fi
            ;;
        Set_minute1|Set_minute2)
            # 检查分钟格式
            if ! echo "$value" | grep -qE '^[0-9]{1,2}$' || [ "$value" -lt 0 ] || [ "$value" -gt 59 ]; then
                echo "[错误] $key 值非法：$value（有效范围0-59）"
                validation_error=1
            fi
            ;;
        Set_weekday1|Set_weekday2)
            # 检查星期格式
            if ! echo "$value" | grep -qE '^[1-7]$'; then
                echo "[错误] $key 值非法：$value（有效范围1-7）"
                validation_error=1
            fi
            ;;
        *)
            echo "[警告] 未知配置项：$key"
    esac
done < "$config_file"

# 存在验证错误时退出
[ $validation_error -ne 0 ] && exit 1

# 执行主服务脚本
echo " "
echo " - 时间格式校验通过 "
echo " "
echo " - 正在应用定时设置..."

if [ -x "$SERVICE_SCRIPT" ]; then
    sh "$SERVICE_SCRIPT" >/dev/null 2>&1
else
    echo "[错误] 服务脚本不存在或不可执行：$SERVICE_SCRIPT"
    exit 1
fi

# 清理备份文件
rm -f "/data/media/0/Android/Clear/清理垃圾/自定义定时设置/定时设置.conf.bak" 2>/dev/null

echo " "
echo " - 定时设置已完成 "
echo " - 请返回上级菜单"