#!/usr/bin/env python3

import time
import signal
import sys

# Список для хранения выделенной памяти
memory_blocks = []

def cleanup(signum, frame):
    print("Очистка и выход...")
    sys.exit(0)

# Установка обработчика сигнала
signal.signal(signal.SIGTERM, cleanup)
signal.signal(signal.SIGINT, cleanup)

# Функция для выделения памяти
def allocate_memory(size_mb):
    return bytearray(size_mb * 1024 * 1024)

# Бесконечный цикл, эмулирующий утечку памяти
try:
    while True:
        # Выделяем 10MB памяти и сохраняем в список
        memory_blocks.append(allocate_memory(10))
        total_allocated = len(memory_blocks) * 10
        print(f"Выделено {total_allocated} MB памяти")
        time.sleep(1)
except MemoryError:
    print("Достигнут предел памяти")
    sys.exit(1)