#!/bin/bash

# Префикс имени сервиса для фильтрации
SERVICE_PREFIX="test-memory"

# Пороговое значение использования памяти в процентах
MEMORY_THRESHOLD_PERCENT=80

# Получаем список сервисов, начинающихся с заданного префикса
SERVICES=$(systemctl list-units --type=service --state=running | awk '{print $1}' | grep "^$SERVICE_PREFIX")

for SERVICE in $SERVICES; do
    echo "Проверка сервиса $SERVICE"
    
    # Получаем значение MemoryMax для сервиса
    MEMORY_MAX=$(systemctl show -p MemoryMax "$SERVICE" | awk -F= '{print $2}')
    
    # Если MemoryMax не установлен, пропускаем этот сервис
    if [ "$MEMORY_MAX" = "infinity" ] || [ -z "$MEMORY_MAX" ]; then
        echo "Для сервиса $SERVICE не установлено ограничение MemoryMax. Пропускаем."
        continue
    fi
    
    # Получаем текущее использование памяти сервисом
    CURRENT_MEMORY_USAGE=$(systemctl show -p MemoryCurrent "$SERVICE" | awk -F= '{print $2}')
    
    # Вычисляем процент использования памяти
    MEMORY_USAGE_PERCENT=$((CURRENT_MEMORY_USAGE * 100 / MEMORY_MAX))
    
    echo "Сервис $SERVICE использует $MEMORY_USAGE_PERCENT% от максимальной памяти"
    
    # Проверяем, превышает ли текущее использование памяти пороговое значение
    if [ "$MEMORY_USAGE_PERCENT" -ge "$MEMORY_THRESHOLD_PERCENT" ]; then
        echo "Использование памяти ($MEMORY_USAGE_PERCENT%) превышает пороговое значение ($MEMORY_THRESHOLD_PERCENT%). Перезапуск сервиса $SERVICE."
        
        # Перезапускаем сервис
        systemctl restart "$SERVICE"
        
        # Проверяем статус сервиса после перезапуска
        if systemctl is-active --quiet "$SERVICE"; then
            echo "Сервис $SERVICE успешно перезапущен."
        else
            echo "Ошибка при перезапуске сервиса $SERVICE."
        fi
    else
        echo "Текущее использование памяти ($MEMORY_USAGE_PERCENT%) ниже порогового значения ($MEMORY_THRESHOLD_PERCENT%). Действий не требуется для $SERVICE."
    fi
done
