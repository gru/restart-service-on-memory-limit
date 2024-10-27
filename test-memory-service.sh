#!/bin/bash

# Функция для очистки при выходе
cleanup() {
    echo "Очистка и выход..."
    exit 0
}

# Установка обработчика сигнала
trap cleanup SIGTERM SIGINT

# Бесконечный цикл, потребляющий память
while true; do
    # Выделяем 10MB памяти
    memory=$(dd if=/dev/zero bs=1M count=10)
    sleep 1
done
